library ieee;
library work;
use ieee.std_logic_1164.all;
use work.pwr_sequencer_pkg.all;
use work.utils_pkg.all;

entity pwr_sequencer is
    generic
    (
        LEVELS_N                : positive
    );
    port
    (
        clk                     : in std_logic;
        reset                   : in std_logic;
        start_in                : in std_logic;
        fail_in                 : in std_logic_vector(LEVELS_N - 1 downto 0);
        en_out                  : out std_logic_vector(LEVELS_N - 1 downto 0);
        status_out              : out status_t(LEVELS_N - 1 downto 0);
        main_pwr_en_out         : out std_logic;
        main_pwr_fail_out       : out std_logic
    );
end entity;

architecture pwr_sequencer_arch of pwr_sequencer is
begin

    pwr_sequencer_p: process(clk, reset)
        type state_t is (idle, sequencing, power_on, power_fail);
        variable state              : state_t;
        variable level_num          : natural;
        variable fail_states        : std_logic_vector(LEVELS_N - 1 downto 0);
        variable status             : status_t(status_out'range);
        variable last_start_state   : std_logic;
    begin
        if reset = '1' then
            state := idle;
            level_num := 0;
            fail_states := (others => '0');
            status := (others => (others => '0'));
            last_start_state := '0';
            en_out <= (others => '0');
            status_out <= (others => (others => '0'));
            main_pwr_en_out <= '0';
            main_pwr_fail_out <= '0';
        elsif rising_edge(clk) then
            if state = idle then
                level_num := 0;
                en_out <= (others => '0');
                status := (others => (others => '0'));
                status_out <= (others => (others => '0'));
                -- Start power sequence with a rising edge
                if not last_start_state = start_in and start_in = '1' then
                    state := sequencing;
                    main_pwr_fail_out <= '0';
                end if;
            elsif state = sequencing then
                -- Enable sequencing level
                en_out(level_num) <= '1';
                -- Enable according status output (for LED etc.)
                status(level_num)(0) := '1';
                status_out <= status;
                -- Wait for fail output to clear
                if fail_in(level_num) = '0' then
                    status(level_num) := shift_left_vec(status(level_num), 1);
                    status_out <= status;
                    level_num := level_num + 1;
                    -- Sequencing done
                    if level_num = status_out'length then
                        state := power_on;
                        main_pwr_en_out <= '1';
                    end if;
                end if;
            elsif state = power_on then
                -- Detect rising edges on fail inputs
                for i in 0 to fail_in'high loop
                    if not fail_in(i) = fail_states(i) and fail_in(i) = '1' then
                        status(i) := "100";
                        status_out <= status;
                        state := power_fail;
                        main_pwr_en_out <= '0';
                        main_pwr_fail_out <= '1';
                    end if;
                end loop;
            elsif state = power_fail then
                -- Restart sequencing
                if not last_start_state = start_in and start_in = '0' then
                    state := idle;
                end if;
            end if;
            fail_states := fail_in;
            last_start_state := start_in;
        end if;
    end process;

end;
