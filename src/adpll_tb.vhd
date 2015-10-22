library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.adpll_pkg.all;

entity adpll_tb is
end entity;

architecture adpll_tb_arch of adpll_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD         : time := 1 sec / 10e7;
    -- Reference signal frequency 45 kHz
    constant REF_PERIOD         : time := 1 sec / 45e3;

    signal clk                  : std_logic := '0';
    signal reset                : std_logic;
    signal ref                  : std_logic := '0';

begin

    DUT_inst: adpll
    generic map
    (
        COUNTER_N               => 12,
        P_SHIFT_N               => 7,
        I_SHIFT_N               => 0,
        ACCUM_BITS_N            => 32,
        TUNING_WORD_N           => 23,
        INIT_OUT_VAL            => (2**22 - 1) / 4,
        OUT_OFFSET              => 2**21,
        OUT_VAL_LIMIT           => 2547483,
        LOCK_COUNT_N            => 20,
        ULOCK_COUNT_N           => 16,
        LOCK_LIMIT              => 100
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
