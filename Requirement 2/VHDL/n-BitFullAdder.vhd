library ieee;
use ieee.std_logic_1164.all;

--Genereic n bit adder entity.
-- Inputs A, B, Cin. 
-- Outputs S, Cout.
Entity NBitAdder is 
	Generic (n : integer := 16);
	Port(A, B: in std_logic_vector(n-1 downTo 0); Cin: in std_logic; S: out std_logic_vector(n-1 downTo 0); Cout: out std_logic);
End Entity NBitAdder;

Architecture NBitAdderImplementation of NBitAdder is
	Component OneBitAdder
	Port(a, b: in std_logic; cin: in std_logic; s, cout: out std_logic);
	End Component;
	Signal temp: std_logic_vector(n-1 downTo 0); -- To store intermediate and final carry bits.
Begin
	-- Generating the n adders.
	generatingLoop: FOR i IN 0 TO n-1 Generate

		-- Generate the least significant adder.
		generateLeastSignificant: IF i = 0 Generate
			Az: OneBitAdder PORT MAP (A(i), B(i), Cin, S(i), temp(i));
		End Generate generateLeastSignificant;
		
		-- Generate the other adders.
		generateOthers: IF i > 0 Generate
			Ao: OneBitAdder PORT MAP (A(i), B(i), temp(i-1), S(i), temp(i));
		End Generate generateOthers;
	
	End Generate generatingLoop;

	-- Assign the carry out.
	Cout <= temp(n-1);

End NBitAdderImplementation;
