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
            CONV_D              : natural;
            CONV_CMD_D          : natural;
            OW_US_D             : positive;
            PWM_N               : positive;
            PWM_MIN_LVL         : positive;
            PWM_EN_ON_D         : natural;
            P_SHIFT_N           : natural;
            I_SHIFT_N           : natural;
            PID_IN_OFFSET       : integer
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            ow_in               : in std_logic;
            enable_in           : in std_logic;
            ow_out              : out std_logic;
            temp_out            : out signed(16 - 1 downto 0);
            temp_out_f          : out std_logic;
            temp_error_out      : out std_logic;
            pwm_out             : out std_logic
        );
    end component;
end package;
