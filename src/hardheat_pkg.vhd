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
            ACCUM_BITS_N        : positive;
            TUNING_WORD_N       : positive;
            INIT_OUT_VAL        : positive;
            DT_COUNTER_N        : positive;
            DT_VAL              : natural;
            OUT_OFFSET          : natural;
            OUT_VAL_LIMIT       : positive;
            -- Number of bits in the lock counter
            LOCK_COUNT_N        : positive;
            -- Number of bits in the unlock counter
            ULOCK_COUNT_N       : positive;
            -- Value under which the phase is considered to be locked
            LOCK_LIMIT          : natural
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
            sig_rl_out          : out std_logic;
            lock_out            : out std_logic
        );
    end component;
end package;
