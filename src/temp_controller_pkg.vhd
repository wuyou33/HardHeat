library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.one_wire_pkg.all;
use work.ds18b20_pkg.all;

package temp_controller_pkg is
    component temp_controller is
        generic
        (
            CONV_INTERVAL       : natural;
            CONV_DELAY_VAL      : natural;
            RESET_ON_D          : positive;
            RESET_SAMPLE_D      : positive;
            RESET_D             : positive;
            TX_ONE_LOW_D        : positive;
            TX_ONE_HIGH_D       : positive;
            TX_ZERO_LOW_D       : positive;
            TX_ZERO_HIGH_D      : positive;
            RX_SAMPLE_D         : positive;
            RX_RELEASE_D        : positive
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            ow_in               : in std_logic;
            ow_out              : out std_logic;
            temp_out            : out signed(16 - 1 downto 0);
            temp_out_f          : out std_logic;
            temp_error_out      : out std_logic
        );
    end component;
end package;
