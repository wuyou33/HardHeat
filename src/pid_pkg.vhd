library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pid_pkg is
    component pid is
        generic
        (
            P_SHIFT_N           : natural;
            I_SHIFT_N           : natural;
            IN_N                : positive;
            OUT_N               : positive;
            INIT_OUT_VAL        : positive;
            OUT_OFFSET          : natural;
            OUT_VAL_LIMIT       : positive
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            pid_in              : in signed(IN_N downto 0);
            pid_out             : out unsigned(OUT_N - 1 downto 0)
        );
    end component;
end package;
