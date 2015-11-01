library ieee;
use ieee.std_logic_1164.all;

package pwr_sequencer_pkg is

    type status_t is array (natural range <>) of std_logic_vector(2 downto 0);

    component pwr_sequencer is
        generic
        (
            LEVELS_N            : positive
        );
        port
        (
            clk                 : in std_logic;
            reset               : in std_logic;
            start_in            : in std_logic;
            fail_in             : in std_logic_vector(LEVELS_N - 1 downto 0);
            en_out              : out std_logic_vector(LEVELS_N - 1 downto 0);
            status_out          : out status_t(LEVELS_N - 1 downto 0);
            main_pwr_en_out     : out std_logic;
            main_pwr_fail_out   : out std_logic
        );
    end component;
end package;
