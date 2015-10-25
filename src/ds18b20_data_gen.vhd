library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity ds18b20_data_gen is
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        ow_out              : in std_logic;
        temp_in             : in signed(16 - 1 downto 0);
        temp_in_f           : in std_logic;
        -- Test temperature value in, data_gen generates a new data packet from
        -- this value and transmits it to the 1-wire bus
        test_temp_in        : in signed(16 - 1 downto 0);
        crc_in              : in std_logic_vector(8 - 1 downto 0);
        receive_data_f_in   : in std_logic;
        busy_in             : in std_logic;
        ow_in               : out std_logic;
        conv_out            : out std_logic
    );
end entity;

architecture ds18b20_data_gen_arch of ds18b20_data_gen is
    subtype data_t is std_logic_vector(8 - 1 downto 0);
    type data_array_t is array(natural range <>) of data_t;
    function calc_crc(Arg : data_t; NewByte : data_t) return data_t is
        variable crc        : data_t;
        variable bit_num    : natural := 0;
    begin
        while bit_num < 8 loop
            crc := Arg;
            crc(crc'left) := NewByte(bit_num) xor crc(crc'right);
            crc(4) := crc(3) xor crc(crc'left);
            crc(5) := crc(4) xor crc(crc'left);
            crc := shift_left_vec(crc, 1);
            bit_num := bit_num + 1;
        end loop;
        return(crc);
    end function;
    function gen_data(Temp : signed(16 - 1 downto 0)) return data_array_t is
        variable byte_num   : natural := 0;
        variable bit_num    : natural := 0;
        variable data       : data_array_t(8 downto 0);
        variable crc        : data_t := (others => '0');
    begin
        while byte_num < 9 loop
            if byte_num = 0 then
                data(byte_num) := std_logic_vector(Temp(7 downto 0));
            elsif byte_num = 1 then
                data(byte_num) := std_logic_vector(Temp(15 downto 8));
            elsif byte_num = 2 then
                data(byte_num) := x"4B";
            elsif byte_num = 3 then
                data(byte_num) := x"46";
            elsif byte_num = 4 then
                data(byte_num) := x"FF";
            elsif byte_num = 5 then
                data(byte_num) := x"FF";
            elsif byte_num = 6 then
                data(byte_num) := x"02";
            elsif byte_num = 7 then
                data(byte_num) := x"10";
            elsif byte_num = 8 then
                data(byte_num) := crc;
                return(data);
            end if;
            crc := calc_crc(crc, data(byte_num));
            byte_num := byte_num + 1;
        end loop;
    end function;
begin

    -- Send data to 1-wire module
    data_gen_p: process(clk, reset)
        type data_gen_state is (idle, wait_busy, wait_ow_high, wait_receive,
            release_ow, tx, assert_temp);
        variable state      : data_gen_state;
        variable next_state : data_gen_state;
        variable byte_num   : natural;
        variable bit_num    : natural;
        variable last_state : std_logic;
        variable busy_state : std_logic;
        variable test_data  : data_array_t(8 downto 0);
        variable last_temp  : signed(15 downto 0);
    begin
        if reset = '1' then
            state := idle;
            next_state := idle;
            ow_in <= '1';
            byte_num := 0;
            bit_num := 0;
            last_state := '0';
            busy_state := '0';
            conv_out <= '0';
            last_temp := test_temp_in;
            test_data := gen_data(test_temp_in);
        elsif rising_edge(clk) then
            if not test_temp_in = last_temp then
                -- If temperature has changed, regenerate test data
                test_data := gen_data(test_temp_in);
                last_temp := test_temp_in;
            end if;
            if state = idle then
                conv_out <= '1';
                state := wait_ow_high;
                if receive_data_f_in = '1' then
                    state := wait_ow_high;
                end if;
            elsif state = wait_busy then
                if not busy_state = busy_in and busy_in = '0' then
                    state := next_state;
                end if;
                busy_state := busy_in;
            elsif state = wait_ow_high then
                conv_out <= '0';
                if not last_state = ow_out and ow_out = '1' then
                    ow_in <= '0';
                    state := wait_busy;
                    next_state := release_ow;
                end if;
                last_state := ow_out;
            elsif state = release_ow then
                ow_in <= '1';
                state := wait_receive;
            elsif state = wait_receive then
                if receive_data_f_in = '1' then
                    state := tx;
                    last_state := ow_out;
                end if;
            elsif state = tx then
                if not last_state = ow_out and ow_out = '1' then
                    ow_in <= test_data(test_data'high - byte_num)(bit_num);
                    bit_num := bit_num + 1;
                    if bit_num = 8 then
                        byte_num := byte_num + 1;
                        bit_num := 0;
                        if byte_num = 9 then
                            state := assert_temp;
                            byte_num := 0;
                            bit_num := 0;
                        end if;
                    end if;
                end if;
                last_state := ow_out;
            elsif state = assert_temp then
                if temp_in_f = '1' then
                    assert crc_in = x"00" report "CRC does not match!"
                        severity warning;
                    assert temp_in = test_temp_in report
                        "Received temp does not match!" severity warning;
                    state := idle;
                end if;
            end if;
        end if;
    end process;

end;
