library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ds18b20_data_gen_pkg is
    component ds18b20_data_gen is
        generic
        (
            MICROSECOND_D       : positive
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            ow_out              : in std_logic;
            temp_in             : in signed(16 - 1 downto 0);
            temp_in_f           : in std_logic;
            ow_in               : out std_logic
        );
    end component;
end package;
