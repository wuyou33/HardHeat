library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hardheat_pkg.all;
use work.ds18b20_data_gen_pkg.all;

entity hardheat_tb is
    generic
    (
        TDC_N               : positive      := 12;
        FILT_P_SHIFT_N      : natural       := 7;
        FILT_I_SHIFT_N      : natural       := 0;
        FILT_INIT_OUT_VAL   : positive      := 2347483;
        FILT_OUT_OFFSET     : natural       := 2**21;
        FILT_OUT_VAL_LIMIT  : positive      := 2347483;
        ACCUM_BITS_N        : positive      := 32;
        ACCUM_WORD_N        : positive      := 23;
        DT_N                : positive      := 16;
        DT_VAL              : natural       := 100;
        LD_LOCK_N           : positive      := 20;
        LD_ULOCK_N          : positive      := 16;
        LD_LOCK_LIMIT       : natural       := 100;
        TEMP_CONV_D         : natural       := 1000000;
        TEMP_CONV_CMD_D     : natural       := 750000;
        TEMP_OW_US_D        : positive      := 100;
        TEMP_PWM_N          : positive      := 12;
        TEMP_PWM_MIN_LVL    : natural       := 2**12 / 5;
        TEMP_PWM_EN_ON_D    : natural       := 2000000;
        TEMP_P_SHIFT_N      : natural       := 4;
        TEMP_I_SHIFT_N      : natural       := 11;
        TEMP_PID_IN_OFFSET  : integer       := -320
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

    -- Temperature controller related signals
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
    signal temp             : signed(16 - 1 downto 0);
    signal temp_f           : std_logic;
    signal temp_out_f       : std_logic;

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
        TDC_N               => TDC_N,
        FILT_P_SHIFT_N      => FILT_P_SHIFT_N,
        FILT_I_SHIFT_N      => FILT_I_SHIFT_N,
        FILT_INIT_OUT_VAL   => FILT_INIT_OUT_VAL,
        FILT_OUT_OFFSET     => FILT_OUT_OFFSET,
        FILT_OUT_VAL_LIMIT  => FILT_OUT_VAL_LIMIT,
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
        TEMP_PID_IN_OFFSET  => TEMP_PID_IN_OFFSET
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
        sig_rl_out          => sig_rl,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_out_f          => temp_out_f
    );

    data_gen_p: ds18b20_data_gen
    generic map
    (
        MICROSECOND_D       => TEMP_OW_US_D
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_in             => temp,
        temp_in_f           => temp_f
    );

    temp_gen: process(clk, reset)
        variable cur_temp   : signed(16 - 1 downto 0);
    begin
        if reset = '1' then
            cur_temp := to_signed(320, temp'length);
            temp <= cur_temp;
            temp_f <= '0';
        elsif rising_edge(clk) then
            temp_f <= '0';
            if temp_out_f = '1' then
                cur_temp := cur_temp + 16;
                temp <= cur_temp;
                temp_f <= '1';
            end if;
        end if;
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

    -- Make sure same side high- and low-side are never on at the same time
    assert not (sig_lh = sig_ll and sig_lh = '1')
        report "Left h = l" severity warning;
    assert not (sig_rh = sig_rl and sig_rh = '1')
        report "Right h = l" severity warning;

end;
