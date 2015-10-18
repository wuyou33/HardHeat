library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tdc is
    generic
    (
        -- Number of bits in the counter
        COUNTER_N       : positive
    );
    port
    (
        clk             : in std_logic;
        reset           : in std_logic;
        up_in           : in std_logic;
        down_in         : in std_logic;
        time_out        : out signed(COUNTER_N downto 0);
        sig_or_out      : out std_logic;
        sign_out        : out std_logic
);
end tdc;

architecture tdc_arch of tdc is
begin

    tdc_p: process(clk, reset)
        variable sig_or     : std_logic;
        variable last_or    : std_logic;
        variable last_up    : std_logic;
        variable last_down  : std_logic;
        variable sign       : std_logic;
        variable count      : signed(COUNTER_N downto 0);
    begin
        if reset = '1' then
            time_out <= (others => '0');
            count := (others => '0');
            last_or := '0';
            last_up := up_in;
            last_down := down_in;
            sign := '0';
            sign_out <= sign;
        elsif rising_edge(clk) then
            if not up_in = last_up and up_in = '1' then
                sign := '1';
                sign_out <= sign;
            elsif not down_in = last_down and down_in = '1' then
                sign := '0';
                sign_out <= sign;
            end if;
            last_up := up_in;
            last_down := down_in;
            sig_or := up_in or down_in;
            sig_or_out <= sig_or;
            -- Count when the or signal is high
            if sig_or = '1' then
                count := count + 1;
            else
                if last_or = '1' then
                    -- Apply sign
                    if sign = '1' then
                        time_out <= not count + 1;
                    else
                        time_out <= count;
                    end if;
                    count := (others => '0');
                end if;
            end if;
            last_or := sig_or;
        end if;
    end process;

end tdc_arch;
