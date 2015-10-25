library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.temp_controller_pkg.all;
use work.ds18b20_data_gen_pkg.all;

entity temp_controller_tb is
end entity;

architecture temp_controller_tb_arch of temp_controller_tb is
    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal enable           : std_logic;
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
    signal ow_n_out         : std_logic;
    signal temp             : signed(16 - 1 downto 0);
    signal temp_f           : std_logic;
    signal conv             : std_logic;
    signal crc              : std_logic_vector(7 downto 0);
    signal receive_data_f   : std_logic;
    signal busy             : std_logic;
    signal test_temp        : signed(16 - 1 downto 0);
    signal test_temp_f      : std_logic;
begin

    reset <= '1', '0' after 500 ns;

    enable <= '1';

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    ow_n_out <= not ow_out;

    DUT_inst: temp_controller
    generic map
    (
        CONV_INTERVAL       => 1000000,
        CONV_DELAY_VAL      => 100000,
        RESET_ON_D          => 48000,
        RESET_SAMPLE_D      => 7000,
        RESET_D             => 41000,
        TX_ONE_LOW_D        => 600,
        TX_ONE_HIGH_D       => 6400,
        TX_ZERO_LOW_D       => 6000,
        TX_ZERO_HIGH_D      => 1000,
        RX_SAMPLE_D         => 900,
        RX_RELEASE_D        => 5500,
        PWM_COUNTER_N       => 12,
        MIN_MOD_LVL         => 2**12 / 4,
        ENABLE_ON_D         => 100,
        P_SHIFT_N           => 4,
        I_SHIFT_N           => 11,
        PID_IN_OFFSET       => -320
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_out            => temp,
        temp_out_f          => temp_f,
        conv_out            => conv,
        crc_out             => crc,
        receive_data_out_f  => receive_data_f,
        busy_out            => busy,
        enable_in           => '1'
    );

    data_gen_p: ds18b20_data_gen
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        temp_in             => temp,
        temp_in_f           => temp_f,
        ow_out              => ow_out,
        conv_in             => conv,
        crc_in              => crc,
        receive_data_f_in   => receive_data_f,
        busy_in             => busy,
        test_temp_in        => test_temp,
        test_temp_in_f      => test_temp_f
    );

    temp_gen: process(clk, reset)
        variable cur_temp   : signed(16 - 1 downto 0);
    begin
        if reset = '1' then
            cur_temp := to_signed(320, test_temp'length);
            test_temp <= cur_temp;
            test_temp_f <= '0';
        elsif rising_edge(clk) then
            test_temp_f <= '0';
            if temp_f = '1' then
                cur_temp := cur_temp + 16;
                test_temp <= cur_temp;
                test_temp_f <= '1';
            end if;
        end if;
    end process;

end;
