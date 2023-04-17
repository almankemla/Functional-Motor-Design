-- QuadratureDecoder.vhd (VHDL)
-- This code defines a quadrature decoder peripheral for the SCOMP.
-- This code takes in data (1, and 0) from two magnet sensors of the Motor with Encoder (DG01D-E) and
-- increment or decrement "count" based on a two-vector sequence from the senesors and outputs the count. 
-- Bo Han Zhu
-- ECE2031 L06
-- 03/14/2021

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY QuadratureDecoder IS
	PORT(
		-- At least IO_DATA and a chip select are needed.  Even though
		-- this device will only respond to IN, IO_WRITE is included so
		-- that this device doesn't drive the bus during an OUT.
		A           : IN    STD_LOGIC; --One Magnet Sensor
		B  			: IN	  STD_LOGIC; --Other Magnet Sensor
		CLK         : IN    STD_LOGIC;
		RESETN      : IN    STD_LOGIC;
		CS          : IN    STD_LOGIC;
		IO_WRITE    : IN    STD_LOGIC;
		IO_DATA     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
	);
END QuadratureDecoder;

ARCHITECTURE a OF QuadratureDecoder IS
	SIGNAL count : STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL tri_enable : STD_LOGIC; -- enable signal for the tri-state driver
	
	TYPE state_type is (init, AB_00, AB_01, AB_11, AB_10);
	SIGNAL state : state_type;
	
	SIGNAL AB : STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL AB0 : STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL AB1 : STD_LOGIC_VECTOR(1 downto 0);
	
	BEGIN
	
	tri_enable <= CS and (not IO_WRITE); -- only drive IO_DATA during IN
	
	-- Use LPM function to create tri-state driver for IO_DATA
	IO_BUS: lpm_bustri
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => count,   -- Put the value on IO_DATA during IN
		enabledt => tri_enable,
		tridata  => IO_DATA
	);

	AB0 <= A & B;

	
	PROCESS (RESETN, CLK)
	BEGIN
		IF RESETN = '0' THEN
			count <= x"0000";
			state <= init;
		ELSIF RISING_EDGE(CLK) THEN
			
			AB <= AB1;
			AB1 <= AB0; 
		
			CASE state IS
			
				WHEN init =>
					IF AB = "00" THEN
						state <= AB_00;
					ELSIF AB = "01" THEN
						state <= AB_01;
					ELSIF AB = "10" THEN
						state <= AB_10;
					ELSIF AB = "11" THEN	
						state <= AB_11;
					END IF;
					
				WHEN AB_00 =>
					IF AB = "01" THEN
						state <= AB_01;
						count <= count + 1;
					ELSIF AB = "10" THEN
						state <= AB_10;
						count <= count - 1;
					END IF;
					
				WHEN AB_01 =>
					IF AB = "11" THEN
						state <= AB_11;
						count <= count + 1;
					ELSIF AB = "00" THEN
						state <= AB_00;
						count <= count - 1;
					END IF;
				
				WHEN AB_11 =>
					IF AB = "10" THEN
						state <= AB_10;
						count <= count + 1;
					ELSIF AB = "01" THEN
						state <= AB_01;
						count <= count - 1;
					END IF;
				
				WHEN AB_10 =>
					IF AB = "00" THEN
						state <= AB_00;
						count <= count + 1;
					ELSIF AB = "11" THEN
						state <= AB_11;
						count <= count - 1;
					END IF;
				
				WHEN OTHERs =>
					state <= init;
					
			END CASE;
					
		END IF;
	END PROCESS;

END a;

