library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.resonant_pfd_pkg.all;
use work.tdc_pkg.all;
use work.pid_pkg.all;
use work.phase_accumulator_pkg.all;
use work.lock_detector_pkg.all;

entity adpll is
    generic
    (
        TDC_N               : positive;
        FILT_P_SHIFT_N      : integer;
        FILT_I_SHIFT_N      : integer;
        FILT_INIT_OUT_VAL   : positive;
        FILT_OUT_OFFSET     : natural;
        FILT_OUT_LIMIT      : natural;
        ACCUM_BITS_N        : positive;
        ACCUM_WORD_N        : positive;
        LD_LOCK_N           : positive;
        LD_ULOCK_N          : positive;
        LD_LOCK_LIMIT       : natural
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        ref_in              : in std_logic;
        sig_out             : out std_logic;
        lock_out            : out std_logic
    );
end entity;

architecture adpll_arch of adpll is
    signal up               : std_logic;
    signal down             : std_logic;
    signal pid_out          : signed(TDC_N - 1 downto 0);
    signal phase_time       : signed(TDC_N - 1 downto 0);
    signal tuning_word      : unsigned(ACCUM_WORD_N - 1 downto 0);
    signal sig              : std_logic;

    function trunc_to_unsigned(arg : signed) return unsigned is
    begin
        return unsigned(std_logic_vector(arg));
    end function;

    function clamp_to_unsigned(arg : signed) return unsigned is
        variable res        : unsigned(arg'high - 1 downto 0);
    begin
        -- Shift value so it is always positive
        res := trunc_to_unsigned(resize(arg + to_signed(2**(arg'length - 1) - 1
                , arg'length)
                , res'length));
        return res;
    end function;

    function clamp(arg : unsigned; limit : natural) return unsigned is
    begin
        if arg > limit then
            return to_unsigned(limit, arg'length);
        else
            return arg;
        end if;
    end function;
begin

    sig_out                 <= sig;

    pfd_p: resonant_pfd
    port map
    (
        clk                 => clk,
        reset               => reset,
        sig_in              => sig,
        ref_in              => ref_in,
        up_out              => up,
        down_out            => down
    );

    tdc_p: tdc
    generic map
    (
        COUNTER_N           => TDC_N
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        up_in               => up,
        down_in             => down,
        time_out            => phase_time
    );

    filter_p: pid
    generic map
    (
        P_SHIFT_N           => FILT_P_SHIFT_N,
        I_SHIFT_N           => FILT_I_SHIFT_N,
        BITS_N              => TDC_N,
        INIT_OUT_VAL        => FILT_INIT_OUT_VAL
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        upd_clk_in          => ref_in,
        setpoint_in         => to_signed(0, TDC_N),
        pid_in              => phase_time,
        pid_out             => pid_out
    );

    tuning_word <= clamp(shift_left(resize(clamp_to_unsigned(-pid_out)
                   , tuning_word'length)
                   , tuning_word'length - phase_time'length)
                    + to_unsigned(FILT_OUT_OFFSET
                        , tuning_word'length)
                        , FILT_OUT_LIMIT);

    phase_accumulator_p: phase_accumulator
    generic map
    (
        ACCUM_BITS_N        => ACCUM_BITS_N,
        TUNING_WORD_N       => ACCUM_WORD_N
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        tuning_word_in      => tuning_word,
        sig_out             => sig
    );

    lock_detector_p: lock_detector
    generic map
    (
        PHASE_TIME_IN_N     => TDC_N,
        LOCK_COUNT_N        => LD_LOCK_N,
        ULOCK_COUNT_N       => LD_ULOCK_N,
        LOCK_LIMIT          => LD_LOCK_LIMIT
    )
    port map
    (
        clk                 => clk,
        reset               => reset,
        phase_time_in       => phase_time,
        lock_out            => lock_out
    );

end;
