library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lock_detector_pkg.all;

entity lock_detector_tb is
end entity;

architecture lock_detector_tb_arch of lock_detector_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;

begin

    DUT_inst: lock_detector
    generic map
    (
        PHASE_TIME_IN_N     => 12,
        LOCK_COUNT_N        => 8,
        ULOCK_COUNT_N       => 8,
        LOCK_LIMIT          => 100
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        phase_time_in       => to_signed(0, 13)
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

end;
