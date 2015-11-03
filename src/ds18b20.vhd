library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ds18b20_pkg.all;
use work.utils_pkg.all;

entity ds18b20 is
    generic
    (
        -- Conversion delay in clock cycles
        CONV_DELAY_VAL          : natural
    );
    port
    (
        clk                     : in std_logic;
        reset                   : in std_logic;
        -- Request temperature
        conv_in_f               : in std_logic;
        -- Connections to 1-wire module
        data_in                 : in std_logic_vector(8 - 1 downto 0);
        data_in_f               : in std_logic;
        busy_in                 : in std_logic;
        error_in                : in std_logic;
        error_id_in             : in unsigned(1 downto 0);
        crc_in                  : in std_logic_vector(8 - 1 downto 0);
        reset_ow_out            : out std_logic;
        data_out                : out std_logic_vector(8 - 1 downto 0);
        data_out_f              : out std_logic;
        receive_data_out_f      : out std_logic;
        -- Temperature output and associated strobe
        temp_out                : out signed(16 - 1 downto 0);
        temp_out_f              : out std_logic;
        temp_error_out          : out std_logic;
        pullup_out              : out std_logic
    );
end entity;

architecture ds18b20_arch of ds18b20 is
begin

    handler_p: process(clk, reset)
        type ds18b20_state is (idle, wait_busy, reset_ow, reset_error, rom_cmd,
            conv_cmd, conv_delay, read_cmd, start_read, read_byte);
        type data_array is array (9 - 1 downto 0) of
            std_logic_vector(8 - 1 downto 0);
        variable state          : ds18b20_state;
        variable next_state     : ds18b20_state;
        variable next_cmd       : ds18b20_state;
        variable data           : data_array;
        variable bytes_left     : unsigned(ceil_log2(data_in'length) downto 0);
        variable busy_state     : std_logic;
        variable timer          : unsigned(ceil_log2(CONV_DELAY_VAL) downto 0);
    begin
        if reset = '1' then
            state := idle;
            next_state := idle;
            next_cmd := conv_cmd;
            reset_ow_out <= '0';
            busy_state := '0';
            data := (others => (others => '0'));
            bytes_left := (others => '0');
            timer := (others => '0');
            receive_data_out_f <= '0';
            data_out <= (others => '0');
            data_out_f <= '0';
            temp_out <= (others => '0');
            temp_out_f <= '0';
            temp_error_out <= '0';
            pullup_out <= '1';
        elsif rising_edge(clk) then
            if state = idle then
                temp_out_f <= '0';
                if conv_in_f = '1' then
                    reset_ow_out <= '1';
                    state := reset_ow;
                end if;
            elsif state = wait_busy then
                data_out_f <= '0';
                if not busy_state = busy_in and busy_in = '0' then
                    state := next_state;
                end if;
                busy_state := busy_in;
            elsif state = reset_ow then
                bytes_left := to_unsigned(data'length, bytes_left'length);
                reset_ow_out <= '0';
                -- Reset error flag
                temp_error_out <= '0';
                pullup_out <= '1';
                state := wait_busy;
                next_state := reset_error;
            elsif state = reset_error then
                -- No device present on the bus, stop and go back to idle
                if error_in = '1' and error_id_in = 1 then
                    temp_error_out <= '1';
                    state := idle;
                else
                    state := rom_cmd;
                end if;
            elsif state = rom_cmd then
                data_out <= DS18B20_ROM_CMD;
                data_out_f <= '1';
                state := wait_busy;
                next_state := next_cmd;
            elsif state = conv_cmd then
                data_out <= DS18B20_CONV_CMD;
                data_out_f <= '1';
                state := wait_busy;
                next_state := conv_delay;
            elsif state = conv_delay then
                data_out_f <= '0';
                pullup_out <= '0';
                if timer < CONV_DELAY_VAL then
                    timer := timer + 1;
                else
                    timer := (others => '0');
                    next_cmd := read_cmd;
                    reset_ow_out <= '1';
                    state := reset_ow;
                end if;
            elsif state = read_cmd then
                data_out <= DS18B20_READ_CMD;
                data_out_f <= '1';
                state := wait_busy;
                next_cmd := conv_cmd;
                next_state := start_read;
            elsif state = start_read then
                receive_data_out_f <= '1';
                state := read_byte;
            elsif state = read_byte then
                receive_data_out_f <= '0';
                if data_in_f = '1' then
                    data(data'length - to_integer(bytes_left)) := data_in;
                    bytes_left := bytes_left - 1;
                    if bytes_left = 0 then
                        -- If CRC is valid
                        if crc_in = x"00" then
                            state := idle;
                            temp_out <= signed(std_logic_vector'(
                                data(1) & data(0)));
                            temp_out_f <= '1';
                        else
                            state := idle;
                            temp_error_out <= '1';
                        end if;
                    else
                        state := start_read;
                    end if;
                end if;
            end if;
        end if;
    end process;

end;
