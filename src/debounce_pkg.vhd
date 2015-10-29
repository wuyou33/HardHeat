library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package debounce_pkg is
    component debounce is
        generic
        (
            DEBOUNCE_D			: natural;
            FLIPFLOPS_N         : positive
        );
        port
        (
            clk					: in std_logic;
            reset               : in std_logic;
            sig_in				: in std_logic;
            sig_out				: out std_logic
        );
    end component;
end package;
