LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Entity for ALU component
-- Use this Entity for your C&A project 2017
-- Other toplevel entities will not be accepted

-- Authors: 	Muhammad Arshan ,          456678
--		Muhammad Shiraz Alam Khan, 454939

ENTITY ALU_E IS
  PORT(
    reset_n     : in std_logic;
    clk         : in std_logic;
    OperandA    : in std_logic_vector(3 downto 0);
    OperandB    : in std_logic_vector(3 downto 0);
    Operation   : in std_logic_vector(2 downto 0);
    Go          : in std_logic;
    Result_Low	: out std_logic_vector(3 downto 0);
    Result_High	: out std_logic_vector(3 downto 0);
    Completed	: out std_logic;
    Errorsig	: out std_Logic);
END ALU_E;

architecture Behavioral_ALU of ALU_E is 

begin

OPER: process(clk,reset_n) 

variable left 								: integer := 0;
variable right 								: integer := 0;
variable Sum, Subtract, Equal, Mux0, Mux1, Mux2, Mux3, Remainder	: std_logic_vector(3 downto 0) := "0000";
Variable L_Shifter, R_Shifter, MuxR					: std_logic_vector(7 downto 0) := "00000000";
variable Res0, Res1, Res2, Res3, Res4, Res5, Res6, Res7, Res8, X, Y	: std_logic_vector(3 downto 0) := "0000";
Variable Carry, Borrow, Hold_Completed, Comp				: std_logic := '0';
Variable num_L_Shift, num_R_Shift 					: std_logic_vector(2 downto 0) :="000";

begin

Completed <= Comp;

if(reset_n = '0') then
	
	Result_Low 	<= "0000";
    	Result_High 	<= "0000";
    	Comp 		:= '0';
    	Errorsig 	<= '0';

elsif (rising_edge(clk) and Comp = '0') then

	Errorsig <= '0';

	------------------
	 --No Operation--
	------------------

	if(Operation = "000") then
		if(Go = '1') then
	  		Result_Low  <= "0000";
    	  		Result_High <= "0000";
    			Comp 	    := '1';
    	  		Errorsig    <= '0';
		end if;

	------------------
	 --Equalization--
	------------------

	elsif (Operation = "001") then
		if(Go = '1') then
			for I in 0 to 3 loop
				Equal(I) := OperandA(I) xnor OperandB(I);
			end loop;
	  	  Result_Low  (3 downto 0) <=  Equal(3 downto 0);
	  	  Result_High (3 downto 0) <=  "0000";
 	  	  Comp 			   := '1';
		  Hold_Completed           := '0';

		end if;

	--------------------------------
	 --left Shifting and Rotation--
	--------------------------------

	elsif (Operation = "010") then
		if(Go = '1') then
	  		num_L_Shift := OperandB(2 downto 0);
	  	  	left := to_integer(unsigned(num_L_Shift));
	  	  	L_Shifter := "0000" & OperandA;

			--Left Shift
			if(OperandB(3) = '0') then

				for I in 1 to left loop
  	  	  		  	L_Shifter(7 downto 0) := L_Shifter(6 downto 0) & '0' ;
				end loop;

 		  	Result_Low (3 downto 0) <= L_Shifter(3 downto 0);
		  	Result_High(3 downto 0) <= L_Shifter(7 downto 4);
 	  	  	Comp 			:= '1';
			Hold_Completed 		:= '0';

			--Left Rotation
			else
				for I in 1 to left loop
	  	  			L_Shifter(7 downto 0) := L_Shifter(6 downto 0) & L_Shifter(7) ;
				end loop;

 		  	Result_Low (3 downto 0) <= L_Shifter(3 downto 0);
		  	Result_High(3 downto 0) <= L_Shifter(7 downto 4);
		  	Comp 			:= '1';
			Hold_Completed 		:= '0';

			end if;
		end if;
	
	---------------------------------
	 --Right Shifting and Rotation--
	---------------------------------

	elsif (Operation = "011") then
		if(Go = '1') then
			num_R_Shift 	:= OperandB(2 downto 0);
		  	right 		:= to_integer(unsigned(num_R_Shift));
		  	R_Shifter 	:= "0000" & OperandA;

			--Right Shift
			if(OperandB(3) = '0') then

				for I in 1 to right loop
	  	  			R_Shifter(7 downto 0) := '0' & R_Shifter(7 downto 1) ;
				end loop;

 		  	Result_Low (3 downto 0) <= R_Shifter(3 downto 0);
		  	Result_High(3 downto 0) <= R_Shifter(7 downto 4);
		  	Comp 			:= '1';
			Hold_Completed 		:= '0';

			--Right Rotation
			else
				for I in 1 to right loop
		 			R_Shifter(7 downto 0) := R_Shifter(0) & R_Shifter(7 downto 1);
				end loop;

 		  	Result_Low (3 downto 0) <= R_Shifter(3 downto 0);
		  	Result_High(3 downto 0) <= R_Shifter(7 downto 4);
		  	Comp 			:= '1';
			Hold_Completed 		:= '0';

			end if; 
		end if; 

	-----------------
	 --4-bit Adder--
	-----------------

	elsif (Operation = "100") then
		if(Go = '1') then
			for I in 0 to 3 loop
	  			Sum(I) := Carry xor (OperandA(I) xor OperandB(I));
	  			Carry  := (OperandA(I) and OperandB(I)) or (carry and (OPerandA(I) xor OPerandB(I)));
			end loop;
		  Result_Low (3 downto 0) <= Sum(3 downto 0);
		  Result_High(3 downto 0) <= "000" & Carry;
		  Comp 			  := '1';
		  Hold_Completed 	  := '0';
		end if;

	----------------------
	 --4-bit Subtractor--
	----------------------

	elsif (Operation = "101") then
		if(Go = '1') then
			--Error Signal Condition
			if(OperandB > OperandA) then
				Errorsig <= '1';
			else
		  		for I in 0 to 3 loop
	  	  			Subtract(I) := (OperandA(I) xor OperandB(I)) xor Borrow;
	  	  			Borrow      := ((not OperandA(I)) and OperandB(I)) or (Borrow and (OPerandA(I) xnor OPerandB(I)));
		  		end loop;
		  	 Result_Low (3 downto 0) <= Subtract;
		  	 Result_High(3 downto 0) <= "0000";
			end if;
		  	Comp 		:= '1';
		  	Hold_Completed  := '0';
		end if;

	----------------------
	 --4-bit Multiplier--
	----------------------

	elsif(Operation = "110") then
		if(Go = '1') then
			for I in 0 to 3 loop
	 			Mux0(I) := OperandA(I) and OperandB(0);
	 			Mux1(I) := OperandA(I) and OperandB(1);
	 	 		Mux2(I) := OperandA(I) and OperandB(2);
				Mux3(I) := OperandA(I) and OperandB(3);
			end loop; 

	 	  MuxR(0) 	   := Mux0(0);
	  	  Res0(3 downto 0) := '0' & Mux0(3 downto 1);
	  	  Res1(3 downto 0) := Mux1(3 downto 0);

			for I in 0 to 3 loop
	  			Res2(I) := Carry xor (Res0(I) xor Res1(I));
	  			Carry  := (Res0(I) and Res1(I)) or (carry and (Res0(I) xor Res1(I)));
			end loop;

	  	  MuxR(1) 	   := Res2(0);
	  	  Res3(3 downto 0) := Carry & Res2(3 downto 1);
	  	  Res4(3 downto 0) := Mux2(3 downto 0);
		  Carry := '0';
	
			for I in 0 to 3 loop
	  			Res5(I) := Carry xor (Res3(I) xor Res4(I));
	  			Carry  := (Res3(I) and Res4(I)) or (carry and (Res3(I) xor Res4(I)));
			end loop;
	
	 	  MuxR(2) 	   := Res5(0);
	 	  Res6(3 downto 0) := Carry & Res5(3 downto 1);
	 	  Res7(3 downto 0) := Mux3(3 downto 0);
		  Carry := '0';
	
			for I in 0 to 3 loop
	  			Res8(I) := Carry xor (Res6(I) xor Res7(I));
	  			Carry  := (Res6(I) and Res7(I)) or (carry and (Res6(I) xor Res7(I)));
			end loop;

	  	  MuxR(3) 	   := Res8(0);
	  	  MuxR(7 downto 4) := Carry & Res8(3 downto 1);
		  Carry := '0';

	  	  Result_Low(3 downto 0)  <= MuxR(3 downto 0);
	  	  Result_High(3 downto 0) <= MuxR(7 downto 4);
	  	  Comp			  := '1';
		  Hold_Completed	  := '0';

		end if;

	-------------------
	 --4-bit Divider--
	-------------------

	elsif(Operation = "111") then
		if(Go = '1') then
			--Error Signal COndition
			if(OperandB > OperandA or OperandB = "0000") then
				Errorsig <= '1';
			else
			  X := "0000";
			  Y := "0001";
			Remainder := OperandA;
				While Remainder >= OperandB loop
			
					Borrow := '0';
					for I in 0 to 3 loop
			  	  		Subtract(I) := (Remainder(I) xor OperandB(I)) xor Borrow;
	  	  				Borrow      := ((not Remainder(I)) and OperandB(I)) or (Borrow and (Remainder(I) xnor OPerandB(I)));
					end loop;
					Remainder := Subtract;
	
				 	Carry := '0';
					for I in 0 to 3 loop
						Sum(I) := Carry xor (X(I) xor Y(I));
	  					Carry  := (X(I) and Y(I)) or (carry and (X(I) xor Y(I)));
					end loop;
					X := Sum;
	
		
				end loop;
	   	  	
		 	  	Result_Low (3 downto 0) <= X;
		  	  	Result_High(3 downto 0) <= Remainder;

			end if;
		  	Comp 	       := '1';
		  	Hold_Completed := '0';
		end if;

	end if;

elsif(rising_edge(clk) and Comp = '1') then
	if Hold_Completed  = '1' then
      	   Hold_Completed := '0';
       	   Comp 	  := '0';
     	else
     	  Hold_Completed  := '1';
   	end if;

end if;

end process;

end Behavioral_ALU;