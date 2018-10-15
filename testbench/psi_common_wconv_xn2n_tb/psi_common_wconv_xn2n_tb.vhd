------------------------------------------------------------------------------
--  Copyright (c) 2018 by Paul Scherrer Institute, Switzerland
--  All rights reserved.
--  Authors: Oliver Bruendler
------------------------------------------------------------------------------

------------------------------------------------------------
-- Testbench generated by TbGen.py
------------------------------------------------------------
-- see Library/Python/TbGenerator

------------------------------------------------------------
-- Libraries
------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;

library work;
	use work.psi_common_math_pkg.all;
	use work.psi_common_logic_pkg.all;
	use work.psi_tb_txt_util.all;

------------------------------------------------------------
-- Entity Declaration
------------------------------------------------------------
entity psi_common_wconv_xn2n_tb is
end entity;

------------------------------------------------------------
-- Architecture
------------------------------------------------------------
architecture sim of psi_common_wconv_xn2n_tb is
	-- *** Fixed Generics ***
	constant InWidth_g : natural := 16;
	constant OutWidth_g : natural := 4;
	
	-- *** Not Assigned Generics (default values) ***
	
	-- *** TB Control ***
	signal TbRunning : boolean := True;
	signal NextCase : integer := -1;
	signal ProcessDone : std_logic_vector(0 to 1) := (others => '0');
	constant AllProcessesDone_c : std_logic_vector(0 to 1) := (others => '1');
	constant TbProcNr_stim_c : integer := 0;
	constant TbProcNr_check_c : integer := 1;
	
	-- *** DUT Signals ***
	signal Clk : std_logic := '0';
	signal Rst : std_logic := '1';
	signal InVld : std_logic := '0';
	signal InRdy : std_logic := '0';
	signal InData : std_logic_vector(InWidth_g-1 downto 0) := (others => '0');
	signal OutVld : std_logic := '0';
	signal OutRdy : std_logic := '0';
	signal OutData : std_logic_vector(OutWidth_g-1 downto 0) := (others => '0');
	
	-- user stuff --
	signal done : boolean := False;
	signal testcase : integer := -1;
	
	procedure ApplyInput(StartValue : in integer; signal InData : out std_logic_vector) is
	begin
		for i in 0 to 3 loop
			InData(3+i*4 downto i*4) <= std_logic_vector(to_unsigned(i+StartValue, 4));
		end loop;
	end procedure;
	
	procedure CheckOutput(StartValue : in integer; offset : in integer) is
	begin
		assert unsigned(OutData) = StartValue+offset report "###ERROR###: received wrong output " & to_string(to_integer(unsigned(OutData))) & " instead of " & to_string(StartValue+offset) severity error;
	end procedure;
	
begin
	------------------------------------------------------------
	-- DUT Instantiation
	------------------------------------------------------------
	i_dut : entity work.psi_common_wconv_xn2n
		generic map (
			InWidth_g => InWidth_g,
			OutWidth_g => OutWidth_g
		)
		port map (
			Clk => Clk,
			Rst => Rst,
			InVld => InVld,
			InRdy => InRdy,
			InData => InData,
			OutVld => OutVld,
			OutRdy => OutRdy,
			OutData => OutData
		);
	
	------------------------------------------------------------
	-- Testbench Control !DO NOT EDIT!
	------------------------------------------------------------
	p_tb_control : process
	begin
		wait until Rst = '0';
		wait until ProcessDone = AllProcessesDone_c;
		TbRunning <= false;
		wait;
	end process;
	
	------------------------------------------------------------
	-- Clocks !DO NOT EDIT!
	------------------------------------------------------------
	p_clock_Clk : process
		constant Frequency_c : real := real(100e6);
	begin
		while TbRunning loop
			wait for 0.5*(1 sec)/Frequency_c;
			Clk <= not Clk;
		end loop;
		wait;
	end process;
	
	
	------------------------------------------------------------
	-- Resets
	------------------------------------------------------------
	p_rst_Rst : process
	begin
		wait for 1 us;
		-- Wait for two clk edges to ensure reset is active for at least one edge
		wait until rising_edge(Clk);
		wait until rising_edge(Clk);
		Rst <= '0';
		wait;
	end process;
	
	
	------------------------------------------------------------
	-- Processes
	------------------------------------------------------------
	-- *** stim ***
	p_stim : process
	begin
		-- start of process !DO NOT EDIT
		wait until Rst = '0';
		
		-- Test Single Serialization
		print(">> Single Serialization");
		testcase <= 0;
		wait until rising_edge(Clk);
		for del in 0 to 3 loop
			InVld <= '1';
			ApplyInput(del*2, InData);
			wait until rising_edge(Clk);
			InVld <= '0';
			wait for 1 ns;
			assert InRdy = '0' report "###ERROR###: InRdy did not go low" severity error;
			for j in 0 to 10 loop
				wait until rising_edge(Clk);
			end loop;
			wait until rising_edge(Clk);
		end loop;
		if done /= true then
			wait until done = true;
		end if;
		
		-- Test Streaming Serialization
		print(">> Streaming Serialization");
		testcase <= 1;
		wait until rising_edge(Clk);
		InVld <= '1';
		for del in 0 to 3 loop	
			for data in 0 to 2 loop
				ApplyInput(del+data, InData);
				wait until rising_edge(Clk) and InRdy = '1';
			end loop;
		end loop;
		if done /= true then
			wait until done = true;
		end if;
				
		-- end of process !DO NOT EDIT!
		ProcessDone(TbProcNr_stim_c) <= '1';
		wait;
	end process;
	
	-- *** check ***
	p_check : process
	begin
		-- start of process !DO NOT EDIT
		wait until Rst = '0';
		
		-- Test Single Serialization
		wait until testcase = 0;
		done <= False;		
		for del in 0 to 3 loop
			for i in 0 to 3 loop
				OutRdy <= '1';
				wait until rising_edge(Clk) and OutVld = '1';
				CheckOutput(2*del, i);
				for j in 0 to del-1 loop
					OutRdy <= '0';
					wait until rising_edge(Clk);
				end loop;
			end loop;
		end loop;
		done <= True;
		
		-- Test Streaming Serialization
		wait until testcase = 1;
		done <= False;
		for del in 0 to 3 loop
			for data in 0 to 2 loop
				for i in 0 to 3 loop
					OutRdy <= '1';
					wait until rising_edge(Clk) and OutVld = '1';
					CheckOutput(del+data, i);
					for j in 0 to del-1 loop
						OutRdy <= '0';
						wait until rising_edge(Clk);
					end loop;
				end loop;
			end loop;
		end loop;
		done <= True;
		
		-- end of process !DO NOT EDIT!
		ProcessDone(TbProcNr_check_c) <= '1';
		wait;
	end process;
	
	
end;
