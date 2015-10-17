library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.adpll_pkg.all;
use work.epdm_pkg.all;
use work.deadtime_gen_pkg.all;

entity hardheat is
    generic
    (
        COUNTER_N           : positive;
        ALPHA_SHIFT_N       : natural;
        BETA_SHIFT_N        : natural;
        ACCUM_BITS_N        : positive;
        TUNING_WORD_N       : positive;
        INIT_OUT_VAL        : positive;
        -- Number of bits in the deadtime counter
        DT_COUNTER_N        : positive;
        -- Amount of deadtime
        DT_VAL              : natural
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        ref_in              : in std_logic;
        sig_in              : in std_logic;
        mod_lvl_in          : in unsigned(2 downto 0);
        mod_lvl_in_f        : in std_logic;
        sig_out             : out std_logic;
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic
    );
end entity;

architecture hardheat_arch of hardheat is
    signal sig              : std_logic;
    signal deadtime         : std_logic;
    signal deadtime_n       : std_logic;
    signal sig_lh           : std_logic;
    signal sig_ll           : std_logic;
    signal sig_rh           : std_logic;
    signal sig_rl           : std_logic;
begin

    adpll_p: adpll
    generic map
    (
        COUNTER_N           => COUNTER_N,
        ALPHA_SHIFT_N       => ALPHA_SHIFT_N,
        BETA_SHIFT_N        => BETA_SHIFT_N,
        ACCUM_BITS_N        => ACCUM_BITS_N,
        TUNING_WORD_N       => TUNING_WORD_N,
        INIT_OUT_VAL        => INIT_OUT_VAL
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref_in,
        sig_out             => sig
    );

    epdm_p: epdm
    port map
    (
        clk                 => clk,
        reset               => reset,
        mod_lvl_in          => mod_lvl_in,
        mod_lvl_in_f        => mod_lvl_in_f,
        sig_in              => sig,
        sig_lh_out          => sig_lh,
        sig_ll_out          => sig_ll,
        sig_rh_out          => sig_rh,
        sig_rl_out          => sig_rl
    );

    deadtime_gen_p: deadtime_gen
    generic map
    (
        COUNTER_N           => DT_COUNTER_N,
        DT_VAL              => DT_VAL
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        sig_in              => sig,
        sig_out             => deadtime,
        sig_n_out           => deadtime_n
    );

    sig_lh_out <= sig_lh and not deadtime;
    sig_ll_out <= sig_ll and not deadtime_n;
    sig_rh_out <= sig_rh and not deadtime_n;
    sig_rl_out <= sig_rl and not deadtime;

    sig_out <= sig;

end;
