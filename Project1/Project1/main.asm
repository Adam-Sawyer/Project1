;
; Project1.asm
;
; Created: 4/2/2020 1:10:17 PM
; Author : Adam
;

LDI R16, 0x00 ;Set register 16 to 0 initially. This register will store the current count.
LDI R17, 0x01 ;Set register 17 to 1 initially. This register will store the increment amount.
LDI R18, 0xFF
LDI R19, 0x00
LDI R20, 0x05 ;Set register 20 to 5 initially. This register will count the change in increment amount.
LDI R21, 0x00 ;Set register 22 to 0 initially. This register will hold the initial value

OUT DDRD, R18 ;Port D in output mode
OUT PORTD, R18 ;Turn off LEDS (active low)

OUT DDRE, R18 ;Port E in output mode

OUT DDRA, R19 ; Port A in input mode
OUT PORTA, R18

SET_INIT_VAL:
	LDI R22, 100           ;Load a counter variable to limit initialization time
    RETRY: RJMP QDELAY     
		   DEC R22         ;Decrement time
		   BRNE CHECK_SW1
		   SBIC PINA, 2    ;checks to see if button is pressed
	       RJMP RETRY
	INC R21                ;increments initial value if button is pressed
	DEC R22                ;Decrement time
	BRNE CHECK_SW1
	RJMP SET_LED2          ;displays new value to LEDs

SET_LED2:	       ; Turns on the LEDs according to value stored in R22 (The initial val register) 
	MOV R18, R21   ; R18 is used as a temporary register to store the count value
	COM R18        ; Takes Ones compliment because LEDs are active low
	OUT PORTD, R18 ; Turns LEDs on 
	RJMP RETRY
		 
CHECK_SW1:
    SBIC PINA, 0 ; Skip next instruction if PA0 gets a 0
    RJMP CHECK_SW2
    RJMP INC_CNT

CHECK_SW2:
	SBIC PINA, 1 ; Skip next instruction if PA1 gets a 0
    RJMP CHECK_SW3
    RJMP DEC_CNT
    
CHECK_SW3:
	SBIC PINA, 2 ; Skip next instruction if PA2 gets a 0
	RJMP CHG_INC
	RJMP SET_LED

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
	
CHG_INC:		; Increments the increment value by 1 or resets to 1
	INC R17
	DEC R20
	BREQ RESET
	RJMP SET_LED
	
	RESET:		; Resets the increment value to 1 and count to 5
		LDI R20, 0x05
		LDI R17, 0x01
		RJMP SET_LED

SET_LED:	       ; Turns on the LEDs according to value stored in R16 (The count register) 
	MOV R18, R16   ; R18 is used as a temporary register to store the count value
	COM R18        ; Takes Ones compliment because LEDs are active low
	OUT PORTD, R18 ; Turns LEDs on 
	RJMP CHECK_SW1

AT_MIN:			 ; Sets value of counter to 31
	LDI R16, 0x1F
	RJMP SYS_ALRM

AT_MAX:			 ; Sets value of counter to 0
	LDI R16, 0x00
	RJMP SYS_ALRM

SYS_ALRM:		 ; Sets off the system alarm
	LDI R21, 50
	LOOP1: OUT PORTE, R18
		   RJMP QDELAY
	       OUT PORTE, R19
	       RJMP QDELAY
	       DEC R21
	       BRNE CHECK_SW1
	       RJMP LOOP1
	

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
