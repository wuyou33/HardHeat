library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.ds18b20_pkg.all;
use work.one_wire_pkg.all;
use work.ds18b20_data_gen_pkg.all;

entity ds18b20_tb is
end entity;

architecture ds18b20_tb_arch of ds18b20_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    -- Conversion interval in clock cycles
    constant CONV_INTERVAL  : natural := 750000;

    constant TEST_TEMP      : std_logic_vector(15 downto 0) := x"0031";
    type data_t is array(natural range <>) of std_logic_vector(8 - 1 downto 0);
    constant TEST_DATA      : data_t(9 - 1 downto 0) :=
        (x"31", x"00", x"4B", x"46", x"FF", x"FF", x"02", x"10", x"72");

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal reset_ow         : std_logic;
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
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

    -- Verify CRC after doing one full conversion
    assert_crc: process(temp_f)
    begin
        if rising_edge(temp_f) then
            assert crc = x"00" report "CRC error!" severity failure;
        end if;
    end process;

    -- Verify we do not encounter a temp error
    process(clk, reset)
    begin
        if rising_edge(clk) and not reset = '1' then
            assert temp_error = '0' report "Temp error!" severity failure;
        end if;
    end process;

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
        US_D                => 100
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

    data_gen: ds18b20_data_gen
    generic map
    (
        MICROSECOND_D       => 100
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        ow_in               => ow_in,
        ow_out              => ow_out,
        temp_in             => signed(TEST_TEMP),
        temp_in_f           => '0'
    );

end;
