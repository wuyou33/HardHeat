library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ds18b20_pkg.all;
use work.one_wire_pkg.all;

entity ds18b20_tb is
end entity;

architecture ds18b20_tb_arch of ds18b20_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    constant TEST_TEMP      : std_logic_vector(15 downto 0) := x"0031";
    type data_t is array(natural range <>) of std_logic_vector(8 - 1 downto 0);
    constant TEST_DATA      : data_t(9 - 1 downto 0) :=
        (x"31", x"00", x"4B", x"46", x"FF", x"FF", x"02", x"10", x"72");

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal reset_ow         : std_logic;
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
    signal ow_n_out         : std_logic;
    signal data_in          : std_logic_vector(8 - 1 downto 0);
    signal data_in_f        : std_logic;
    signal receive_data_f   : std_logic;
    signal busy             : std_logic;
    signal data_out         : std_logic_vector(8 - 1 downto 0);
    signal data_out_f       : std_logic;
    signal err              : std_logic;
    signal err_id           : unsigned(1 downto 0);
    signal temp             : signed(16 - 1 downto 0);
    signal temp_f           : std_logic;
    signal temp_error       : std_logic;
    signal crc              : std_logic_vector(8 - 1 downto 0);

    -- Signals internal to the test bench
    signal conv             : std_logic;

begin

    -- Invert the output signal coming from the 1-wire module for display
    ow_out <= not ow_n_out;

    DUT_inst: ds18b20
    generic map
    (
        -- Use a small 1ms conversion delay to not make simulation take long
        CONV_DELAY_VAL      => 100000
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        conv_in_f           => conv,
        data_in             => data_out,
        data_in_f           => data_out_f,
        busy_in             => busy,
        error_in            => err,
        error_id_in         => err_id,
        reset_ow_out        => reset_ow,
        data_out            => data_in,
        data_out_f          => data_in_f,
        receive_data_out_f  => receive_data_f,
        temp_out            => temp,
        temp_out_f          => temp_f,
        crc_in              => crc,
        temp_error_out      => temp_error
    );

    ow_p: one_wire
    generic map
    (
        RESET_ON_D          => 48000,
        RESET_SAMPLE_D      => 7000,
        RESET_D             => 41000,
        TX_ONE_LOW_D        => 600,
        TX_ONE_HIGH_D       => 6400,
        TX_ZERO_LOW_D       => 6000,
        TX_ZERO_HIGH_D      => 1000,
        RX_SAMPLE_D         => 900,
        RX_RELEASE_D        => 5500
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        reset_ow            => reset_ow,
        ow_in               => ow_in,
        data_in             => data_in,
        data_in_f           => data_in_f,
        receive_data_f      => receive_data_f,
        ow_out              => ow_n_out,
        error_out           => err,
        error_id_out        => err_id,
        busy_out            => busy,
        data_out            => data_out,
        data_out_f          => data_out_f,
        crc_out             => crc
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    -- Send data to 1-wire module
    data_gen: process(clk, reset)
        type data_gen_state is (idle, wait_busy, wait_ow_high, wait_receive,
            release_ow, tx, assert_temp);
        variable state      : data_gen_state;
        variable next_state : data_gen_state;
        variable byte_num   : natural;
        variable bit_num    : natural;
        variable last_state : std_logic;
        variable busy_state : std_logic;
    begin
        if reset = '1' then
            state := idle;
            next_state := idle;
            ow_in <= '1';
            byte_num := 0;
            bit_num := 0;
            last_state := '0';
            busy_state := '0';
            conv <= '0';
        elsif rising_edge(clk) then
            if state = idle then
                conv <= '1';
                state := wait_ow_high;
                if receive_data_f = '1' then
                    state := wait_ow_high;
                end if;
            elsif state = wait_busy then
                if not busy_state = busy and busy = '0' then
                    state := next_state;
                end if;
                busy_state := busy;
            elsif state = wait_ow_high then
                conv <= '0';
                if not last_state = ow_out and ow_out = '1' then
                    ow_in <= '0';
                    state := wait_busy;
                    next_state := release_ow;
                end if;
                last_state := ow_out;
            elsif state = release_ow then
                ow_in <= '1';
                state := wait_receive;
            elsif state = wait_receive then
                if receive_data_f = '1' then
                    state := tx;
                    last_state := ow_out;
                end if;
            elsif state = tx then
                if not last_state = ow_out and ow_out = '1' then
                    ow_in <= TEST_DATA(TEST_DATA'high - byte_num)(bit_num);
                    bit_num := bit_num + 1;
                    if bit_num = 8 then
                        byte_num := byte_num + 1;
                        bit_num := 0;
                        if byte_num = 9 then
                            state := assert_temp;
                            byte_num := 0;
                            bit_num := 0;
                        end if;
                    end if;
                end if;
                last_state := ow_out;
            elsif state = assert_temp then
                if temp_f = '1' then
                    assert crc = x"00" report "CRC does not match!"
                        severity warning;
                    assert temp = signed(TEST_TEMP) report
                        "Received temp does not match!" severity warning;
                    state := idle;
                end if;
            end if;
        end if;
    end process;

end;
