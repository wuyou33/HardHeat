library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hardheat_pkg is
    component hardheat is
        generic
        (
            COUNTER_N           : positive;
            ALPHA_SHIFT_N       : natural;
            BETA_SHIFT_N        : natural;
            ACCUM_BITS_N        : positive;
            TUNING_WORD_N       : positive;
            INIT_OUT_VAL        : positive;
            DT_COUNTER_N        : positive;
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
    end component;
end package;
