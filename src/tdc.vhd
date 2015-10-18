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
    signal sign         : std_logic;
begin

    -- D-type flip-flop generating the sign-bit for the output
    sign_ff_p: process(down_in, reset)
    begin
        if reset = '1' then
            sign <= '0';
            sign_out <= sign;
        elsif rising_edge(down_in) then
            sign <= up_in;
            sign_out <= sign;
        end if;
    end process;

    tdc_p: process(clk, reset)
        variable sig_or     : std_logic;
        variable last_state : std_logic;
        variable count      : signed(COUNTER_N downto 0);
    begin
        if reset = '1' then
            time_out <= (others => '0');
            count := (others => '0');
            last_state := '0';
        elsif rising_edge(clk) then
            sig_or := up_in or down_in;
            sig_or_out <= sig_or;
            -- Count when the or signal is high, sign comes from flip-flop
            if sig_or = '1' then
                count := count + 1;
            else
                if last_state = '1' then
                    time_out <= count;
                    -- Add the sign
                    time_out(time_out'high) <= sign;
                    count := (others => '0');
                end if;
            end if;
            last_state := sig_or;
        end if;
    end process;

end tdc_arch;
