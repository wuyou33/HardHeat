library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package epdm_pkg is
    component epdm is
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            mod_lvl_in          : in unsigned(2 downto 0);
            mod_lvl_in_f        : in std_logic;
            sig_in              : in std_logic;
            sig_lh_out          : out std_logic;
            sig_ll_out          : out std_logic;
            sig_rh_out          : out std_logic;
            sig_rl_out          : out std_logic
        );
    end component;
end package;
