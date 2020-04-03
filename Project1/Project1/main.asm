;
; Project1.asm
;
; Created: 4/2/2020 1:10:17 PM
; Author : Adam
;

LDI R16, 0x00 ;Set register 16 to 0 initially. This register will store the current count.
LDI R17, 0x01 ;Set register 17 to 1 initially. This register will store the increment amount.
LDI R18, 0xFF

OUT DDRD, R18 ;Port D in output mode
OUT PORTD, R18 ;Turn off LEDS (active low)

OUT DDRA, R19 ; Port A in input mode
OUT PORTA, R18
	 
CHECK_SW1:
    SBIC PINA, 0 ; Skip next instruction if PA0 gets a 0
    RJMP CHECK_SW2
    RJMP INC_CNT

CHECK_SW2:
	SBIC PINA, 1 ; Skip next instruction if PA0 gets a 0
    RJMP SET_LED
    RJMP DEC_CNT

INC_CNT:		 ; Increases the count by the value of the counter
	ADD R16, R17
	RJMP CHK_VAL

DEC_CNT:		 ; Decreases the count by the value of the counter
	SUB R16, R17
	RJMP CHK_VAL

CHK_VAL:		 ; Checks if max value has been reached
	SBIS PIND, 7
	RJMP AT_MIN
	SBIS PIND, 5
	RJMP AT_MAX
	RJMP SET_LED

SET_LED:	       ; Turns on the LEDs according to value stored in R16 (The count register) 
	MOV R18, R16   ; R18 is used as a temporary register to store the count value
	COM R18        ; Takes Ones compliment because LEDs are active low
	OUT PORTD, R18 ; Turns LEDs on 
	RJMP CHECK_SW1

AT_MIN:			 ; Sets value of counter to 31
	LDI R16, 0x1F
	;RJMP SYS_ALRM

AT_MAX:			 ; Sets value of counter to 0
	LDI R16, 0x00
	;RJMP SYS_ALRM

SYS_ALRM:		 ; Sets off the system alarm
	RJMP CHECK_SW1
	

QDELAY: 
	LDI R23, 255
	AGAIN3: LDI R22, 255
			AGAIN2:LDI R21, 25 
				AGAIN1:NOP 
					   DEC R21 
					   BRNE AGAIN1          
				DEC R22
				BRNE AGAIN2
			DEC R23
			BRNE AGAIN3
