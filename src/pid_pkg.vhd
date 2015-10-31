library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pid_pkg is
    component pid is
        generic
        (
            P_SHIFT_N           : integer;
            I_SHIFT_N           : integer;
            BITS_N              : positive;
            INIT_OUT_VAL        : natural
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            upd_clk_in          : in std_logic;
            setpoint_in         : in signed(BITS_N - 1 downto 0);
            pid_in              : in signed(BITS_N - 1 downto 0);
            pid_out             : out signed(BITS_N - 1 downto 0)
        );
    end component;
end package;
