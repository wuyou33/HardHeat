library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity debounce is
	generic
	(
        -- Debounce time in clock cycles
		DEBOUNCE_D			: natural;
        FLIPFLOPS_N         : positive
	);
	port
	(
		clk					: in std_logic;
        reset               : in std_logic;
		sig_in				: in std_logic;
		sig_out				: out std_logic
	);
end entity;

architecture rtl of debounce is

    signal flipflops        : std_logic_vector(FLIPFLOPS_N - 1 downto 0);
	signal timer_set		: std_logic;
	signal timer    		: unsigned(ceil_log2(DEBOUNCE_D) downto 0);

begin

	timer_set <= flipflops(flipflops'high) xor flipflops(flipflops'high - 1);

	process(clk, reset)
	begin
        if reset = '1' then
            flipflops <= (others => '0');
            timer <= (others => '0');
            sig_out <= '0';
		elsif rising_edge(clk) then
            flipflops <= shift_left_vec(flipflops, 1, sig_in);
            -- Reset counter, input is changing
			if timer_set = '1' then
				timer <= (others => '0');
			elsif timer < DEBOUNCE_D then
				timer <= timer + 1;
            else
				sig_out <= flipflops(flipflops'high);
			end if;
		end if;
	end process;

end;
