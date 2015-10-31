library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hardheat_pkg is
    component hardheat is
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
    end component;
end package;
