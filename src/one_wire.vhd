library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity one_wire is
    generic
    (
        -- One wire delay values in counter values clocked with the main clock
        RESET_ON_D          : positive;
        RESET_SAMPLE_D      : positive;
        RESET_D             : positive;
        TX_ONE_LOW_D        : positive;
        TX_ONE_HIGH_D       : positive;
        TX_ZERO_LOW_D       : positive;
        TX_ZERO_HIGH_D      : positive;
        RX_SAMPLE_D         : positive;
        RX_RELEASE_D        : positive
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        -- Strobe for generating a reset on the 1-wire bus
        reset_ow            : in std_logic;
        ow_in               : in std_logic;
        -- Data to be sent to the 1-wire bus
        data_in             : in std_logic_vector(8 - 1 downto 0);
        -- Strobe indicating new data has arrived to be sent out
        data_in_f           : in std_logic;
        -- Flag for starting the process of receiving data
        receive_data_f      : in std_logic;
        -- Data received from the 1-wire bus
        data_out            : out std_logic_vector(8 - 1 downto 0);
        -- Strobe indicating new data has been received
        data_out_f          : out std_logic;
        ow_out              : out std_logic;
        -- Signal indicating the 1-wire bus is busy
        busy_out            : out std_logic;
        -- Signal indicating there has been an error, bus needs to be reset
        error_out           : out std_logic;
        -- ID indicating type of error, 1 = no device on bus
        error_id_out        : out unsigned(1 downto 0)
    );
end entity;

architecture one_wire_arch of one_wire is
    signal ow_reset_out     : std_logic;
    signal ow_send_out      : std_logic;
    signal ow_receive_out   : std_logic;
    signal err_no_dev       : std_logic;
    signal busy_reset       : std_logic;
    signal busy_send        : std_logic;
    signal busy_receive     : std_logic;
begin

    ow_rst_p: process(clk, reset)
        type ow_rst_state is (idle, reset_on, reset_sample, reset_delay);
        variable state      : ow_rst_state;
        variable timer      : unsigned(16 - 1 downto 0);
    begin
        if reset = '1' then
            state := idle;
            timer := (others => '0');
            err_no_dev <= '0';
            busy_reset <= '0';
            ow_reset_out <= '0';
        elsif rising_edge(clk) then
            if state = idle then
                if reset_ow = '1' then
                    state := reset_on;
                    ow_reset_out <= '1';
                    busy_reset <= '1';
                else
                    busy_reset <= '0';
                end if;
            elsif state = reset_on then
                if timer < RESET_ON_D then
                    timer := timer + 1;
                else
                    -- Release bus
                    ow_reset_out <= '0';
                    state := reset_sample;
                    timer := (others => '0');
                end if;
            elsif state = reset_sample then
                if timer < RESET_SAMPLE_D then
                    timer := timer + 1;
                else
                    -- No device present on bus, indicate error
                    if ow_in = '1' then
                        err_no_dev <= '1';
                        state := idle;
                        timer := (others => '0');
                    end if;
                    state := reset_delay;
                    timer := (others => '0');
                end if;
            elsif state = reset_delay then
                if timer < RESET_D then
                    timer := timer + 1;
                else
                    state := idle;
                    timer := (others => '0');
                end if;
            end if;
        end if;
    end process;

    ow_send_p: process(clk, reset)
        type ow_send_state is (idle, tx_one_low, tx_one_high, tx_zero_low,
            tx_zero_high, tx_next_bit);
        variable state      : ow_send_state;
        variable timer      : unsigned(16 - 1 downto 0);
        variable data       : std_logic_vector(data_in'range);
        variable data_left  : unsigned(ceil_log2(data_in'length) downto 0);
    begin
        if reset = '1' then
            state := idle;
            -- Bus is released on reset
            ow_send_out <= '0';
            busy_send <= '0';
            timer := (others => '0');
            data := (others => '0');
            data_left := (others => '0');
        elsif rising_edge(clk) then
            if state = idle then
                -- Bus always released when idle
                ow_send_out <= '0';
                if data_in_f = '1' then
                    data := data_in;
                    data_left := to_unsigned(data'length, data_left'length);
                    busy_send <= '1';
                    state := tx_next_bit;
                    timer := (others => '0');
                    -- Pull bus down on both cases
                    ow_send_out <= '1';
                else
                    busy_send <= '0';
                end if;
            elsif state = tx_one_low then
                if timer < TX_ONE_LOW_D then
                    timer := timer + 1;
                else
                    -- Release bus
                    ow_send_out <= '0';
                    state := tx_one_high;
                    timer := (others => '0');
                end if;
            elsif state = tx_one_high then
                if timer < TX_ONE_HIGH_D then
                    timer := timer + 1;
                else
                    state := tx_next_bit;
                    timer := (others => '0');
                end if;
            elsif state = tx_zero_low then
                if timer < TX_ZERO_LOW_D then
                    timer := timer + 1;
                else
                    state := tx_next_bit;
                    timer := (others => '0');
                end if;
            elsif state = tx_zero_high then
                if timer < TX_ZERO_HIGH_D then
                    timer := timer + 1;
                else
                    state := tx_next_bit;
                    timer := (others => '0');
                end if;
            elsif state = tx_next_bit then
                if data_left = 0 then
                    state := idle;
                else
                    if data(data'left) = '1' then
                        state := tx_one_low;
                    else
                        state := tx_zero_low;
                    end if;
                    data_left := data_left - 1;
                    -- Shift data
                    data := shift_left_vec(data, 1);
                    -- Pull bus down on both cases
                    ow_send_out <= '1';
                end if;
                timer := (others => '0');
            end if;
        end if;
    end process;

    ow_receive_p: process(clk, reset)
        type ow_receive_state is (idle, rx_low, rx_sample, rx_release,
            rx_next_bit);
        variable state      : ow_receive_state;
        variable timer      : unsigned(16 - 1 downto 0);
        variable data       : std_logic_vector(data_in'range);
        variable data_left  : unsigned(ceil_log2(data_in'length) downto 0);
    begin
        if reset = '1' then
            state := idle;
            ow_receive_out <= '0';
            busy_receive <= '0';
            timer := (others => '0');
            data := (others => '0');
            data_left := (others => '0');
            data_out <= (others => '0');
            data_out_f <= '0';
        elsif rising_edge(clk) then
            if state = idle then
                -- Reset data out indicator strobe
                data_out_f <= '0';
                if receive_data_f = '1' then
                    -- Pull bus low
                    ow_receive_out <= '1';
                    busy_receive <= '1';
                    data := (others => '0');
                    data_left := to_unsigned(data'length, data_left'length);
                    state := rx_low;
                    timer := (others => '0');
                else
                    busy_receive <= '0';
                end if;
            elsif state = rx_low then
                -- Delay is same as for transmit low-state
                if timer < TX_ONE_LOW_D then
                    timer := timer + 1;
                else
                    -- Release bus
                    ow_receive_out <= '0';
                    state := rx_sample;
                    timer := (others => '0');
                end if;
            elsif state = rx_sample then
                if timer < RX_SAMPLE_D then
                    timer := timer + 1;
                else
                    data(0) := ow_in;
                    data_left := data_left - 1;
                    state := rx_release;
                    timer := (others => '0');
                end if;
            elsif state = rx_release then
                if timer < RX_RELEASE_D then
                    timer := timer + 1;
                else
                    -- Release bus
                    ow_receive_out <= '0';
                    state := rx_next_bit;
                    timer := (others => '0');
                end if;
            elsif state = rx_next_bit then
                if data_left = 0 then
                    state := idle;
                    data_out <= data;
                    data_out_f <= '1';
                else
                    data := shift_left_vec(data, 1);
                    ow_receive_out <= '1';
                    state := rx_low;
                end if;
            end if;
        end if;
    end process;

    ow_write_p: process(clk, reset)
    begin
        if reset = '1' then
            ow_out <= '0';
        elsif rising_edge(clk) then
            ow_out <= ow_reset_out or ow_send_out or ow_receive_out;
        end if;
    end process;

    ow_error_p: process(clk, reset)
    begin
        if reset = '1' then
            error_out <= '0';
            error_id_out <= (others => '0');
        elsif rising_edge(clk) then
            if err_no_dev = '1' then
                error_id_out <= to_unsigned(1, error_id_out'length);
                error_out <= '1';
            else
                error_out <= '0';
                error_id_out <= (others => '0');
            end if;
        end if;
    end process;

    ow_busy_p: process(clk, reset)
    begin
        if reset = '1' then
            busy_out <= '0';
        elsif rising_edge(clk) then
            busy_out <= busy_reset or busy_send or busy_receive;
        end if;
    end process;

end;