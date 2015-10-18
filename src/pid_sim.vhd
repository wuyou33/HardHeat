library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid_sim is
    generic
    (
        -- Proportional coefficient, input value multiplied by 2^P_SHIFT_N
        P_SHIFT_N           : natural;
        -- Integral coefficient, cumulative error multiplied by 2^-I_SHIFT_N
        I_SHIFT_N           : natural;
        -- Number of bits in the input of the filter (signed)
        IN_N                : positive;
        -- Number of output bits (unsigned)
        OUT_N               : positive;
        -- Initial value for the tuning word after reset
        INIT_OUT_VAL        : positive;
        -- Offset for the output value
        OUT_OFFSET          : natural;
        -- Output value limit
        OUT_VAL_LIMIT       : positive
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        pid_in              : in signed(IN_N downto 0);
        pid_out             : out unsigned(OUT_N - 1 downto 0);
        proportional_out    : out signed(OUT_N downto 0);
        integral_out        : out signed(OUT_N downto 0)
    );
end entity;

architecture pid_sim_arch of pid_sim is
begin

    pid_p: process(clk, reset)
        variable proportional   : integer;
        variable integral       : integer;
        variable temp           : integer;
    begin
        if reset = '1' then
            pid_out <= to_unsigned(INIT_OUT_VAL, pid_out'length);
            proportional := 0;
            proportional_out <= to_signed(proportional, proportional_out'length);
            integral := 0;
            integral_out <= to_signed(integral, integral_out'length);
        elsif rising_edge(clk) then
            proportional := to_integer(-pid_in) * 2**P_SHIFT_N;
            integral := integral - to_integer(pid_in);
            proportional_out <= to_signed(proportional, proportional_out'length);
            integral_out <= to_signed(integral, integral_out'length);
            temp := proportional + (integral * 2**I_SHIFT_N) + OUT_OFFSET;
            if temp > OUT_VAL_LIMIT then
                pid_out <= to_unsigned(OUT_VAL_LIMIT, OUT_N);
            else
                pid_out <= to_unsigned(temp, OUT_N);
            end if;
        end if;
    end process;

end;
