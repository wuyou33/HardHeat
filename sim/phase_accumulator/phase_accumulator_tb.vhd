library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phase_accumulator_tb is
    generic
    (
        ACCUM_BITS_N        : positive := 32;
        TUNING_WORD_N       : positive := 22
    );
end entity;

architecture rtl of phase_accumulator_tb is

    -- Clock frequency is 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e8;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal tuning_word_in   : unsigned(TUNING_WORD_N - 1 downto 0);
    signal sig_out          : std_logic;

begin

    DUT_inst: entity work.phase_accumulator(rtl)
    generic map
    (
        ACCUM_BITS_N    => ACCUM_BITS_N,
        TUNING_WORD_N   => TUNING_WORD_N
    )
    port map
    (
        clk             => clk,
        reset           => reset,
        tuning_word_in  => tuning_word_in,
        sig_out         => sig_out
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    tuning_word_gen: process(clk)
    begin
        if reset = '1' then
            tuning_word_in <= to_unsigned(2**TUNING_WORD_N - 1, TUNING_WORD_N);
        elsif rising_edge(clk) then
            tuning_word_in <= tuning_word_in - 1;
        end if;
    end process;

end;
