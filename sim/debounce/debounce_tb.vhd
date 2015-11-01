library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.debounce_pkg.all;

entity debounce_tb is
end entity;

architecture debounce_tb_arch of debounce_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal sig              : std_logic;
begin

    reset <= '1', '0' after 500 ns;

    sig <= '1';

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    DUT_inst: debounce
    generic map
    (
        DEBOUNCE_D          => 1000,
        FLIPFLOPS_N         => 5
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        sig_in              => sig
    );

end;
