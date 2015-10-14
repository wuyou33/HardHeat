library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deadtime_gen is
    generic
    (
        -- Number of bits in the counter
        COUNTER_N           : positive;
        -- Amount of deadtime
        DT_VAL              : natural
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        sig_in              : in std_logic;
        sig_out             : out std_logic;
        sig_n_out           : out std_logic
    );
end entity;

architecture deadtime_gen_arch of deadtime_gen is
begin

    dt_gen_p: process(clk, reset)
        variable count      : unsigned(COUNTER_N - 1 downto 0);
        variable off        : std_logic;
        variable last_state : std_logic;
    begin
        if reset = '1' then
            sig_out <= '0';
            sig_n_out <= '0';
            off := '0';
            last_state := sig_in;
            count := (others => '0');
        elsif rising_edge(clk) then
            if sig_in = last_state then
                count := count + 1;
            else
                count := (others => '0');
            end if;
            if count <= DT_VAL then
                off := '1';
            else
                off := '0';
            end if;
            sig_out <= sig_in xor (sig_in and off);
            sig_n_out <= (not sig_in) xor (not sig_in and off);
            last_state := sig_in;
        end if;
    end process;

end;
