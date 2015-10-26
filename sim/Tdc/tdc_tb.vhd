library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_pkg.all;

entity tdc_tb is
end entity;

architecture tdc_tb_arch of tdc_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD         : time := 1 sec / 10e7;
    -- Up signal frequency 40 kHz
    constant UP_PERIOD          : time := 1 sec / 40e3;
    -- Down signal frequency 50 kHz
    constant DOWN_PERIOD        : time := 1 sec / 50e3;

    signal clk                  : std_logic := '0';
    signal reset                : std_logic;
    signal up                   : std_logic := '0';
    signal down                 : std_logic := '0';

begin

    DUT_inst: tdc
    generic map
    (
        COUNTER_N       => 12
    )
    port map
    (
        clk             => clk,
        reset           => reset,
        up_in           => up,
        down_in         => down
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    up_gen: process(up)
    begin
        up <= not up after UP_PERIOD / 2;
    end process;

    down_gen: process(down)
    begin
        down <= not down after DOWN_PERIOD / 2;
    end process;

end;
