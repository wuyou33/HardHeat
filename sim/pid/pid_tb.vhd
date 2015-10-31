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
        P_SHIFT_N           => 4,
        I_SHIFT_N           => 2,
        BITS_N              => 16,
        INIT_OUT_VAL        => 0
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        upd_clk_in          => upd,
        setpoint_in         => to_signed(0, 16),
        pid_in              => to_signed(100, 16)
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
