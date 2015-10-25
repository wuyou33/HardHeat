library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ds18b20_pkg.all;
use work.one_wire_pkg.all;
use work.ds18b20_data_gen_pkg.all;

entity ds18b20_tb is
end entity;

architecture ds18b20_tb_arch of ds18b20_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    constant TEST_TEMP      : std_logic_vector(15 downto 0) := x"0031";
    type data_t is array(natural range <>) of std_logic_vector(8 - 1 downto 0);
    constant TEST_DATA      : data_t(9 - 1 downto 0) :=
        (x"31", x"00", x"4B", x"46", x"FF", x"FF", x"02", x"10", x"72");

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal reset_ow         : std_logic;
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
    signal ow_n_out         : std_logic;
    signal data_in          : std_logic_vector(8 - 1 downto 0);
    signal data_in_f        : std_logic;
    signal receive_data_f   : std_logic;
    signal busy             : std_logic;
    signal data_out         : std_logic_vector(8 - 1 downto 0);
    signal data_out_f       : std_logic;
    signal err              : std_logic;
    signal err_id           : unsigned(1 downto 0);
    signal temp             : signed(16 - 1 downto 0);
    signal temp_f           : std_logic;
    signal temp_error       : std_logic;
    signal crc              : std_logic_vector(8 - 1 downto 0);

    -- Signals internal to the test bench
    signal conv             : std_logic;

begin

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    -- Invert the output signal coming from the 1-wire module for display
    ow_out <= not ow_n_out;

    DUT_inst: ds18b20
    generic map
    (
        -- Use a small 1ms conversion delay to not make simulation take long
        CONV_DELAY_VAL      => 100000
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
        temp_error_out      => temp_error
    );

    ow_p: one_wire
    generic map
    (
        RESET_ON_D          => 48000,
        RESET_SAMPLE_D      => 7000,
        RESET_D             => 41000,
        TX_ONE_LOW_D        => 600,
        TX_ONE_HIGH_D       => 6400,
        TX_ZERO_LOW_D       => 6000,
        TX_ZERO_HIGH_D      => 1000,
        RX_SAMPLE_D         => 900,
        RX_RELEASE_D        => 5500
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
        ow_out              => ow_n_out,
        error_out           => err,
        error_id_out        => err_id,
        busy_out            => busy,
        data_out            => data_out,
        data_out_f          => data_out_f,
        crc_out             => crc
    );

    data_gen: ds18b20_data_gen
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        temp_in             => signed(TEST_TEMP),
        temp_in_f           => '0',
        ow_out              => ow_out,
        conv_out            => conv,
        crc_in              => crc,
        receive_data_f_in   => receive_data_f,
        busy_in             => busy,
        test_temp_in        => signed(TEST_TEMP)
    );

end;
