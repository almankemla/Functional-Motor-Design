; Starting code with basic constants and simple subroutine

ORG 0
	LOAD   	Degrees     	;Put the value into AC
	CALL   	ToEncoding  	;Sent the value in AC to ToEncoding, which convert degrees to count
Start:
	IN     Quad		;Quad peripheral is responsible for providing the current position 
	OUT    Hex0		;We can put Hex0 here, so the user can see the position (count) changing in real time
	SUB    Encoding		;Subtract the current position from the targeted position
	OUT    Dir		;The difference is sent to Direction Peripheral via IO_DATA, which is latch to COMPARE
	OUT    Hex1		;I was thinkning we can display the -12 or 12 onto Hex1, since it's always something between F4 and C, so we only need two display for this. 
	JUMP   Start		;The loop repeat until COMPARE value is within the range of -12 < x < 12 counts. 


; Takes a degree value and transforms it into Quadrature Encoder cpr.
; This process essentially takes a number and multiplies it by 3/2
ToEncoding:
	ADD    	Degrees
	ADD	Degrees
	SHIFT  -1
	STORE 	Encoding
	RETURN


; Variables
Degrees:   DW 2880 ;negative = CW, positive = CCW
Encoding:  DW 0

; Useful values
PWMHigh:   DW &H000F

; IO address constants
Switches:  EQU &H000
LEDs:      EQU &H001
Timer:     EQU &H002
Hex0:      EQU &H004
Hex1:      EQU &H005
Inc:	   EQU &H0F0
Quad:      EQU &H0F1
PWM:       EQU &H0F2
Dir:       EQU &H0F3
