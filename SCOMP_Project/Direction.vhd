-- Direction.vhd (VHDL)
-- This code controls the motor position in either direction over a range of 2 turns.
-- Bo Han Zhu
-- ECE2031 L06
-- 03/31/2021

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY Direction IS
	PORT(
		PWMCLOCK    : IN    STD_LOGIC;
		RESETN      : IN    STD_LOGIC;
		CS          : IN    STD_LOGIC;
		PWM_OUT     : OUT   STD_LOGIC;
		IN1         : OUT   STD_LOGIC;
		IN2         : OUT   STD_LOGIC;
		IO_DATA     : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END Direction;

ARCHITECTURE a OF Direction IS
    SIGNAL COMPARE  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	 SIGNAL SIGBIT   : STD_LOGIC;

    BEGIN

    IO_Handler: PROCESS (RESETN, CS)
    BEGIN
        -- Create a register to store the data sent from SCOMP
        IF (RESETN = '0') THEN
            COMPARE <= "0000000000000000";
        ELSIF rising_edge(CS) THEN
            -- When written to, latch IO_DATA into the compare register.
            COMPARE <= IO_DATA(15 DOWNTO 0);
				SIGBIT <= IO_DATA(15);
        END IF;

    END PROCESS;

    PWM_Generator: PROCESS (PWMCLOCK)
    BEGIN
		

		
		IF (rising_edge(PWMCLOCK)) THEN

			-- if within reasonable range, stop spinning
			if (COMPARE <= "0000000000001100" or COMPARE >= "1111111111110100") THEN
				PWM_OUT <= '0';
				IN1 <= '0';
				IN2 <= '0';
			-- if new degree is more than target degree, spin clockwise
			elsif (SIGBIT = '0') THEN
				PWM_OUT <= '1';
				IN1 <= '0';
				IN2 <= '1';
			-- if new degree is less than target degree, spin counter-clockwise
			elsif (SIGBIT = '1') THEN
				PWM_OUT <= '1';
				IN1 <= '1';
				IN2 <= '0';
			end if;

      END IF;
    END PROCESS;

END a;