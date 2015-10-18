library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lock_detector_pkg is
    component lock_detector is
        generic
        (
            PHASE_TIME_IN_N         : positive;
            LOCK_COUNT_N            : positive;
            ULOCK_COUNT_N           : positive;
            LOCK_LIMIT              : natural
        );
        port
        (
            clk                     : in std_logic;
            reset                   : in std_logic;
            phase_time_in           : in signed(PHASE_TIME_IN_N downto 0);
            lock_out                : out std_logic
        );
    end component;
end package;
