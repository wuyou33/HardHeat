library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils_pkg is
	function log2(Arg : natural) return natural;
	function ceil_log2(Arg : natural) return natural;
    function shift_right_vec(Arg : std_logic_vector; Num : positive)
        return std_logic_vector;
    function shift_left_vec(Arg : std_logic_vector; Num : positive)
        return std_logic_vector;
    function shift_right_vec(   Arg : std_logic_vector;
                                Num : positive;
                                NewBit : std_logic)
        return std_logic_vector;
    function shift_left_vec(    Arg : std_logic_vector;
                                Num : positive;
                                NewBit : std_logic)
        return std_logic_vector;
end package;

package body utils_pkg is
	---------------------------------------------------------------------------
	-- Function for calculating the base-2 logarithm
	---------------------------------------------------------------------------
	function log2(Arg : natural) return natural is
		variable temp    	: integer := Arg;
		variable ret_val 	: integer := 0;
	begin
		while temp > 1 loop
			ret_val := ret_val + 1;
			temp    := temp / 2;
		end loop;
		return ret_val;
	end function;
	---------------------------------------------------------------------------
	-- Function for calculating the minimum number of bits to represent Arg
	---------------------------------------------------------------------------
	function ceil_log2(Arg : natural) return natural is
		variable RetVal		: natural;
	begin
		RetVal := log2(Arg);
		-- Round up
		if (Arg > (2**RetVal)) then
			return(RetVal + 1);
		else
			return(RetVal);
		end if;
	end function;
	---------------------------------------------------------------------------
	-- Shift an std_logic_vector right
	---------------------------------------------------------------------------
    function shift_right_vec(Arg : std_logic_vector; Num : positive)
        return std_logic_vector is
    begin
        return(std_logic_vector(shift_right(unsigned(Arg), Num)));
    end function;
	---------------------------------------------------------------------------
	-- Shift an std_logic_vector left
	---------------------------------------------------------------------------
    function shift_left_vec(Arg : std_logic_vector; Num : positive)
        return std_logic_vector is
    begin
        return(std_logic_vector(shift_left(unsigned(Arg), Num)));
    end function;
	---------------------------------------------------------------------------
	-- Shift an std_logic_vector right and put new bit to 'high
	---------------------------------------------------------------------------
    function shift_right_vec(   Arg : std_logic_vector;
                                Num : positive;
                                NewBit : std_logic) return std_logic_vector is
        variable vec        : std_logic_vector(Arg'range);
    begin
        vec := std_logic_vector(shift_right(unsigned(Arg), Num));
        vec(vec'high) := NewBit;
        return(vec);
    end function;
	---------------------------------------------------------------------------
	-- Shift an std_logic_vector left and put new bit to 'low
	---------------------------------------------------------------------------
    function shift_left_vec(    Arg : std_logic_vector;
                                Num : positive;
                                NewBit : std_logic) return std_logic_vector is
        variable vec        : std_logic_vector(Arg'range);
    begin
        vec := std_logic_vector(shift_left(unsigned(Arg), Num));
        vec(vec'low) := NewBit;
        return(vec);
    end function;
end package body;
