library ieee;
use ieee.std_logic_1164.all;

package altera_pll_top_pkg is
	component altera_pll_top is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component altera_pll_top;
end package;
