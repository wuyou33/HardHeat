library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adpll_tb is
end entity;

architecture rtl of adpll_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD         : time := 1 sec / 10e7;
    -- Reference signal frequency 50 kHz
    constant REF_PERIOD         : time := 1 sec / 90e3;

    signal clk                  : std_logic := '0';
    signal reset                : std_logic;
    signal ref                  : std_logic := '0';

begin

    DUT_inst: entity work.adpll(rtl)
    generic map
    (
        TDC_N                   => 13,
        FILT_P_SHIFT_N          => 0,
        FILT_I_SHIFT_N          => -5,
        ACCUM_BITS_N            => 32,
        ACCUM_WORD_N            => 23,
        FILT_INIT_OUT_VAL       => 2**11,
        FILT_OUT_OFFSET         => 2**21,
        FILT_OUT_LIMIT          => 2**22,
        LD_LOCK_N               => 20,
        LD_ULOCK_N              => 16,
        LD_LOCK_LIMIT           => 100
    )
    port map
    (
        clk                     => clk,
        reset                   => reset,
        ref_in                  => ref
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    ref_gen: process(ref)
    begin
        ref <= not ref after REF_PERIOD / 2;
    end process;

end;
