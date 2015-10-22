library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hardheat_pkg.all;

entity hardheat_top is
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
        OUT_VAL_LIMIT       : positive      := 2347483;
        LOCK_COUNT_N        : positive      := 20;
        ULOCK_COUNT_N       : positive      := 16;
        LOCK_LIMIT          : natural       := 100
    );
    port
    (
        clk_in              : in std_logic;
        reset_in            : in std_logic;
        ref_in              : in std_logic;
        sig_in              : in std_logic;
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic;
        lock_out            : out std_logic
    );
end entity;

architecture hardheat_arch_top of hardheat_top is
    signal reset_n          : std_logic;
    signal mod_lvl          : unsigned(2 downto 0);
    signal mod_lvl_f        : std_logic;
begin

    -- Invert reset_in and sync to clk
    reset_clk_sync_p: process(clk_in)
    begin
        if rising_edge(clk_in) then
            reset_n <= not reset_in;
        end if;
    end process;

    -- Fix modulation level to no modulation
    mod_lvl <= to_unsigned(4, mod_lvl'length);
    mod_lvl_f <= '0';

    -- TODO: Sig is internally connected!
    hardheat_p: hardheat
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
        OUT_VAL_LIMIT       => OUT_VAL_LIMIT,
        LOCK_COUNT_N        => LOCK_COUNT_N,
        ULOCK_COUNT_N       => ULOCK_COUNT_N,
        LOCK_LIMIT          => LOCK_LIMIT
    )
    port map
    (
        clk                 => clk_in,
        reset               => reset_n,
        ref_in              => ref_in,
        sig_in              => sig_in,
        mod_lvl_in          => mod_lvl,
        mod_lvl_in_f        => mod_lvl_f,
        sig_lh_out          => sig_lh_out,
        sig_ll_out          => sig_ll_out,
        sig_rh_out          => sig_rh_out,
        sig_rl_out          => sig_rl_out,
        lock_out            => lock_out
    );

end;
