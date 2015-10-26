library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package one_wire_pkg is
    component one_wire is
        generic
        (
            US_D                : positive
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            reset_ow            : in std_logic;
            ow_in               : in std_logic;
            data_in             : in std_logic_vector(8 - 1 downto 0);
            data_in_f           : in std_logic;
            receive_data_f      : in std_logic;
            crc_out             : out std_logic_vector(8 - 1 downto 0);
            data_out            : out std_logic_vector(8 - 1 downto 0);
            data_out_f          : out std_logic;
            ow_out              : out std_logic;
            busy_out            : out std_logic;
            error_out           : out std_logic;
            error_id_out        : out unsigned(1 downto 0)
        );
    end component;
end package;
