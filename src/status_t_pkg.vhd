library ieee;
use ieee.std_logic_1164.all;

package status_t_pkg is

    type status_t is array (natural range <>) of std_logic_vector(2 downto 0);

end package;
