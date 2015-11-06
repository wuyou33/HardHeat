library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rpm_counter_tb is
    generic
    (
        BITS_N              : natural   := 20;
        MIN_RPM_LIM         : natural   := 2**18;
        TEST_RPM            : natural   := 2**16
    );
end entity;

architecture rtl of rpm_counter_tb is

    -- Main clock frequency 100 MHz
    constant CLK_PERIOD     : time := 1 sec / 10e7;

    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    signal rpm              : std_logic;
    signal fault            : std_logic;

begin

    reset <= '1', '0' after 500 ns;

    clk_gen: process(clk)
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end process;

    DUT_inst: entity work.rpm_counter(rtl)
    generic map
    (
        BITS_N              => BITS_N,
        MIN_RPM_LIM         => 2**18,
        DEBOUNCE_D          => 10000
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        rpm_in              => rpm,
        fault_out           => fault
    );

    rpm_gen: process(clk, reset)
        variable counter    : unsigned(BITS_N - 1 downto 0);
        variable start_done : boolean;
    begin
        if reset = '1' then
            counter := (others => '0');
            rpm <= '1';
            start_done := false;
        elsif rising_edge(clk) then
            if start_done then
                counter := counter + 1;
            -- Wait until we get fault indication for no RPM
            elsif fault = '1' then
                start_done := true;
            end if;
            if counter > TEST_RPM then
                rpm <= not rpm;
                counter := (others => '0');
            end if;
        end if;
    end process;

end;
