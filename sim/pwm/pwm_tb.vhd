library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_tb is
end entity;

architecture rtl of pwm_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal enable           : std_logic;
    signal mod_lvl          : unsigned(12 - 1 downto 0);
    signal mod_lvl_f        : std_logic;

begin

    reset <= '1', '0' after 500 ns;

    enable <= '1';

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    DUT_inst: entity work.pwm(rtl)
    generic map
    (
        COUNTER_N           => 12,
        MIN_MOD_LVL         => 2**12 / 5,
        ENABLE_ON_D         => 100
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        enable_in           => enable,
        mod_lvl_in          => mod_lvl,
        mod_lvl_f_in        => mod_lvl_f
    );

    mod_lvl_gen: process(clk)
        variable timer      : unsigned(12 - 1 downto 0);
    begin
        if reset = '1' then
            timer := (others => '0');
            mod_lvl <= to_unsigned(2**12 / 2, mod_lvl'length);
            mod_lvl_f <= '0';
        elsif rising_edge(clk) then
            mod_lvl_f <= '0';
            if timer = 2**12 - 1 then
                mod_lvl <= mod_lvl - 1;
                mod_lvl_f <= '1';
            end if;
            timer := timer + 1;
        end if;
    end process;

end;
