library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use work.deadtime_gen_pkg.all;
use work.epdm_pkg.all;
use work.phase_accumulator_pkg.all;

entity epdm_tb is
    generic
    (
        TUNING_WORD_N       : positive := 22
    );
end entity;

architecture epdm_tb_arch of epdm_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 20e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal sig              : std_logic;
    signal mod_lvl          : unsigned(2 downto 0);
    signal mod_lvl_f        : std_logic;

begin

    DUT_inst: epdm
    port map
    (
        clk                 => clk,
        reset               => reset,
        mod_lvl_in          => mod_lvl,
        mod_lvl_in_f        => mod_lvl_f,
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
        tuning_word_in      => to_unsigned(2**TUNING_WORD_N / 2 - 1,
            TUNING_WORD_N),
        sig_out             => sig
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    mod_lvl_gen: process(clk, reset)
        variable mod_lvl_v      : unsigned(2 downto 0);
        variable cycle_count    : unsigned(3 downto 0);
        variable last_state     : std_logic;
    begin
        if reset = '1' then
            mod_lvl_v := to_unsigned(4, mod_lvl_v'length);
            mod_lvl <= mod_lvl_v;
            cycle_count := (others => '0');
            last_state := sig;
            mod_lvl_f <= '0';
        elsif rising_edge(clk) then
            if mod_lvl_f = '1' then
                mod_lvl_f <= '0';
            end if;
            if not sig = last_state and sig = '1' then
                cycle_count := cycle_count + 1;
                -- Increase pulse density every 12 rising edges
                if cycle_count = 12 then
                    cycle_count := (others => '0');
                    if mod_lvl = 0 then
                        mod_lvl_v := to_unsigned(4, mod_lvl_v'length);
                    else
                        mod_lvl_v := mod_lvl_v - 1;
                    end if;
                    mod_lvl <= mod_lvl_v;
                    mod_lvl_f <= '1';
                end if;
            end if;
            last_state := sig;
        end if;
    end process;

end;
