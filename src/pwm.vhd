library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity pwm is
    generic
    (
        -- Number of bits in the PWM counter
        COUNTER_N               : positive;
        -- Minimum modulation level (to ensure for example fans stay running)
        MIN_MOD_LVL             : positive;
        -- Number of PWM cycles (full timer) the PWM is disabled on enable
        ENABLE_ON_D             : natural
    );
    port
    (
        clk                     : in std_logic;
        reset                   : in std_logic;
        enable_in               : in std_logic;
        mod_lvl_in              : in unsigned(COUNTER_N - 1 downto 0);
        mod_lvl_f_in            : in std_logic;
        pwm_out                 : out std_logic
    );
end entity;

architecture pwm_arch of pwm is
begin

    pwm_p: process(clk, reset)
        type pwm_state is (idle, enable_on_delay, pwm);
        variable state          : pwm_state;
        variable timer          : unsigned(COUNTER_N - 1 downto 0);
        variable cycles         : unsigned(ceil_log2(ENABLE_ON_D) - 1 downto 0);
        variable mod_lvl        : unsigned(COUNTER_N - 1 downto 0);
    begin
        if reset = '1' then
            state := idle;
            timer := (others => '0');
            cycles := (others => '0');
            mod_lvl := (others => '0');
            pwm_out <= '0';
        elsif rising_edge(clk) then
            if state = idle then
                pwm_out <= '0';
                if enable_in = '1' then
                    state := enable_on_delay;
                    timer := (others => '0');
                    cycles := (others => '0');
                    pwm_out <= '1';
                end if;
            elsif state = enable_on_delay then
                if timer = 2**COUNTER_N - 1 then
                    cycles := cycles + 1;
                    if cycles >= ENABLE_ON_D then
                        state := pwm;
                        timer := (others => '0');
                    end if;
                end if;
            elsif state = pwm then
                if timer <= mod_lvl then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;
            end if;
            if enable_in = '0' then
                state := idle;
                timer := (others => '0');
            else
                timer := timer + 1;
            end if;
            if mod_lvl_f_in = '1' then
                if mod_lvl_in < MIN_MOD_LVL then
                    mod_lvl := to_unsigned(MIN_MOD_LVL, mod_lvl'length);
                else
                    mod_lvl := mod_lvl_in;
                end if;
            end if;
        end if;
    end process;

end;
