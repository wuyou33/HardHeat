library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pwm_pkg is
    component pwm is
        generic
        (
            COUNTER_N               : positive;
            MIN_MOD_LVL             : positive;
            ENABLE_ON_D             : natural
        );
        port
        (
            clk                     : in std_logic;
            reset                   : in std_logic;
            enable_in               : in std_logic;
            mod_lvl_in              : in unsigned(COUNTER_N - 1 downto 0);
            mod_lvl_f_in            : in std_logic;
            pwm_out                 : out std_logic
        );
    end component;
end package;
