library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity pid is
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
        pid_out             : out unsigned(OUT_N - 1 downto 0)
    );
end entity;

architecture pid_arch of pid is
begin

    pid_p: process(clk, reset)
        -- Size variable so that the bigges possible value fits
        variable prop           : signed(ceil_log2(2**IN_N * 2**P_SHIFT_N)
			downto 0);
        variable integral       : signed(OUT_N downto 0);
        variable sum            : signed(OUT_N downto 0);
        variable temp_out       : unsigned(OUT_N - 1 downto 0);
    begin
        if reset = '1' then
            pid_out <= to_unsigned(INIT_OUT_VAL, pid_out'length);
            prop := (others => '0');
            integral := (others => '0');
        elsif rising_edge(clk) then
            prop := shift_left(resize(-pid_in, prop'length), P_SHIFT_N);
            integral := integral - pid_in;
            sum := prop + shift_right(integral, I_SHIFT_N);
            -- Strip sign bit, add offset and limit value
            temp_out := unsigned(std_logic_vector(sum(sum'high - 1 downto 0)))
                + to_unsigned(OUT_OFFSET, pid_out'length);
            if temp_out > OUT_VAL_LIMIT then
                pid_out <= to_unsigned(OUT_VAL_LIMIT, OUT_N);
            else
                pid_out <= temp_out;
            end if;
        end if;
    end process;

end;
