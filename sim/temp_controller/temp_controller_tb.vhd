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

    constant MICROSECOND_D  : natural := 100;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal enable           : std_logic;
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
    signal temp             : signed(16 - 1 downto 0);
    signal temp_f           : std_logic;
    signal temp_out_f       : std_logic;
begin

    reset <= '1', '0' after 500 ns;

    enable <= '1';

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    DUT_inst: temp_controller
    generic map
    (
        CONV_D              => 1000000,
        CONV_CMD_D          => 100000,
        OW_US_D             => MICROSECOND_D,
        PWM_N               => 12,
        PWM_MIN_LVL         => 2**12 / 4,
        PWM_EN_ON_D         => 100,
        P_SHIFT_N           => 4,
        I_SHIFT_N           => -11,
        TEMP_SETPOINT       => 320
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        ow_out              => ow_out,
        enable_in           => '1',
        temp_out_f          => temp_out_f
    );

    data_gen_p: ds18b20_data_gen
    generic map
    (
        MICROSECOND_D       => MICROSECOND_D
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        temp_in             => temp,
        temp_in_f           => temp_f,
        ow_out              => ow_out
    );

    temp_gen: process(clk, reset)
        variable cur_temp   : signed(16 - 1 downto 0);
    begin
        if reset = '1' then
            cur_temp := to_signed(320, temp'length);
            temp <= cur_temp;
            temp_f <= '0';
        elsif rising_edge(clk) then
            temp_f <= '0';
            if temp_out_f = '1' then
                cur_temp := cur_temp + 16;
                temp <= cur_temp;
                temp_f <= '1';
            end if;
        end if;
    end process;

end;
