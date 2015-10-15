library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity epdm is
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        -- Modulation level input, supports five pulse density levels
        mod_lvl_in          : in unsigned(2 downto 0);
        mod_lvl_in_f        : in std_logic;
        -- Signal in, should have 50% duty cycle so no deadtime etc.
        sig_in              : in std_logic;
        -- Left high-side switch etc.
        sig_lh_out          : out std_logic;
        sig_ll_out          : out std_logic;
        sig_rh_out          : out std_logic;
        sig_rl_out          : out std_logic
    );
end entity;

architecture epdm_arch of epdm is
begin

    epdm_p: process(clk, reset)
        variable count          : unsigned(3 downto 0);
        variable last_state     : std_logic;
        variable skip           : std_logic;
    begin
        if reset = '1' then
            sig_lh_out <= '0';
            sig_ll_out <= '0';
            sig_rh_out <= '0';
            sig_rl_out <= '0';
            count := (others => '0');
            last_state := sig_in;
            skip := '1';
        elsif rising_edge(clk) then
            -- New modulation level, reset counter
            if mod_lvl_in_f = '1' then
                count := (others => '0');
            end if;
            if not sig_in = last_state then
                -- Count on rising and falling edge
                if sig_in = '1' then
                    count := count + 1;
                elsif sig_in = '0' then
                    count := count + 1;
                end if;
                -- Skip every sixth cycle
                if to_integer(mod_lvl_in) = 3 then
                    if count = 6 then
                        skip := '1';
                    else
                        skip := '0';
                    end if;
                -- Skip every fourth cycle
                elsif to_integer(mod_lvl_in) = 2 then
                    if count mod 4 = 0 then
                        skip := '1';
                    else
                        skip := '0';
                    end if;
                -- Skip every second cycle
                elsif to_integer(mod_lvl_in) = 1 then
                    if count mod 2 = 0 then
                        skip := '1';
                    else
                        skip := '0';
                    end if;
                -- Skip every cycle except every fourth
                elsif to_integer(mod_lvl_in) = 0 then
                    if not (count mod 4 = 2) then
                        skip := '1';
                    else
                        skip := '0';
                    end if;
                -- No skipping, full power
                else
                    skip := '0';
                end if;
                -- Reset counter
                if count = 12 then
                    count := (others => '0');
                end if;
            end if;
            if skip = '1' then
                sig_lh_out <= '0';
                sig_ll_out <= '1';
                sig_rh_out <= '0';
                sig_rl_out <= '1';
            else
                sig_lh_out <= sig_in;
                sig_ll_out <= not sig_in;
                sig_rh_out <= not sig_in;
                sig_rl_out <= sig_in;
            end if;
            last_state := sig_in;
        end if;
    end process;

end;
