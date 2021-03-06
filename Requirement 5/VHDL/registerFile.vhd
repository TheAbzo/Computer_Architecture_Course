library ieee;
use ieee.std_logic_1164.all;

Entity RegisterFile is
	Generic (n : integer :=16);
	port (Clk, Rst: in std_logic; InternalBus: inout std_logic_vector(15 downTo 0));
End RegisterFile;

Architecture StructuralModel of RegisterFile is
	Component RomWithCounter is
		Generic (n: integer := 9);
		port( Clk : In std_logic; Rst: In std_logic; DataOut : out std_logic_vector(n-1 downTo 0));
	End Component;

	Component Ram is
		Generic (n: integer := 16);
		port( Clk : In std_logic; We  : In std_logic; Address : In  std_logic_vector(5 downTo 0); DataIn  : In  std_logic_vector(15 downTo 0); DataOut : out std_logic_vector(15 downTo 0));
	End Component;

	Component RegisterWithBus is 
		Generic (n: integer := 16);
		port(InternalBus: inout std_logic_vector(n-1 downTo 0); Clk, Rst, WriteEnable, ReadEnable: in std_logic); -- Write Enable means write a value to this register (i.e. Dest).
	End Component;
	
	Component MARRegister is 
		Generic (n: integer := 16);
		port(InternalBus: inout std_logic_vector(n-1 downTo 0); RamAddress: out std_logic_vector(n-1 downTo 0); Clk, Rst, WriteEnable, ReadEnable: in std_logic);
	End Component;

	Component MDRRegister is 
		Generic (n: integer := 16);
		port(InternalBus: inout std_logic_vector(n-1 downTo 0); RamOutput: in std_logic_vector(n-1 downTo 0); RamInput: out std_logic_vector(n-1 downTo 0); Clk, Rst, WriteEnable, ReadEnable, RamWriteEnable: in std_logic);	End Component;
	
	Component ThreeToEightDecoder is 
		port(Enable, S2, S1, S0: in std_logic; F: out std_logic_vector(7 downTo 0));
	End Component;
	
	-- ROM
	Signal RomOutput: std_logic_vector(8 downTo 0);
	-- Src and Dest.
	Signal Src, Dest: std_logic_vector(3 downTo 0);
	Signal SrcDecoderOutput, DestDecoderOutput: std_logic_vector(7 downTo 0);
	-- RAM.
	Signal RamClk, RamWriteEnable: std_logic;
	Signal RamAddress: std_logic_vector(5 downto 0);
	Signal RamInput, RamOutput, MAROutput: std_logic_vector(n-1 downto 0);
	-- The four registers Clk.
	Signal Temp0,Temp1,Temp2,Temp3, Temp4: std_logic;

BEGIN
	-- ROM.
	ROMBLOCK: RomWithCounter GENERIC MAP (n=>9) PORT MAP(Clk, Rst, RomOutput);

	-- ROM instructions [1-bit WE, 8 bits: Src enable and Src, Dest enable and Dest].
	Dest <= RomOutput(3 downTo 0);
	Src <= RomOutput(7 downTo 4);
	RamWriteEnable <= RomOutput(8);
	
	-- RAM.
	RamClk <= (not Clk);
	RamAddress <= MAROutput(5 downTo 0);
	RAMBLOCK: Ram GENERIC MAP (n=>16) PORT MAP(RamClk, RamWriteEnable, RamAddress, RamInput, RamOutput);
	
	-- MAR and MDR registers.
	MAR: MARRegister GENERIC MAP (n=>16) PORT MAP(InternalBus, MAROutput, Temp4, Rst, DestDecoderOutput(4), SrcDecoderOutput(4));
	MDR: MDRRegister GENERIC MAP (n=>16) PORT MAP(InternalBus, RamOutput, RamInput, Clk, Rst, DestDecoderOutput(5), SrcDecoderOutput(5), RamWriteEnable);

	-- Src and Dest Decoders.
	srcDecoder: ThreeToEightDecoder PORT MAP(Src(3), Src(2), Src(1), Src(0), SrcDecoderOutput);
	DestDecoder: ThreeToEightDecoder PORT MAP(Dest(3), Dest(2), Dest(1), Dest(0), DestDecoderOutput);

	-- The Four Registers (Ax, Bx, Cx & Dx). 
	Temp0 <= Clk and DestDecoderOutput(0);  -- Used to write only to prevent passing Z to other registers.
	Temp1 <= Clk and DestDecoderOutput(1);
	Temp2 <= Clk and DestDecoderOutput(2);
	Temp3 <= Clk and DestDecoderOutput(3);
	Temp4 <= ClK and DestDecoderOutput(4);

	AX: RegisterWithBus GENERIC MAP (n=>16) PORT MAP(InternalBus, temp0, Rst, DestDecoderOutput(0), SrcDecoderOutput(0));
	BX: RegisterWithBus GENERIC MAP (n=>16) PORT MAP(InternalBus, temp1, Rst, DestDecoderOutput(1), SrcDecoderOutput(1));
	CX: RegisterWithBus GENERIC MAP (n=>16) PORT MAP(InternalBus, temp2, Rst, DestDecoderOutput(2), SrcDecoderOutput(2));
	DX: RegisterWithBus GENERIC MAP (n=>16) PORT MAP(InternalBus, temp3, Rst, DestDecoderOutput(3), SrcDecoderOutput(3));
	
End StructuralModel;

