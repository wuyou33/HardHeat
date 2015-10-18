package utils_pkg is
	function log2(Arg : natural) return natural;
	function ceil_log2(Arg : positive) return natural;
end package;

package body utils_pkg is
	---------------------------------------------------------------------------
	-- Function for calculating the base-2 logarithm
	---------------------------------------------------------------------------
	function log2(Arg : natural) return integer is
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
	function ceil_log2(Arg : positive) return natural is
		variable RetVal		: natural;
	begin
		RetVal := log2(Arg);
		-- Round up
		if (Arg > (2**RetVal)) then
			return(RetVal + 1);
		else
			return(RetVal);
		end if;
	end function ceil_log2;
end package body;
