library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity ds18b20_data_gen is
    generic
    (
        MICROSECOND_D       : positive
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        ow_out              : in std_logic;
        -- Test temperature value in, data_gen generates a new data packet from
        -- this value and transmits it to the 1-wire bus
        temp_in             : in signed(16 - 1 downto 0);
        temp_in_f           : in std_logic;
        ow_in               : out std_logic
    );
end entity;

architecture rtl of ds18b20_data_gen is

    subtype data_t is std_logic_vector(8 - 1 downto 0);

    type data_array_t is array(natural range <>) of data_t;

    function calc_crc(Arg : data_t; NewByte : data_t) return data_t is
        variable crc        : data_t;
        variable bit_num    : natural := 0;
    begin
        while bit_num < 8 loop
            crc := Arg;
            crc(crc'left) := NewByte(bit_num) xor crc(crc'right);
            crc(4) := crc(3) xor crc(crc'left);
            crc(5) := crc(4) xor crc(crc'left);
            crc := shift_left_vec(crc, 1);
            bit_num := bit_num + 1;
        end loop;
        return(crc);
    end function;

    function gen_data(Temp : signed(16 - 1 downto 0)) return data_array_t is
        variable byte_num   : natural := 0;
        variable bit_num    : natural := 0;
        variable data       : data_array_t(8 downto 0);
        variable crc        : data_t := (others => '0');
    begin
        while byte_num < 9 loop
            if byte_num = 0 then
                data(byte_num) := std_logic_vector(Temp(7 downto 0));
            elsif byte_num = 1 then
                data(byte_num) := std_logic_vector(Temp(15 downto 8));
            -- Just use some (valid) fixed data for the rest of the bytes
            elsif byte_num = 2 then
                data(byte_num) := x"4B";
            elsif byte_num = 3 then
                data(byte_num) := x"46";
            elsif byte_num = 4 then
                data(byte_num) := x"FF";
            elsif byte_num = 5 then
                data(byte_num) := x"FF";
            elsif byte_num = 6 then
                data(byte_num) := x"02";
            elsif byte_num = 7 then
                data(byte_num) := x"10";
            elsif byte_num = 8 then
                data(byte_num) := crc;
                -- Do not calculate CRC for CRC byte so just return
                return(data);
            end if;
            crc := calc_crc(crc, data(byte_num));
            byte_num := byte_num + 1;
        end loop;
    end function;

    constant RESET_D            : natural := MICROSECOND_D * 479;
    constant RESET_WAIT_D       : natural := MICROSECOND_D * 15;
    constant RESET_PRESENCE_D   : natural := MICROSECOND_D * 239;
    constant ZERO_D             : natural := MICROSECOND_D * 59;
    constant ONE_D              : natural := MICROSECOND_D * 1;

    constant SKIP_ROM_CMD       : std_logic_vector(8 - 1 downto 0) := x"CC";
    constant CONV_CMD           : std_logic_vector(8 - 1 downto 0) := x"44";
    constant READ_CMD           : std_logic_vector(8 - 1 downto 0) := x"BE";
begin

    data_gen_p: process(clk, reset)
        type data_gen_state is (
            idle,
            reset_wait,
            presence,
            wait_reset_high,
            read,
            command,
            transmit
        );

        -- Increment timer value and go to next state when delay is fullfilled
        procedure handle_delay( constant delay      : in natural;
                                variable timer      : inout natural;
                                constant next_state : in data_gen_state;
                                variable state_var  : inout data_gen_state) is
        begin
            timer := timer + 1;
            if timer >= delay then
                state_var := next_state;
                timer := 0;
            end if;
        end procedure;

        procedure new_bit(  variable buf : inout data_t;
                            constant val : in std_logic) is
        begin
            buf := shift_right_vec(buf, 1);
            buf(buf'high) := val;
        end procedure;

        variable state          : data_gen_state;
        variable next_state     : data_gen_state;
        variable byte_num       : natural;
        variable bit_num        : natural;
        variable last_out       : std_logic;
        variable tx_buf         : data_array_t(8 downto 0);
        variable timer          : natural;
        variable rx_buf         : data_t;
        variable rx_bits_left   : natural;
    begin
        if reset = '1' then
            state := idle;
            next_state := idle;
            byte_num := 0;
            bit_num := 0;
            last_out := '0';
            tx_buf := gen_data(temp_in);
            timer := 0;
            rx_buf := (others => '0');
            rx_bits_left := 0;
            ow_in <= '1';

        elsif rising_edge(clk) then

            if state = idle then
                ow_in <= '1';
                if ow_out = '0' then
                    handle_delay(RESET_D, timer, reset_wait, state);
                else
                    timer := 0;
                end if;

            elsif state = reset_wait then
                handle_delay(RESET_WAIT_D, timer, presence, state);

            elsif state = presence then
                ow_in <= '0';
                handle_delay(RESET_PRESENCE_D, timer, wait_reset_high, state);

            elsif state = wait_reset_high then
                ow_in <= '1';
                if ow_out = '1' then
                    state := read;
                    rx_buf := (others => '0');
                    rx_bits_left := rx_buf'length;
                    next_state := command;
                end if;

            elsif state = read then
                ow_in <= '1';
                if rx_bits_left > 0 then
                    if ow_out = '0' then
                        timer := timer + 1;
                    elsif ow_out = '1' then
                        if timer >= ZERO_D then
                            new_bit(rx_buf, '0');
                            rx_bits_left := rx_bits_left - 1;
                        elsif timer >= ONE_D then
                            new_bit(rx_buf, '1');
                            rx_bits_left := rx_bits_left - 1;
                        end if;
                        timer := 0;
                    end if;
                else
                    state := next_state;
                end if;

            elsif state = command then
                if rx_buf = SKIP_ROM_CMD then
                    next_state := command;
                    state := read;
                    rx_bits_left := rx_buf'length;
                elsif rx_buf = CONV_CMD then
                    -- Just start waiting for next reset
                    state := idle;
                    next_state := idle;
                    rx_bits_left := rx_buf'length;
                elsif rx_buf = READ_CMD then
                    state := transmit;
                    rx_bits_left := 0;
                else
                    report "Unknown command" severity warning;
                    state := idle;
                    next_state := idle;
                    rx_bits_left := 0;
                end if;
                rx_buf := (others => '0');

            elsif state = transmit then
                if not last_out = ow_out and ow_out = '0' then
                    ow_in <= tx_buf(byte_num)(bit_num);
                    bit_num := bit_num + 1;
                    if bit_num = 8 then
                        bit_num := 0;
                        byte_num := byte_num + 1;
                        if byte_num = tx_buf'length then
                            state := idle;
                            next_state := idle;
                            bit_num := 0;
                            byte_num := 0;
                        end if;
                    end if;
                end if;
            end if;
            last_out := ow_out;

            -- Update TX buffer data if temperature has changed
            if temp_in_f = '1' then
                tx_buf := gen_data(temp_in);
            end if;
        end if;
    end process;

end;
