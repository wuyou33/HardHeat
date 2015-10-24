library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ds18b20_pkg is

    constant DS18B20_ROM_CMD        : std_logic_vector(8 - 1 downto 0) := x"CC";
    constant DS18B20_CONV_CMD       : std_logic_vector(8 - 1 downto 0) := x"44";
    constant DS18B20_READ_CMD       : std_logic_vector(8 - 1 downto 0) := x"BE";

    component ds18b20 is
        generic
        (
            CONV_DELAY_VAL          : natural
        );
        port
        (
            clk                     : in std_logic;
            reset                   : in std_logic;
            -- Request temperature
            conv_in_f               : in std_logic;
            -- Connections to 1-wire module
            data_in                 : in std_logic_vector(8 - 1 downto 0);
            data_in_f               : in std_logic;
            busy_in                 : in std_logic;
            error_in                : in std_logic;
            error_id_in             : in unsigned(1 downto 0);
            crc_in                  : in std_logic_vector(8 - 1 downto 0);
            reset_ow_out            : out std_logic;
            data_out                : out std_logic_vector(8 - 1 downto 0);
            data_out_f              : out std_logic;
            receive_data_out_f      : out std_logic;
            -- Temperature output and associated strobe
            temp_out                : out signed(16 - 1 downto 0);
            temp_out_f              : out std_logic;
            temp_error_out          : out std_logic
        );
    end component;
end package;
