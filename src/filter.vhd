library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Very simple first order (RC) loop filter based on bit shifts only
entity filter is
    generic
    (
        -- Proportional path, input value multiplied by 2^ALPHA_SHIFT_N
        ALPHA_SHIFT_N       : natural;
        -- Integral path, input value multiplied by 2^-BETA_SHIFT_N and added
        -- to last cycle result (last_beta) of the same sum
        BETA_SHIFT_N        : natural;
        -- Number of bits in the input of the filter (signed), input is shifted
        -- so it is halfway of the filter input to be always positive
        IN_N                : positive;
        -- Number of output bits (unsigned)
        OUT_N               : positive;
        -- Initial value for the tuning word after reset, with 0 no output
        INIT_OUT_VAL        : positive
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        filt_in             : in signed(IN_N downto 0);
        filt_out            : out unsigned(OUT_N - 1 downto 0)
    );
end entity;

architecture filter_arch of filter is
    signal last_beta        : unsigned(OUT_N - 1 downto 0);
begin

    filter_p: process(clk, reset)
        variable shifted    : unsigned(IN_N downto 0);
        variable temp       : std_logic_vector(IN_N + 1 downto 0);
        variable alpha      : unsigned(OUT_N - 1 downto 0);
        variable beta       : unsigned(OUT_N - 1 downto 0);
    begin
        if reset = '1' then
            filt_out <= to_unsigned(INIT_OUT_VAL, OUT_N);
            alpha := to_unsigned(0, OUT_N);
            beta := to_unsigned(0, OUT_N);
            last_beta <= to_unsigned(0, OUT_N);
        elsif rising_edge(clk) then
            -- Extend size to fit the result
            temp := std_logic_vector(
                resize(filt_in, IN_N + 2) + to_signed(2**12 / 2, IN_N + 2));
            -- Convert to unsigned, drop the sign bit
            shifted := unsigned(temp(temp'high - 1 downto 0));
            -- Perform shifts
            alpha := resize(shifted, OUT_N) sll ALPHA_SHIFT_N;
            beta := (resize(shifted, OUT_N) srl BETA_SHIFT_N) + last_beta;
            last_beta <= beta;
            filt_out <= alpha + beta;
        end if;
    end process;

end;
