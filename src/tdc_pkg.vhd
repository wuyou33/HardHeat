library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tdc_pkg is
    component tdc is
        generic
        (
            COUNTER_N       : positive
        );
        port
        (
            clk             : in std_logic;
            reset           : in std_logic;
            up_in           : in std_logic;
            down_in         : in std_logic;
            time_out        : out signed(COUNTER_N - 1 downto 0);
            sig_or_out      : out std_logic;
            sign_out        : out std_logic
        );
    end component;
end package;
