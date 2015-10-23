library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.one_wire_pkg.all;

entity one_wire_tb is
end entity;

architecture one_wire_tb_arch of one_wire_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    constant TX_TEST_DATA   : std_logic_vector(7 downto 0)  := "10101010";
    --constant TX_TEST_DATA   : std_logic_vector(7 downto 0)  := "10011001";
    constant RX_TEST_DATA   : std_logic_vector(7 downto 0)  := "10101010";

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal reset_ow         : std_logic;
    signal ow_in            : std_logic;
    signal ow_out           : std_logic;
    signal ow_n_out         : std_logic;
    signal data             : std_logic_vector(8 - 1 downto 0);
    signal data_f           : std_logic;
    signal receive_data_f   : std_logic;
    signal busy             : std_logic;
    signal data_out         : std_logic_vector(8 - 1 downto 0);
    signal data_out_f       : std_logic;

    -- Signals internal to the test bench, not related to DUT
    signal reset_done       : std_logic;
    signal send_done        : std_logic;
    signal receive_done     : std_logic;

begin

    -- Invert the output signal coming from the 1-wire module for display
    ow_out <= not ow_n_out;

    DUT_inst: one_wire
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
        data_in             => data,
        data_in_f           => data_f,
        receive_data_f      => receive_data_f,
        ow_out              => ow_n_out,
        busy_out            => busy,
        data_out            => data_out,
        data_out_f          => data_out_f
    );

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    -- Generate a reset pulse on the 1-wire bus once reset is done
    ow_reset_gen: process(clk, reset)
        variable done       : std_logic;
    begin
        if reset = '1' then
            done := '0';
            reset_ow <= '0';
        elsif rising_edge(clk) then
            reset_ow <= '0';
            if done = '0' then
                reset_ow <= '1';
                done := '1';
            end if;
        end if;
    end process;

    -- Pull up flag after reset is sent to the bus (bus is not busy anymore)
    ow_reset_done_gen: process(busy, reset)
        variable done       : std_logic;
    begin
        if reset = '1' then
            done := '0';
            reset_done <= '0';
        elsif falling_edge(busy) then
            if done = '0' then
                reset_done <= '1';
                done := '1';
            end if;
        end if;
    end process;

    -- Send data on OW bus after reset is done
    ow_tx_data_gen: process(reset_done, clk, reset)
        variable done       : std_logic;
    begin
        if reset = '1' then
            done := '0';
            data <= (others => '0');
            data_f <= '0';
        elsif rising_edge(reset_done) then
            data <= TX_TEST_DATA;
            data_f <= '1';
        elsif rising_edge(clk) then
            data_f <= '0';
        end if;
    end process;

    -- Pull up flag after done sending data to the bus (bus is not busy anymore)
    ow_send_done_gen: process(busy, reset)
        variable done       : std_logic;
    begin
        if reset = '1' then
            done := '0';
            send_done <= '0';
        elsif falling_edge(busy) then
            if done = '0' and reset_done = '1' then
                send_done <= '1';
                done := '1';
            end if;
        end if;
    end process;

    -- Pull up a flag to indicate we want to receive data from the OW bus
    ow_rx_f_gen: process(send_done, clk, reset)
        variable done       : std_logic;
    begin
        if reset = '1' then
            done := '0';
            receive_data_f <= '0';
        elsif rising_edge(send_done) then
            if done = '0' then
                receive_data_f <= '1';
                done := '1';
            end if;
        elsif rising_edge(clk) then
            receive_data_f <= '0';
        end if;
    end process;

    -- Send data to OW module after sending is done
    ow_rx_data_gen: process(send_done, ow_out, reset)
        variable done       : std_logic;
        variable sending    : std_logic;
        variable index      : natural;
    begin
        if reset = '1' then
            done := '0';
            sending := '0';
            ow_in <= '0';
            index := 8;
        elsif rising_edge(send_done) then
            -- Only start sending after TX test is done
            sending := '1';
        elsif rising_edge(ow_out) then
            if sending = '1' then
                index := index - 1;
                if index = 0 then
                    ow_in <= RX_TEST_DATA(index);
                    sending := '0';
                    done := '1';
                else
                    ow_in <= RX_TEST_DATA(index);
                end if;
            end if;
        end if;
    end process;

    -- Pull up flag after done sending data to the bus (bus is not busy anymore)
    ow_receive_done_gen: process(busy, reset)
        variable done       : std_logic;
    begin
        if reset = '1' then
            done := '0';
            receive_done <= '0';
        elsif falling_edge(busy) then
            if done = '0' and send_done = '1' then
                receive_done <= '1';
                done := '1';
            end if;
        end if;
    end process;

    -- Assert received data is correct
    ow_rx_data_assert: process(data_out_f)
    begin
        if data_out_f = '1' then
            assert data_out = RX_TEST_DATA report "RX data does not match!"
                severity warning;
        end if;
    end process;

end;