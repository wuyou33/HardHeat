library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hardheat_pkg is
    component hardheat is
        generic
        (
            COUNTER_N           : positive;
            P_SHIFT_N           : natural;
            I_SHIFT_N           : natural;
            OUT_OFFSET          : natural;
            OUT_VAL_LIMIT       : positive;
            ACCUM_BITS_N        : positive;
            TUNING_WORD_N       : positive;
            INIT_OUT_VAL        : positive;
            DT_COUNTER_N        : positive;
            DT_VAL              : natural;
            LOCK_COUNT_N        : positive;
            ULOCK_COUNT_N       : positive;
            LOCK_LIMIT          : natural;
            CONV_INTERVAL       : natural;
            CONV_DELAY_VAL      : natural;
            RESET_ON_D          : positive;
            RESET_SAMPLE_D      : positive;
            RESET_D             : positive;
            TX_ONE_LOW_D        : positive;
            TX_ONE_HIGH_D       : positive;
            TX_ZERO_LOW_D       : positive;
            TX_ZERO_HIGH_D      : positive;
            RX_SAMPLE_D         : positive;
            RX_RELEASE_D        : positive;
            PWM_COUNTER_N       : positive;
            MIN_MOD_LVL         : natural;
            ENABLE_ON_D         : natural;
            TEMP_P_SHIFT_N      : natural;
            TEMP_I_SHIFT_N      : natural;
            PID_IN_OFFSET       : integer
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
            temp_error_out      : out std_logic;
            pwm_out             : out std_logic
        );
    end component;
end package;
