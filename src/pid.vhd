library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        pid_out             : out unsigned(OUT_N - 1 downto 0);
        proportional_out    : out signed(OUT_N downto 0);
        integral_out        : out signed(OUT_N downto 0)
    );
end entity;

architecture pid_arch of pid is
begin

    pid_p: process(clk, reset)
        variable proportional   : signed(OUT_N downto 0);
        variable integral       : signed(OUT_N downto 0);
        variable temp           : signed(OUT_N downto 0);
        variable temp_out       : unsigned(OUT_N - 1 downto 0);
    begin
        if reset = '1' then
            pid_out <= to_unsigned(INIT_OUT_VAL, pid_out'length);
            proportional := (others => '0');
            proportional_out <= proportional;
            integral := (others => '0');
            integral_out <= integral;
        elsif rising_edge(clk) then
            -- TODO: What about saturation?
            proportional := shift_left(resize(-pid_in, OUT_N + 1), P_SHIFT_N);
            proportional_out <= proportional;
            integral := integral - pid_in;
            integral_out <= integral;
            temp := signed(std_logic_vector(resize(proportional, proportional'length))) + signed(std_logic_vector(shift_right(integral, I_SHIFT_N)));
            temp_out := unsigned(std_logic_vector(temp(temp'high - 1 downto 0))) + to_unsigned(OUT_OFFSET, pid_out'length);
            if temp_out > OUT_VAL_LIMIT then
                pid_out <= to_unsigned(OUT_VAL_LIMIT, OUT_N);
            else
                pid_out <= temp_out;
            end if;
        end if;
    end process;

end;
