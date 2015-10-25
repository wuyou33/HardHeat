library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.adpll_pkg.all;
use work.epdm_pkg.all;
use work.deadtime_gen_pkg.all;
use work.temp_controller_pkg.all;
use work.utils_pkg.all;

entity hardheat is
    generic
    (
        -- Number of bits in the time-to-digital counter
        COUNTER_N           : positive;
        -- Filter number of bitshifts (left) for proportional path
        P_SHIFT_N           : natural;
        -- Filter number of bitshifts (right) for integral path
        I_SHIFT_N           : natural;
        -- Filter output offset and clamping value
        OUT_OFFSET          : natural;
        OUT_VAL_LIMIT       : positive;
        -- Phase accumulator
        ACCUM_BITS_N        : positive;
        TUNING_WORD_N       : positive;
        INIT_OUT_VAL        : positive;
        -- Number of bits in the deadtime counter
        DT_COUNTER_N        : positive;
        -- Amount of deadtime
        DT_VAL              : natural;
        -- Number of bits in the lock counter
        LOCK_COUNT_N        : positive;
        -- Number of bits in the unlock counter
        ULOCK_COUNT_N       : positive;
        -- Value under which the phase is considered to be locked
        LOCK_LIMIT          : natural;
        -- Interval how often to measure temperature
        CONV_INTERVAL       : natural;
        -- Conversion delay for the sensor
        CONV_DELAY_VAL      : natural;
        -- 1-wire bus delays
        RESET_ON_D          : positive;
        RESET_SAMPLE_D      : positive;
        RESET_D             : positive;
        TX_ONE_LOW_D        : positive;
        TX_ONE_HIGH_D       : positive;
        TX_ZERO_LOW_D       : positive;
        TX_ZERO_HIGH_D      : positive;
        RX_SAMPLE_D         : positive;
        RX_RELEASE_D        : positive
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        ref_in              : in std_logic;
        sig_in              : in std_logic;
        mod_lvl_in          : in unsigned(2 downto 0);
        mod_lvl_in_f        : in std_logic;
        ow_in               : in std_logic;
        ow_out              : out std_logic;
        sig_out             : out std_logic;
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic;
        lock_out            : out std_logic;
        temp_out            : out signed(16 - 1 downto 0);
        temp_out_f          : out std_logic;
        temp_error_out      : out std_logic
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
        P_SHIFT_N           => P_SHIFT_N,
        I_SHIFT_N           => I_SHIFT_N,
        ACCUM_BITS_N        => ACCUM_BITS_N,
        TUNING_WORD_N       => TUNING_WORD_N,
        INIT_OUT_VAL        => INIT_OUT_VAL,
        OUT_OFFSET          => OUT_OFFSET,
        OUT_VAL_LIMIT       => OUT_VAL_LIMIT,
        LOCK_COUNT_N        => LOCK_COUNT_N,
        ULOCK_COUNT_N       => ULOCK_COUNT_N,
        LOCK_LIMIT          => LOCK_LIMIT
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref_in,
        sig_out             => sig,
        lock_out            => lock_out
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

    temp_controller_p: temp_controller
    generic map
    (
        CONV_INTERVAL       => CONV_INTERVAL,
        CONV_DELAY_VAL      => CONV_DELAY_VAL,
        RESET_ON_D          => RESET_ON_D,
        RESET_SAMPLE_D      => RESET_SAMPLE_D,
        RESET_D             => RESET_D,
        TX_ONE_LOW_D        => TX_ONE_LOW_D,
        TX_ONE_HIGH_D       => TX_ONE_HIGH_D,
        TX_ZERO_LOW_D       => TX_ZERO_LOW_D,
        TX_ZERO_HIGH_D      => TX_ZERO_HIGH_D,
        RX_SAMPLE_D         => RX_SAMPLE_D,
        RX_RELEASE_D        => RX_RELEASE_D
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_out            => temp_out,
        temp_out_f          => temp_out_f,
        temp_error_out      => temp_error_out
    );

    sig_lh_out <= sig_lh and not deadtime;
    sig_ll_out <= sig_ll and not deadtime_n;
    sig_rh_out <= sig_rh and not deadtime_n;
    sig_rl_out <= sig_rl and not deadtime;

    sig_out <= sig;

end;
