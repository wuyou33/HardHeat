library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity resonant_pfd_tb is
end entity;

architecture rtl of resonant_pfd_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD         : time := 1 sec / 10e7;
    -- Reference signal frequency 40 kHz
    constant REF_PERIOD         : time := 1 sec / 40e3;
    -- Output signal frequency 50 kHz
    constant SIG_PERIOD         : time := 1 sec / 50e3;

    signal clk                  : std_logic := '0';
    signal reset                : std_logic;
    signal ref                  : std_logic := '0';
    signal sig                  : std_logic := '0';

begin

    DUT_inst: entity work.resonant_pfd(rtl)
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref,
        sig_in              => sig
    );

    reset <= '1' , '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    ref_gen: process(ref)
    begin
        ref <= not ref after REF_PERIOD / 2;
    end process;

    sig_gen: process(sig)
    begin
        sig <= not sig after SIG_PERIOD / 2;
    end process;

end;
