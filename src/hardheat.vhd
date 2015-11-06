library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity hardheat is
    generic
    (
        TDC_N               : positive;
        FILT_P_SHIFT_N      : integer;
        FILT_I_SHIFT_N      : integer;
        FILT_INIT_OUT_VAL   : positive;
        FILT_OUT_OFFSET     : natural;
        FILT_OUT_LIM        : positive;
        ACCUM_BITS_N        : positive;
        ACCUM_WORD_N        : positive;
        DT_N                : positive;
        DT_VAL              : natural;
        LD_LOCK_N           : positive;
        LD_ULOCK_N          : positive;
        LD_LOCK_LIMIT       : natural;
        TEMP_CONV_D         : natural;
        TEMP_CONV_CMD_D     : natural;
        TEMP_OW_US_D        : positive;
        TEMP_PWM_N          : positive;
        TEMP_PWM_MIN_LVL    : natural;
        TEMP_PWM_EN_ON_D    : natural;
        TEMP_P_SHIFT_N      : integer;
        TEMP_I_SHIFT_N      : integer;
        TEMP_SETPOINT       : integer
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
        ow_pullup_out       : out std_logic;
        sig_out             : out std_logic;
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic;
        lock_out            : out std_logic;
        temp_out            : out signed(16 - 1 downto 0);
        temp_out_f          : out std_logic;
        temp_err_out        : out std_logic;
        pwm_out             : out std_logic
    );
end entity;

architecture rtl of hardheat is

    signal sig              : std_logic;
    signal deadtime         : std_logic;
    signal deadtime_n       : std_logic;
    signal sig_lh           : std_logic;
    signal sig_ll           : std_logic;
    signal sig_rh           : std_logic;
    signal sig_rl           : std_logic;

begin

    adpll_p: entity work.adpll(rtl)
    generic map
    (
        TDC_N               => TDC_N,
        FILT_P_SHIFT_N      => FILT_P_SHIFT_N,
        FILT_I_SHIFT_N      => FILT_I_SHIFT_N,
        FILT_INIT_OUT_VAL   => FILT_INIT_OUT_VAL,
        FILT_OUT_OFFSET     => FILT_OUT_OFFSET,
        FILT_OUT_LIMIT      => FILT_OUT_LIM,
        ACCUM_BITS_N        => ACCUM_BITS_N,
        ACCUM_WORD_N        => ACCUM_WORD_N,
        LD_LOCK_N           => LD_LOCK_N,
        LD_ULOCK_N          => LD_ULOCK_N,
        LD_LOCK_LIMIT       => LD_LOCK_LIMIT
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref_in,
        sig_out             => sig,
        lock_out            => lock_out
    );

    epdm_p: entity work.epdm(rtl)
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

    deadtime_gen_p: entity work.deadtime_gen(rtl)
    generic map
    (
        DT_N                => DT_N,
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

    temp_controller_p: entity work.temp_controller(rtl)
    generic map
    (
        CONV_D              => TEMP_CONV_D,
        CONV_CMD_D          => TEMP_CONV_CMD_D,
        OW_US_D             => TEMP_OW_US_D,
        PWM_N               => TEMP_PWM_N,
        PWM_MIN_LVL         => TEMP_PWM_MIN_LVL,
        PWM_EN_ON_D         => TEMP_PWM_EN_ON_D,
        P_SHIFT_N           => TEMP_P_SHIFT_N,
        I_SHIFT_N           => TEMP_I_SHIFT_N,
        TEMP_SETPOINT       => TEMP_SETPOINT
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_out            => temp_out,
        temp_out_f          => temp_out_f,
        pwm_out             => pwm_out,
        enable_in           => '1',
        temp_error_out      => temp_err_out,
        ow_pullup_out       => ow_pullup_out
    );

    sig_lh_out <= sig_lh and not deadtime;
    sig_ll_out <= sig_ll and not deadtime_n;
    sig_rh_out <= sig_rh and not deadtime_n;
    sig_rl_out <= sig_rl and not deadtime;

    sig_out <= sig;

end;
