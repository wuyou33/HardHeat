library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ds18b20 is
    generic
    (

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
        reset_ow_out            : out std_logic;
        data_out                : out std_logic_vector(8 - 1 downto 0);
        data_out_f              : out std_logic;
        receive_data_out_f      : out std_logic;
        -- Temperature output and associated strobe
        temp_out                : out signed(16 - 1 downto 0);
        temp_out_f              : out std_logic;
    );
end entity;

architecture ds18b20_arch of ds18b20 is
    signal reset_done           : std_logic;
    signal rom_done             : std_logic;
begin

    -- Reset 1-wire bus first when conversion has been requested
    ds18b20_reset_p: process(clk, reset)
        variable wait_busy      : std_logic;
    begin
        if reset = '1' then
            wait_busy := '0';
            reset_done <= '0';
            reset_ow_out <= '0';
        elsif rising_edge(clk) then
            reset_ow_out <= '0';
            if conv_in_f = '1' then
                reset_ow_out <= '1';
                reset_done <= '0';
                -- Wait until 1-wire bus has been reset
                wait_busy := '1';
            elsif wait_busy = '1' then
                if busy_in = '0' then
                    -- If there is a device present on the bus, otherwise stop
                    if error_in = '0' then
                        reset_done <= '1';
                        wait_busy := '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- After bus has been reset, send skip rom command
    ds18b20_rom_p: process(clk, reset)
    begin
        if reset = '1' then
            rom_done <= '0';
            data_out <= (others => '0');
            data_out_f <= '0';
            temp_out <= (others => '0');
            temp_out_f <= '0';
        elsif rising_edge(clk) then

        end if;
    end process;

end;
