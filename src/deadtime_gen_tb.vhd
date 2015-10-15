library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.deadtime_gen_pkg.all;
use work.phase_accumulator_pkg.all;

entity deadtime_gen_tb is
    generic
    (
        TUNING_WORD_N       : positive := 22
    );
end entity;

architecture deadtime_gen_tb_arch of deadtime_gen_tb is

    constant CLK_PERIOD     : time := 1 sec / 20e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal sig              : std_logic;
    signal tuning_word      : unsigned(TUNING_WORD_N - 1 downto 0);

begin

    DUT_inst: deadtime_gen
    generic map
    (
        COUNTER_N           => 16,
        DT_VAL              => 100
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        sig_in              => sig
    );

    sig_gen_p: phase_accumulator
    generic map
    (
        ACCUM_BITS_N        => 32,
        TUNING_WORD_N       => TUNING_WORD_N
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        tuning_word_in      => tuning_word,
        sig_out             => sig
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
	    clk <= not clk after CLK_PERIOD / 2;
    end process;

    tuning_word_gen: process(clk)
    begin
        if reset = '1' then
            tuning_word <= to_unsigned(2**TUNING_WORD_N / 2 - 1, TUNING_WORD_N);
        elsif rising_edge(clk) then
            tuning_word <= tuning_word - 1;
        end if;
    end process;

end;
