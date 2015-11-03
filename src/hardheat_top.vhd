library ieee;
library work;
library altera;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.altera_pll_top_pkg.all;
use work.hardheat_pkg.all;
use work.debounce_pkg.all;
use altera.altera_syn_attributes.all;

entity hardheat_top is
    generic
    (
        -- Number of bits in time-to-digital converter
        TDC_N               : positive      := 12;
        -- Number of bitshifts to left for the filter proportional coefficient
        FILT_P_SHIFT_N      : integer       := 0;
        -- Number of bitshifts to right for the filter integral coefficient
        FILT_I_SHIFT_N      : integer       := -5;
        -- Initial output value from the filter
        FILT_INIT_OUT_VAL   : positive      := 2**11 - 1;
        -- Filter output offset
        FILT_OUT_OFFSET     : natural       := 2**21;
        -- Filter output value clamping limit
        FILT_OUT_LIM        : positive      := 2**22;
        -- Number of bits in the phase accumulator
        ACCUM_BITS_N        : positive      := 32;
        -- Number of bits in the tuning word for the phase accumulator
        ACCUM_WORD_N        : positive      := 23;
        -- Number of bits in the deadtime counter
        DT_N                : positive      := 16;
        -- Amount of deadtime in clock cycles
        DT_VAL              : natural       := 100;
        -- Number of bits in the lock detector "locked" counter
        LD_LOCK_N           : positive      := 20;
        -- Number of bits in the lock detector "unlocked" counter
        LD_ULOCK_N          : positive      := 16;
        -- Phase difference value under which we are considered to be locked
        LD_LOCK_LIMIT       : natural       := 100;
        -- Temperature conversion interval in clock cycles
        TEMP_CONV_D         : natural       := 100000000;
        -- Delay between conversion command and reading in clock cycles
        TEMP_CONV_CMD_D     : natural       := 75000000;
        -- Number of clock cycles for 1us delay for the 1-wire module
        TEMP_OW_US_D        : positive      := 100;
        -- Number of bits in the temperature PWM controller
        TEMP_PWM_N          : positive      := 12;
        -- Minimum PWM level (duty cycle)
        TEMP_PWM_MIN_LVL    : natural       := 2**12 / 5;
        -- Output maximum duty cycle on enable, measured in PWM cycles!
        TEMP_PWM_EN_ON_D    : natural       := 100000;
        -- Number of bitshifts to left for the PID-filter proportional coeff
        TEMP_P_SHIFT_N      : integer       := 4;
        -- Number of bitshifts to right for the PID-filter integral coeff
        TEMP_I_SHIFT_N      : integer       := -11;
        -- PID input offset applied to the temperature sensor output
        TEMP_SETPOINT       : integer       := 320;
        DEBOUNCE_D          : natural       := 1000000;
        DEBOUNCE_FF_N       : natural       := 5
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
        ow_pullup_out       : out std_logic;
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic;
        lock_out            : out std_logic;
        pwm_out             : out std_logic;
        temp_err_out        : out std_logic
    );
end entity;

architecture hardheat_arch_top of hardheat_top is
    attribute noprune               : boolean;
    attribute preserve              : boolean;
    attribute keep                  : boolean;
    signal clk                      : std_logic;
    attribute noprune of clk        : signal is true;
    attribute keep of clk           : signal is true;
    signal temp                     : signed(16 - 1 downto 0);
    signal temp_f                   : std_logic;
    attribute keep of temp          : signal is true;
    attribute keep of temp_f        : signal is true;
    attribute noprune of temp       : signal is true;
    attribute noprune of temp_f     : signal is true;
    attribute preserve of temp      : signal is true;
    --attribute preserve of temp_f    : signal is true;
    signal pll_clk                  : std_logic;
    signal pll_locked               : std_logic;
    signal reset                    : std_logic;
    signal mod_lvl                  : std_logic_vector(mod_lvl_in'range);
    signal mod_lvl_f                : std_logic;
    signal debounced_sws            : std_logic_vector(mod_lvl_in'range);
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

    -- Read modulation level state from switches, debounce
    debouncing_p: for i in 0 to mod_lvl_in'high generate
    debouncer_p: debounce
    generic map
    (
        DEBOUNCE_D          => DEBOUNCE_D,
        FLIPFLOPS_N         => DEBOUNCE_FF_N
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        sig_in              => mod_lvl_in(i),
        sig_out             => debounced_sws(i)
    );
    end generate;

    -- Change modulation level when debounced modulation level changes
    mod_lvl_p: process(clk, reset)
        variable state      : std_logic_vector(mod_lvl_in'high downto 0);
    begin
        if reset = '1' then
            state := (others => '1');
            mod_lvl <= state;
            mod_lvl_f <= '0';
        elsif rising_edge(clk) then
            mod_lvl_f <= '0';
            if not debounced_sws = state then
                state := debounced_sws;
                mod_lvl <= state;
                mod_lvl_f <= '1';
            end if;
        end if;
    end process;

    -- TODO: Sig is internally connected!
    hardheat_p: hardheat
    generic map
    (
        TDC_N               => TDC_N,
        FILT_P_SHIFT_N      => FILT_P_SHIFT_N,
        FILT_I_SHIFT_N      => FILT_I_SHIFT_N,
        FILT_INIT_OUT_VAL   => FILT_INIT_OUT_VAL,
        FILT_OUT_OFFSET     => FILT_OUT_OFFSET,
        FILT_OUT_LIM        => FILT_OUT_LIM,
        ACCUM_BITS_N        => ACCUM_BITS_N,
        ACCUM_WORD_N        => ACCUM_WORD_N,
        LD_LOCK_N           => LD_LOCK_N,
        LD_ULOCK_N          => LD_ULOCK_N,
        LD_LOCK_LIMIT       => LD_LOCK_LIMIT,
        DT_N                => DT_N,
        DT_VAL              => DT_VAL,
        TEMP_CONV_D         => TEMP_CONV_D,
        TEMP_CONV_CMD_D     => TEMP_CONV_CMD_D,
        TEMP_OW_US_D        => TEMP_OW_US_D,
        TEMP_PWM_N          => TEMP_PWM_N,
        TEMP_PWM_MIN_LVL    => TEMP_PWM_MIN_LVL,
        TEMP_PWM_EN_ON_D    => TEMP_PWM_EN_ON_D,
        TEMP_P_SHIFT_N      => TEMP_P_SHIFT_N,
        TEMP_I_SHIFT_N      => TEMP_I_SHIFT_N,
        TEMP_SETPOINT       => TEMP_SETPOINT
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ref_in              => ref_in,
        sig_in              => sig_in,
        mod_lvl_in          => unsigned(mod_lvl),
        mod_lvl_in_f        => mod_lvl_f,
        sig_lh_out          => sig_lh_out,
        sig_ll_out          => sig_ll_out,
        sig_rh_out          => sig_rh_out,
        sig_rl_out          => sig_rl_out,
        lock_out            => lock_out,
        ow_in               => ow_in,
        ow_out              => ow_out,
        ow_pullup_out       => ow_pullup_out,
        temp_out            => temp,
        temp_out_f          => temp_f,
        temp_err_out        => temp_err_out,
        pwm_out             => pwm_out
    );

end;
