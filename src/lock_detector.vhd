library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lock_detector is
    generic
    (
        -- Number of bits in the phase-difference input
        PHASE_TIME_IN_N         : positive;
        -- Number of bits in the lock counter
        LOCK_COUNT_N            : positive;
        -- Number of bits in the unlock counter
        ULOCK_COUNT_N           : positive;
        -- Value under which the phase is considered to be locked
        LOCK_LIMIT              : natural
    );
    port
    (
        clk                     : in std_logic;
        reset                   : in std_logic;
        phase_time_in           : in signed(PHASE_TIME_IN_N downto 0);
        lock_out                : out std_logic
    );
end entity;

architecture lock_detector_arch of lock_detector is
begin

    lock_detector_p: process(clk, reset)
        variable lock_count     : unsigned(LOCK_COUNT_N - 1 downto 0);
        variable ulock_count    : unsigned(ULOCK_COUNT_N - 1 downto 0);
    begin
        if reset = '1' then
            lock_count := (others => '0');
            ulock_count := (others => '0');
            lock_out <= '0';
        elsif rising_edge(clk) then
            if phase_time_in <= LOCK_LIMIT and phase_time_in >= -LOCK_LIMIT then
                lock_count := lock_count + 1;
                if lock_count = 2**lock_count'length - 1 then
                    lock_out <= '1';
                end if;
            else
                lock_count := (others => '0');
                ulock_count := ulock_count + 1;
                if ulock_count = 2**ulock_count'length - 1 then
                    lock_out <= '0';
                end if;
            end if;
        end if;
    end process;

end;
