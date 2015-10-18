library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.resonant_pfd_pkg.all;
use work.tdc_pkg.all;
use work.pid_sim_pkg.all;
use work.phase_accumulator_pkg.all;

entity adpll is
    generic
    (
        COUNTER_N       : positive;
        P_SHIFT_N       : natural;
        I_SHIFT_N       : natural;
        ACCUM_BITS_N    : positive;
        TUNING_WORD_N   : positive;
        INIT_OUT_VAL    : positive;
        OUT_OFFSET      : natural;
        OUT_VAL_LIMIT   : positive
    );
    port
    (
        clk             : in std_logic;
        reset           : in std_logic;
        ref_in          : in std_logic;
        sig_out         : out std_logic
    );
end entity;

architecture adpll_arch of adpll is
    signal up           : std_logic;
    signal down         : std_logic;
    signal phase_time   : signed(COUNTER_N downto 0);
    signal tuning_word  : unsigned(TUNING_WORD_N - 1 downto 0);
    signal sig          : std_logic;
begin

    sig_out             <= sig;

    pfd_p: resonant_pfd
    port map
    (
        clk             => clk,
        reset           => reset,
        sig_in          => sig,
        ref_in          => ref_in,
        up_out          => up,
        down_out        => down
    );

    tdc_p: tdc
    generic map
    (
        COUNTER_N       => COUNTER_N
    )
    port map
    (
        clk             => clk,
        reset           => reset,
        up_in           => up,
        down_in         => down,
        time_out        => phase_time
    );

    filter_p: pid_sim
    generic map
    (
        P_SHIFT_N       => P_SHIFT_N,
        I_SHIFT_N       => I_SHIFT_N,
        IN_N            => COUNTER_N,
        OUT_N           => TUNING_WORD_N,
        INIT_OUT_VAL    => INIT_OUT_VAL,
        OUT_OFFSET      => OUT_OFFSET,
        OUT_VAL_LIMIT   => OUT_VAL_LIMIT
    )
    port map
    (
        clk             => ref_in,
        reset           => reset,
        pid_in          => phase_time,
        pid_out         => tuning_word
    );

    phase_accumulator_p: phase_accumulator
    generic map
    (
        ACCUM_BITS_N    => ACCUM_BITS_N,
        TUNING_WORD_N   => TUNING_WORD_N
    )
    port map
    (
        clk             => clk,
        reset           => reset,
        tuning_word_in  => tuning_word,
        sig_out         => sig
    );

end;
