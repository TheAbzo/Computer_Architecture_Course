library ieee;
use ieee.std_logic_1164.all;

-- Prototyping PartD entity.
Entity PartD is
	port(A: in std_logic_vector(15 downTo 0); Cin, S0, S1: in std_logic; Cout: out std_logic; F: out std_logic_vector(15 downTo 0));
End Entity PartD;

-- Architecture of PartD. The implementation is done by using simple When else statements for both F(16 bits) and Cout (1 bit).
Architecture PartDImplementation of PartD is
Begin

-- Apply F output.
	F <= A(14 downTo 0) & '0' WHEN S1 = '0' and S0 = '0'
		ELSE A(14 downTo 0) & A(15) WHEN S1 = '0' and S0 = '1'
		ELSE A(14 downTo 0) & Cin   WHEN S1 = '1' and S0 = '0'
		ELSE (others => '0');

-- Apply Cout output.
	Cout <= A(15) WHEN S1 = '0' and S0 = '0'
		ELSE '0' WHEN S1 = '0' and S0 = '1'  -- Ask Here.
		ELSE A(15) WHEN S1 = '1' and S0 = '0'
		ELSE '0';

End PartDImplementation;
