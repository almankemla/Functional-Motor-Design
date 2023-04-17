-- PWM_GEN.VHD (a peripheral module for SCOMP)
-- 2021.03.20
--
-- Generates a square wave with duty cycle dependant on value
-- sent from SCOMP.

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY PWM_GEN IS
    PORT(PWMCLOCK,
        RESETN,
        CS       : IN STD_LOGIC;
        IO_DATA  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PWM_OUT  : OUT STD_LOGIC
    );
END PWM_GEN;

ARCHITECTURE a OF PWM_GEN IS
    SIGNAL COUNT    : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL COMPARE  : STD_LOGIC_VECTOR(3 DOWNTO 0);

    BEGIN

    IO_Handler: PROCESS (RESETN, CS)
    BEGIN
        -- Create a register to store the data sent from SCOMP
        IF (RESETN = '0') THEN
            COMPARE <= "0000";
        ELSIF rising_edge(CS) THEN
            -- When written to, latch IO_DATA into the compare register.
            COMPARE <= IO_DATA(3 DOWNTO 0);
        END IF;

    END PROCESS;

    PWM_Generator: PROCESS (PWMCLOCK)
    BEGIN

        -- Something to consider (eventually): should anything happen at reset?
		  -- Answer for now: reset doesn't do anything

		  -- Hard coding "0000" to guarantee not driving the motor at "0000" -- (Bohan did this, feel free to change)
		  IF (COMPARE = "0000") THEN
				PWM_OUT <= '0';
        -- Create a counter and a comparator that control the output
        ELSIF (rising_edge(PWMCLOCK)) THEN

            COUNT <= COUNT + 1;

            -- todo: on compare match, set the output low.
				IF (COUNT = COMPARE) THEN
					PWM_OUT <= '0';
				END IF;

            -- todo: on overflow, set the output high
				IF (COUNT = "1111") THEN
					PWM_OUT <= '1';
				END IF;

            -- Something to consider (eventually): What will happen in edge cases, 
            -- like the compare register being 1111?  What makes sense to happen?
				-- Answer for now: The compare register right now at "1111" spins without brakes

        END IF;
    END PROCESS;

END a;