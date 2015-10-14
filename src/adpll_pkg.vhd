library ieee;
use ieee.std_logic_1164.all;

package adpll_pkg is
    component adpll is
        generic
        (
            COUNTER_N       : positive;
            ALPHA_SHIFT_N   : natural;
            BETA_SHIFT_N    : natural;
            ACCUM_BITS_N    : positive;
            TUNING_WORD_N   : positive;
            INIT_OUT_VAL    : positive
        );
        port
        (
            clk             : in std_logic;
            reset           : in std_logic;
            ref_in          : in std_logic;
            sig_out         : out std_logic
        );
    end component;
end package;
