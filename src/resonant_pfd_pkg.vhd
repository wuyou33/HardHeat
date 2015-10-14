library ieee;
use ieee.std_logic_1164.all;

package resonant_pfd_pkg is
    component resonant_pfd is
        port
        (
            -- Inputs
            clk             : in std_logic;
            reset           : in std_logic;
            sig_in          : in std_logic;
            ref_in          : in std_logic;
            -- Outputs
            up_out          : out std_logic;
            down_out        : out std_logic
        );
    end component;
end package;
