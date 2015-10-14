library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.filter_pkg.all;

entity filter_tb is
end entity;

architecture filter_tb_arch of filter_tb is

    -- Run the filter at 50 kHz
    constant CLK_PERIOD         : time := 1 sec / 50e3;

    signal clk                  : std_logic := '0';
    signal reset                : std_logic;
    signal filt_in              : std_logic;
    signal run_filter_f         : std_logic;

begin

    DUT_inst: filter
    generic map
    (
        ALPHA_SHIFT_N       => 11,
        BETA_SHIFT_N        => 3,
        IN_N                => 11,
        OUT_N               => 22,
        INIT_OUT_VAL        => 2**22 / 2 - 1
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        filt_in             => to_signed(2**9, 12)
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

end;
