library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phase_accumulator is
    generic
    (
        -- Number of bits in the accumulator
        ACCUM_BITS_N    : positive;
        -- Number of bits in the tuning word (unsigned)
        TUNING_WORD_N   : positive
    );
    port
    (
        clk             : in std_logic;
        reset           : in std_logic;
        tuning_word_in  : in unsigned(TUNING_WORD_N - 1 downto 0);
        sig_out         : out std_logic
    );
end entity;

architecture phase_accumulator_arch of phase_accumulator is
    signal accumulator  : unsigned (ACCUM_BITS_N - 1 downto 0);
    signal out_state    : std_logic;
begin

    accumulate: process(clk, reset)
    begin
        if reset = '1' then
            accumulator <= to_unsigned(0, ACCUM_BITS_N);
            out_state <= '0';
            sig_out <= '0';
        elsif rising_edge(clk) then
            accumulator <= accumulator + tuning_word_in;
            sig_out <= accumulator(accumulator'high);
        end if;
    end process;

end;
