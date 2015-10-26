library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package deadtime_gen_pkg is
    component deadtime_gen is
        generic
        (
            DT_N                : positive;
            DT_VAL              : natural
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            sig_in              : in std_logic;
            sig_out             : out std_logic;
            sig_n_out           : out std_logic
        );
    end component;
end package;
