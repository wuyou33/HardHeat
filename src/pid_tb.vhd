library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pid_pkg.all;

entity pid_tb is
end entity;

architecture pid_tb_arch of pid_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD         : time := 1 sec / 10e7;
    -- Run the filter at 50 kHz
    constant UPD_PERIOD         : time := 1 sec / 50e3;

    signal clk                  : std_logic := '0';
    signal upd                  : std_logic := '0';
    signal reset                : std_logic;
    signal filt_in              : std_logic;

begin

    DUT_inst: pid
    generic map
    (
        P_SHIFT_N           => 11,
        I_SHIFT_N           => 3,
        IN_N                => 11,
        OUT_N               => 22,
        INIT_OUT_VAL        => 2**22 / 2 - 1,
        IN_OFFSET           => 0,
        OUT_OFFSET          => 0,
        OUT_VAL_LIMIT       => 2**22 - 1
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        upd_clk_in          => upd,
        pid_in              => to_signed(2**10, 12)
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    upd_gen: process(upd)
    begin
        upd <= not upd after UPD_PERIOD / 2;
    end process;

end;
