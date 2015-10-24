library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package one_wire_pkg is
    component one_wire is
        generic
        (
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
