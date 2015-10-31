library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.debounce_pkg.all;

entity rpm_counter is
    generic
    (
        BITS_N                  : positive;
        MIN_RPM_LIM             : natural;
        DEBOUNCE_D              : natural
    );
    port
    (
        clk                     : in std_logic;
        reset                   : in std_logic;
        rpm_in                  : in std_logic;
        rpm_out                 : out unsigned(BITS_N - 1 downto 0);
        rpm_out_f               : out std_logic;
        fault_out               : out std_logic
    );
end entity;

architecture rpm_counter_arch of rpm_counter is
    signal rpm                  : std_logic;
begin

    debounce_p: debounce
	generic map
	(
		DEBOUNCE_D			=> DEBOUNCE_D,
        FLIPFLOPS_N         => 5
	)
	port map
	(
		clk					=> clk,
        reset               => reset,
		sig_in				=> rpm_in,
		sig_out				=> rpm
	);

    rpm_p: process(clk, reset)
        variable counter        : unsigned(BITS_N - 1 downto 0);
        variable last_state     : std_logic;
    begin
        if reset = '1' then
            rpm_out <= (others => '0');
            fault_out <= '0';
            rpm_out_f <= '0';
            counter := (others => '0');
            last_state := '0';
        elsif rising_edge(clk) then
            rpm_out_f <= '0';
            -- Indicate a fault if counter reaches maximum value
            if counter = 2**counter'length - 1 then
                fault_out <= '1';
            else
                counter := counter + 1;
            end if;
            if not rpm = last_state and rpm = '1' then
                if counter > MIN_RPM_LIM then
                   fault_out <= '1';
                else
                    fault_out <= '0';
                end if;
                rpm_out <= counter;
                rpm_out_f <= '1';
                counter := (others => '0');
            end if;
            last_state := rpm;
        end if;
    end process;

end;
