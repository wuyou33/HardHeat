library ieee;
use ieee.std_logic_1164.all;

entity resonant_pfd is
    port
    (
        -- Inputs
        clk             : in std_logic;
        reset           : in std_logic;
        sig_in          : in std_logic;
        ref_in          : in std_logic;
        -- Outputs
        up_out          : out std_logic;
        down_out        : out std_logic
    );
end resonant_pfd;

architecture resonant_pfd_arch of resonant_pfd is
    signal ff           : std_logic;
begin

    -- D-type flip-flop
    ff_p: process(clk, reset)
        variable last_sig   : std_logic;
    begin
        if reset = '1' then
            ff <= '0';
            last_sig := sig_in;
        -- FF is synchronous so we do not have to synchronize the output after
        elsif rising_edge(clk) then
            if not sig_in = last_sig and sig_in = '1' then
                ff <= ref_in;
            end if;
            last_sig := sig_in;
        end if;
    end process;

    -- Actual phase-frequency detector
    pfd_p: process(clk, reset)
        variable sig_ref_xor    : std_logic;
    begin
        if reset = '1' then
            up_out <= '0';
            down_out <= '0';
            sig_ref_xor := '0';
        elsif rising_edge(clk) then
            sig_ref_xor := sig_in xor ref_in;
            up_out <= sig_ref_xor and ff;
            down_out <= sig_ref_xor and not ff;
        end if;
    end process;

end;
