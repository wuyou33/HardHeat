library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hardheat_pkg.all;

entity hardheat_tb is
    generic
    (
        COUNTER_N           : positive      := 12;
        P_SHIFT_N           : natural       := 7;
        I_SHIFT_N           : natural       := 0;
        ACCUM_BITS_N        : positive      := 32;
        TUNING_WORD_N       : positive      := 23;
        INIT_OUT_VAL        : positive      := 2347483;
        DT_COUNTER_N        : positive      := 16;
        DT_VAL              : natural       := 100;
        OUT_OFFSET          : natural       := 2**21;
        OUT_VAL_LIMIT       : positive      := 2347483
    );
end entity;

architecture hardheat_arch_tb of hardheat_tb is

    -- Clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;
    -- Reference signal frequency 50 kHz
    constant REF_PERIOD     : time := 1 sec / 50e3;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal ref              : std_logic := '0';
    signal sig              : std_logic;
    signal sig_lh           : std_logic;
    signal sig_ll           : std_logic;
    signal sig_rh           : std_logic;
    signal sig_rl           : std_logic;
    signal mod_lvl          : unsigned(2 downto 0);
    signal mod_lvl_f        : std_logic;

begin

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    ref_gen: process(ref)
    begin
        ref <= not ref after REF_PERIOD / 2;
    end process;

    DUT_inst: hardheat
    generic map
    (
        COUNTER_N           => COUNTER_N,
        P_SHIFT_N           => P_SHIFT_N,
        I_SHIFT_N           => I_SHIFT_N,
        ACCUM_BITS_N        => ACCUM_BITS_N,
        TUNING_WORD_N       => TUNING_WORD_N,
        INIT_OUT_VAL        => INIT_OUT_VAL,
        DT_COUNTER_N        => DT_COUNTER_N,
        DT_VAL              => DT_VAL,
        OUT_OFFSET          => OUT_OFFSET,
        OUT_VAL_LIMIT       => OUT_VAL_LIMIT
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref,
        sig_in              => sig,
        mod_lvl_in          => mod_lvl,
        mod_lvl_in_f        => mod_lvl_f,
        sig_out             => sig,
        sig_lh_out          => sig_lh,
        sig_ll_out          => sig_ll,
        sig_rh_out          => sig_rh,
        sig_rl_out          => sig_rl
    );

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

    -- Make sure same side high- and low-side are never on at the same time
    assert not (sig_lh = sig_ll and sig_lh = '1')
        report "Left h = l" severity warning;
    assert not (sig_rh = sig_rl and sig_rh = '1')
        report "Right h = l" severity warning;

end;
