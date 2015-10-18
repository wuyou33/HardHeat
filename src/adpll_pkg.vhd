library ieee;
use ieee.std_logic_1164.all;

package adpll_pkg is
    component adpll is
        generic
        (
            COUNTER_N       : positive;
            P_SHIFT_N       : natural;
            I_SHIFT_N       : natural;
            ACCUM_BITS_N    : positive;
            TUNING_WORD_N   : positive;
            INIT_OUT_VAL    : positive;
            OUT_OFFSET      : natural;
            OUT_VAL_LIMIT   : positive;
            LOCK_COUNT_N    : positive;
            ULOCK_COUNT_N   : positive;
            LOCK_LIMIT      : natural
        );
        port
        (
            clk             : in std_logic;
            reset           : in std_logic;
            ref_in          : in std_logic;
            sig_out         : out std_logic;
            lock_out        : out std_logic
        );
    end component;
end package;
