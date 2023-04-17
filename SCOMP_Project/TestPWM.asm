ORG 0

Routine:
	IN     Switches
	OUT    PWM
	IN     Quad
	OUT	   Hex0
    JUMP   Routine	
	
; IO address constants
Switches:  EQU &H000
LEDs:      EQU &H001
Timer:     EQU &H002
Hex0:      EQU &H004
Hex1:      EQU &H005
Inc:	   EQU &H0F0
Quad:      EQU &H0F1
PWM:       EQU &H0F2