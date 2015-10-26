library ieee;
use ieee.std_logic_1164.all;

package adpll_pkg is
    component adpll is
        generic
        (
            TDC_N               : positive;
            FILT_P_SHIFT_N      : natural;
            FILT_I_SHIFT_N      : natural;
            FILT_INIT_OUT_VAL   : positive;
            FILT_OUT_OFFSET     : natural;
            FILT_OUT_VAL_LIMIT  : positive;
            ACCUM_BITS_N        : positive;
            ACCUM_WORD_N        : positive;
            LD_LOCK_N           : positive;
            LD_ULOCK_N          : positive;
            LD_LOCK_LIMIT       : natural
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
