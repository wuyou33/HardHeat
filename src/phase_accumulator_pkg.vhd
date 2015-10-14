library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package phase_accumulator_pkg is
    component phase_accumulator is
        generic
        (
            ACCUM_BITS_N    : positive;
            TUNING_WORD_N   : positive
        );
        port
        (
            clk             : in std_logic;
            reset           : in std_logic;
            tuning_word_in  : in unsigned(TUNING_WORD_N - 1 downto 0);
            sig_out         : out std_logic
        );
    end component;
end package;
