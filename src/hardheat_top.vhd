library ieee;
library work;
library altera;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.altera_pll_top_pkg.all;
use work.hardheat_pkg.all;
use altera.altera_syn_attributes.all;

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
        LOCK_LIMIT          : natural       := 100;
        CONV_INTERVAL       : natural       := 100000000;
        CONV_DELAY_VAL      : natural       := 75000000;
        RESET_ON_D          : positive      := 48000;
        RESET_SAMPLE_D      : positive      := 7000;
        RESET_D             : positive      := 41000;
        TX_ONE_LOW_D        : positive      := 600;
        TX_ONE_HIGH_D       : positive      := 6400;
        TX_ZERO_LOW_D       : positive      := 6000;
        TX_ZERO_HIGH_D      : positive      := 1000;
        RX_SAMPLE_D         : positive      := 900;
        RX_RELEASE_D        : positive      := 5500
    );
    port
    (
        clk_in              : in std_logic;
        reset_in            : in std_logic;
        ref_in              : in std_logic;
        sig_in              : in std_logic;
        ow_in               : in std_logic;
        mod_lvl_in          : in std_logic_vector(2 downto 0);
        ow_out              : out std_logic;
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic;
        lock_out            : out std_logic
    );
end entity;

architecture hardheat_arch_top of hardheat_top is
    signal clk                      : std_logic;
    signal pll_clk                  : std_logic;
    signal pll_locked               : std_logic;
    signal reset                    : std_logic;
    signal mod_lvl                  : unsigned(2 downto 0);
    signal mod_lvl_f                : std_logic;
    signal temp                     : signed(16 - 1 downto 0);
    signal temp_f                   : std_logic;
    signal temp_error               : std_logic;
    attribute noprune               : boolean;
    attribute noprune of temp       : signal is true;
    attribute noprune of temp_f     : signal is true;
    attribute noprune of temp_error : signal is true;
    attribute preserve              : boolean;
    attribute preserve of temp      : signal is true;
    attribute preserve of temp_f    : signal is true;
    attribute preserve of temp_error: signal is true;
begin

    -- Main clock from PLL on the SoCkit board
    pll_p: altera_pll_top
    port map
    (
        refclk              => clk_in,
        rst                 => not reset_in,
        outclk_0            => pll_clk,
        locked              => pll_locked
    );

    clk <= pll_clk;
    reset <= not pll_locked;

    -- Read modulation level state from switches on SoCkit and output new
    -- modulation whenever their state changes
    mod_lvl_p: process(clk, reset)
        variable state      : unsigned(2 downto 0);
    begin
        if reset = '1' then
            state := to_unsigned(4, mod_lvl'length);
            mod_lvl <= to_unsigned(4, mod_lvl'length);
            mod_lvl_f <= '0';
        elsif rising_edge(clk) then
            mod_lvl_f <= '0';
            if not mod_lvl_in = std_logic_vector(state) then
                state := unsigned(mod_lvl_in);
                mod_lvl <= state;
                mod_lvl_f <= '1';
            end if;
        end if;
    end process;

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
        LOCK_LIMIT          => LOCK_LIMIT,
        CONV_INTERVAL       => CONV_INTERVAL,
        CONV_DELAY_VAL      => CONV_DELAY_VAL,
        RESET_ON_D          => RESET_ON_D,
        RESET_SAMPLE_D      => RESET_SAMPLE_D,
        RESET_D             => RESET_D,
        TX_ONE_LOW_D        => TX_ONE_LOW_D,
        TX_ONE_HIGH_D       => TX_ONE_HIGH_D,
        TX_ZERO_LOW_D       => TX_ZERO_LOW_D,
        TX_ZERO_HIGH_D      => TX_ZERO_HIGH_D,
        RX_SAMPLE_D         => RX_SAMPLE_D,
        RX_RELEASE_D        => RX_RELEASE_D
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref_in,
        sig_in              => sig_in,
        mod_lvl_in          => mod_lvl,
        mod_lvl_in_f        => mod_lvl_f,
        sig_lh_out          => sig_lh_out,
        sig_ll_out          => sig_ll_out,
        sig_rh_out          => sig_rh_out,
        sig_rl_out          => sig_rl_out,
        lock_out            => lock_out,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_out            => temp,
        temp_out_f          => temp_f,
        temp_error_out      => temp_error
    );

end;
