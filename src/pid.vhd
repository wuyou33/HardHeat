library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity pid is
    generic
    (
        -- Coefficients are shifted left is positive and right if negative
        -- Proportional coefficient
        P_SHIFT_N           : integer;
        -- Integral coefficient
        I_SHIFT_N           : integer;
        -- Number of bits in the filter
        BITS_N              : positive;
        -- Initial output value
        INIT_OUT_VAL        : natural
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        upd_clk_in          : in std_logic;
        setpoint_in         : in signed(BITS_N - 1 downto 0);
        pid_in              : in signed(BITS_N - 1 downto 0);
        pid_out             : out signed(BITS_N - 1 downto 0)
    );
end entity;

architecture pid_arch of pid is
begin

    pid_p: process(clk, reset)
        variable step           : std_logic;
        variable setpoint_err   : signed(BITS_N - 1 downto 0);
        variable prop           : signed(BITS_N + 2 downto 0);
        variable integral       : signed(BITS_N + 2 downto 0);
        variable sum            : signed(BITS_N + 2 downto 0);
        variable last_state     : std_logic;
    begin
        if reset = '1' then
            step := '0';
            pid_out <= to_signed(INIT_OUT_VAL, pid_out'length);
            setpoint_err := (others => '0');
            integral := (others => '0');
            sum := (others => '0');
            last_state := '0';
        elsif rising_edge(clk) then
            if not upd_clk_in = last_state and upd_clk_in = '1' then
                setpoint_err := setpoint_in - pid_in;
                if P_SHIFT_N < 0 then
                    prop := shift_right(resize(setpoint_err, prop'length)
                                , -P_SHIFT_N);
                else
                    prop := shift_left(resize(setpoint_err, prop'length)
                                , P_SHIFT_N);
                end if;
                integral := integral + setpoint_err;
                -- Stop integrating to precent windup
                if integral > 2**(integral'length - 1) - 1 then
                    integral := to_signed(2**(integral'length - 1) - 1
                        , integral'length);
                elsif integral < -2**(integral'length - 1) - 1 then
                    integral := to_signed(-2**(integral'length - 1) - 1
                        , integral'length);
                end if;
                if I_SHIFT_N < 0 then
                    sum := prop + shift_right(integral, -I_SHIFT_N);
                else
                    sum := prop + shift_left(integral, I_SHIFT_N);
                end if;
                if sum > 2**pid_out'length - 1 then
                    sum := to_signed(2**(pid_out'length) - 1, sum'length);
                elsif sum < -2**pid_out'length - 1 then
                    sum := to_signed(-2**(pid_out'length) - 1, sum'length);
                end if;
                step := '1';
            elsif step = '1' then
                pid_out <= resize(sum, pid_out'length);
                step := '0';
            end if;
            last_state := upd_clk_in;
        end if;
    end process;

end;
