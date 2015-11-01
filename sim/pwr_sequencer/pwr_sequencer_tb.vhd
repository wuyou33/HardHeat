library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pwr_sequencer_pkg.all;

entity pwr_sequencer_tb is
    generic
    (
        LEVELS_N            : natural   := 3;
        TEST_D              : natural   := 10000
    );
end entity;

architecture pwr_sequencer_tb_arch of pwr_sequencer_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal main_pwr_en      : std_logic;
    signal main_pwr_fail    : std_logic;
    signal start            : std_logic;
    signal fail             : std_logic_vector(LEVELS_N - 1 downto 0);
    signal enable           : std_logic_vector(LEVELS_N - 1 downto 0);

begin

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    DUT_inst: pwr_sequencer
    generic map
    (
        LEVELS_N            => LEVELS_N
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        start_in            => start,
        fail_in             => fail,
        en_out              => enable,
        main_pwr_en_out     => main_pwr_en,
        main_pwr_fail_out   => main_pwr_fail
    );

    fail_gen: process(clk, reset)
        type state_t is (idle, delay, power_on, cause_fail);
        variable state          : state_t;
        variable timer          : natural;
        variable cur_level      : natural;
    begin
        if reset = '1' then
            state := idle;
            timer := 0;
            fail <= (others => '1');
            cur_level := 0;
            start <= '0';
        elsif rising_edge(clk) then
            if state = idle then
                start <= '1';
                for i in 0 to enable'high loop
                    if enable(i) = '1' then
                        cur_level := i;
                        state := delay;
                    end if;
                end loop;
            elsif state = delay then
                timer := timer + 1;
                if timer > TEST_D then
                    fail(cur_level) <= '0';
                    timer := 0;
                    if cur_level = enable'high then
                        state := power_on;
                    else
                        state := idle;
                    end if;
                end if;
            elsif state = power_on then
                timer := timer + 1;
                -- After succesfull sequencing cause a failure
                if timer > TEST_D then
                    fail(0) <= '1';
                    timer := 0;
                    state := cause_fail;
                end if;
            elsif state = cause_fail then
                timer := timer + 1;
                start <= '0';
                -- After succesfull power failure, restart
                if timer > TEST_D then
                    start <= '1';
                    fail <= (others => '1');
                    timer := 0;
                    state := idle;
                end if;
            end if;
        end if;
    end process;

end;
