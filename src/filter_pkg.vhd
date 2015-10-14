library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package filter_pkg is
    component filter is
        generic
        (
            ALPHA_SHIFT_N       : natural;
            BETA_SHIFT_N        : natural;
            IN_N                : positive;
            OUT_N               : positive;
            INIT_OUT_VAL        : positive
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            filt_in             : in signed(IN_N downto 0);
            filt_out            : out unsigned(OUT_N - 1 downto 0)
        );
    end component;
end package;
