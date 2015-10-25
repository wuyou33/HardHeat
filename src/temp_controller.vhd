library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.one_wire_pkg.all;
use work.ds18b20_pkg.all;
use work.pid_pkg.all;
use work.pwm_pkg.all;
use work.utils_pkg.all;

entity temp_controller is
    generic
    (
        CONV_INTERVAL       : natural;
        CONV_DELAY_VAL      : natural;
        RESET_ON_D          : positive;
        RESET_SAMPLE_D      : positive;
        RESET_D             : positive;
        TX_ONE_LOW_D        : positive;
        TX_ONE_HIGH_D       : positive;
        TX_ZERO_LOW_D       : positive;
        TX_ZERO_HIGH_D      : positive;
        RX_SAMPLE_D         : positive;
        RX_RELEASE_D        : positive;
        PWM_COUNTER_N       : positive;
        MIN_MOD_LVL         : positive;
        ENABLE_ON_D         : natural;
        P_SHIFT_N           : natural;
        I_SHIFT_N           : natural;
        PID_IN_OFFSET       : integer
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        ow_in               : in std_logic;
        enable_in           : in std_logic;
        ow_out              : out std_logic;
        temp_out            : out signed(16 - 1 downto 0);
        temp_out_f          : out std_logic;
        temp_error_out      : out std_logic;
        pwm_out             : out std_logic;
        conv_out            : out std_logic;
        crc_out             : out std_logic_vector(8 - 1 downto 0);
        receive_data_out_f  : out std_logic;
        busy_out            : out std_logic
    );
end entity;

architecture temp_controller_arch of temp_controller is
    signal reset_ow         : std_logic;
    signal data_in          : std_logic_vector(8 - 1 downto 0);
    signal data_in_f        : std_logic;
    signal receive_data_f   : std_logic;
    signal busy             : std_logic;
    signal data_out         : std_logic_vector(8 - 1 downto 0);
    signal data_out_f       : std_logic;
    signal err              : std_logic;
    signal err_id           : unsigned(1 downto 0);
    signal crc              : std_logic_vector(8 - 1 downto 0);
    signal pwm_enable       : std_logic;
    signal mod_lvl          : unsigned(PWM_COUNTER_N - 1 downto 0);
    signal mod_lvl_f        : std_logic;
    signal temp             : signed(16 - 1 downto 0);
    signal temp_f           : std_logic;
    signal conv             : std_logic;
begin

    temp_out <= temp;
    temp_out_f <= temp_f;
    -- These are mainly for simulation
    conv_out <= conv;
    crc_out <= crc;
    receive_data_out_f <= receive_data_f;
    busy_out <= busy;

    -- Perform temperature reading at predefined intervals
    conv_p: process(clk, reset)
        variable timer      : unsigned(ceil_log2(CONV_INTERVAL) downto 0);
    begin
        if reset = '1' then
            timer := to_unsigned(CONV_INTERVAL, timer'length);
            conv <= '0';
        elsif rising_edge(clk) then
            conv <= '0';
            if timer < CONV_INTERVAL then
                timer := timer + 1;
            else
                conv <= '1';
                timer := (others => '0');
            end if;
        end if;
    end process;

    ds18b20_p: ds18b20
    generic map
    (
        CONV_DELAY_VAL      => CONV_DELAY_VAL
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        conv_in_f           => conv,
        data_in             => data_out,
        data_in_f           => data_out_f,
        busy_in             => busy,
        error_in            => err,
        error_id_in         => err_id,
        reset_ow_out        => reset_ow,
        data_out            => data_in,
        data_out_f          => data_in_f,
        receive_data_out_f  => receive_data_f,
        temp_out            => temp,
        temp_out_f          => temp_f,
        crc_in              => crc,
        temp_error_out      => temp_error_out
    );

    ow_p: one_wire
    generic map
    (
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
        reset_ow            => reset_ow,
        ow_in               => ow_in,
        data_in             => data_in,
        data_in_f           => data_in_f,
        receive_data_f      => receive_data_f,
        ow_out              => ow_out,
        error_out           => err,
        error_id_out        => err_id,
        busy_out            => busy,
        data_out            => data_out,
        data_out_f          => data_out_f,
        crc_out             => crc
    );

    pid_p: pid
    generic map
    (
        P_SHIFT_N           => P_SHIFT_N,
        I_SHIFT_N           => I_SHIFT_N,
        IN_N                => temp'high,
        OUT_N               => PWM_COUNTER_N,
        INIT_OUT_VAL        => 0,
        IN_OFFSET           => PID_IN_OFFSET,
        OUT_OFFSET          => 0,
        OUT_VAL_LIMIT       => 2**PWM_COUNTER_N - 1
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        upd_clk_in          => temp_f,
        pid_in              => temp,
        pid_out             => mod_lvl
    );

    pwm_p: pwm
    generic map
    (
        COUNTER_N           => PWM_COUNTER_N,
        MIN_MOD_LVL         => MIN_MOD_LVL,
        ENABLE_ON_D         => ENABLE_ON_D
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        enable_in           => enable_in,
        mod_lvl_in          => mod_lvl,
        mod_lvl_f_in        => temp_f,
        pwm_out             => pwm_out
    );

end;
