library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package rpm_counter_pkg is
    component rpm_counter is
        generic
        (
            BITS_N                  : positive;
            MIN_RPM_LIM             : natural;
            DEBOUNCE_D              : natural
        );
        port
        (
            clk                     : in std_logic;
            reset                   : in std_logic;
            rpm_in                  : in std_logic;
            rpm_out                 : out unsigned(BITS_N - 1 downto 0);
            rpm_out_f               : out std_logic;
            fault_out               : out std_logic
        );
    end component;
end package;
