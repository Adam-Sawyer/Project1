;
; Project1.asm
;
; Created: 4/2/2020 1:10:17 PM
; Author : Saul Lynn, Shane McEnaney, Pamela Petterchak, Adam Sawyer
;

LDI R16, 0x00 ;Set register 16 to 0 initially. This register will store the current count.
LDI R17, 0x01 ;Set register 17 to 1 initially. This register will store the increment amount.
LDI R18, 0xFF
LDI R19, 0x00
LDI R20, 0x05 ;Set register 20 to 5 initially. This register will count the change in increment amount.
LDI R21, 0x00 ;Set register 22 to 0 initially. This register will hold the initial value
LDI R26, 0x1F

OUT DDRD, R18 ;Port D in output mode
OUT PORTD, R18 ;Turn off LEDS (active low)

OUT DDRE, R18 ;Port E in output mode

OUT DDRA, R19 ; Port A in input mode
OUT PORTA, R18 ; enable pull-ups on PA

INIT:
	CALL SET_INIT_VAL
	CALL SET_LEDS
	WAIT_UNTIL_REL0: ; Waits until release of button to continue
		SBIS PINA, 4 ; Skip next instruction if PA2 gets a 0
		RJMP WAIT_UNTIL_REL0
	CALL QDELAY

MAIN:
	CHECK_UP:
		SBIC PINA, 5 ; Skip next instruction if PA0 gets a 0
		RJMP CHECK_DOWN
		CP R16, R26
		BREQ COUNT_MAX
		CALL INC_CNT
		CALL SET_LEDS
		CALL QDELAY
		RJMP MAIN

	CHECK_DOWN:
		SBIC PINA, 6 ; Skip next instruction if PA1 gets a 0
		RJMP CHECK_RESET
		CP R19, R16
		BREQ COUNT_MIN
		CALL DEC_CNT
		CALL SET_LEDS
		CALL QDELAY
		RJMP MAIN
    
	CHECK_RESET:
		SBIC PINA, 4 ; Skip next instruction if PA2 gets a 0
		RJMP CHECK_STOPWATCH_MODE
		CALL RESET_COUNT
		CALL SET_LEDS
		CALL QDELAY
		RJMP MAIN

	CHECK_STOPWATCH_MODE:
		SBIC PINA, 7 ; Skip next instruction if PA2 gets a 0
		RJMP MAIN
		WAIT_UNTIL_REL:
			SBIS PINA, 7 ; Skip next instruction if PA2 gets a 0
			RJMP WAIT_UNTIL_REL
		CALL QDELAY
		CALL STOPWATCH_MODE
		RJMP MAIN

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CALL CUSTOM FUNCTIONS HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;CHECK_CUSTOM1
		;CALL CUSTOM1

	;CHECK_CUSTOM2
		;CALL CUSTOM2

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	COUNT_MAX:
		CALL RESET_COUNT
		CALL SET_LEDS
		CALL SYS_ALARM
		CALL QDELAY
		RJMP MAIN

	COUNT_MIN:
		CALL SET_COUNT
		CALL SET_LEDS
		CALL SYS_ALARM
		CALL QDELAY
		RJMP MAIN
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; COMMON FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RESET_COUNT:
	MOV R16, R19
	RET

SET_COUNT:
	MOV R16, R26
	RET

INC_CNT:		 ; Increases the count by the value of the counter
	ADD R16, R17
	RET

DEC_CNT:		 ; Decreases the count by the value of the counter
	ADD R16, R18
	CLC
	RET

SET_LEDS:	       ; Turns on the LEDs according to value stored in R16 (The count register) ; Turns on the LEDs according to value stored in R22 (The initial val register) 
	MOV R27, R16   ; R18 is used as a temporary register to store the count value
	COM R27        ; Takes Ones compliment because LEDs are active low
	OUT PORTD, R27 ; Turns LEDs on 
	RET

SYS_ALARM:		 ; Sets off the system alarm
	LDI R25, 2
	LOOP1:
		OUT PORTE, R18
		CALL QDELAY
	    OUT PORTE, R19
	    CALL QDELAY
	    DEC R25
	    BRNE LOOP1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CALL CUSTOM FUNCTIONS HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SET_INIT_VAL:
	IN R16, PINA;
	COM R16
	RET

	;; ----- EVERTHING ELSE IN THIS FUNCTION BELOW LOOKS LIKE IT CAN BE DELETE -----

	;LDI R22, 100           ;Load a counter variable to limit initialization time
    ;RETRY: RJMP QDELAY     
		   ;DEC R22         ;Decrement time
		   ;BRNE CHECK_SW1
		   ;SBIC PINA, 7    ;checks to see if button is pressed
	       ;RJMP RETRY
	;INC R21                ;increments initial value if button is pressed
	;DEC R22                ;Decrement time
	;BRNE CHECK_SW1
	;CALL SET_LEDS          ;displays new value to LEDs
	;RET

;SET_LED2:	       ; Turns on the LEDs according to value stored in R22 (The initial val register) 
;	MOV R18, R21   ; R18 is used as a temporary register to store the count value
;	COM R18        ; Takes Ones compliment because LEDs are active low
;	OUT PORTD, R18 ; Turns LEDs on 
;	RJMP RETRY

;; ---------------------------------------------------------------------------------
	
CHG_INC:		; Increments the increment value by 1 or resets to 1
	INC R17
	DEC R20
	BREQ RESET2
	;CALL SET_LED
	RET
	
	RESET2:		; Resets the increment value to 1 and count to 5
		LDI R20, 0x05
		LDI R17, 0x01
		;CALL SET_LED
		RET

STOPWATCH_MODE:
	CALL RESET_COUNT
	CALL SET_LEDS
	CBI PORTD, 7 ;
	UP:
		SBIC PINA, 5 ; Skip next instruction if PA0 gets a 0
		RJMP DOWN
		WAIT_UNTIL_REL1:
			SBIS PINA, 5 ; Skip next instruction if PA2 gets a 0
			RJMP WAIT_UNTIL_REL1
		L1:
			CP R16, R26
			BREQ STOP_RESET
			CALL INC_CNT
			CALL SET_LEDS
			CBI PORTD, 7 ; LED 6 already being used
			CALL QDELAY
			SBIC PINA, 5 ; Skip next instruction if PA0 gets a 0
			RJMP L1
			RJMP WAIT

	DOWN:
		SBIC PINA, 6 ; Skip next instruction if PA1 gets a 0
		RJMP STOP_RESET
		WAIT_UNTIL_REL2:
			SBIS PINA, 6 ; Skip next instruction if PA2 gets a 0
			RJMP WAIT_UNTIL_REL2
		L2:
			CP R19, R16
			BREQ STOP_RESET
			CALL DEC_CNT
			CALL SET_LEDS
			CBI PORTD, 7 ; LED 6 already being used
			CALL QDELAY
			SBIC PINA, 6 ; Skip next instruction if PA1 gets a 0
			RJMP L2
			RJMP WAIT
    
	STOP_RESET:
		CBI PORTD, 7 ; LED 6 already being used
		SBIC PINA, 4 ; Skip next instruction if PA2 gets a 0
		RJMP EXIT_STOPWATCH
		CALL RESET_COUNT
		CALL SET_LEDS
		CBI PORTD, 7 ; LED 6 already being used
	
	WAIT:
		CBI PORTD, 7 ; LED 6 already being used
		CALL QDELAY
	
	EXIT_STOPWATCH:
		SBIC PINA, 7 ; Skip next instruction if PA2 gets a 0
		RJMP UP
		WAIT_UNTIL_REL3:
			SBIS PINA, 7 ; Skip next instruction if PA2 gets a 0
			RJMP WAIT_UNTIL_REL3
		SBI PORTD, 7 ; LRF1 TURNED OFF
		CALL QDELAY
		RET
	

QDELAY: 
	LDI R23, 255
	AGAIN3:
		LDI R22, 255
		AGAIN2:
			LDI R21, 10 ; set to 10 to spped up testing; calculated in report at 25
			AGAIN1:
				NOP 
				DEC R21 
				BRNE AGAIN1          
			DEC R22
			BRNE AGAIN2
		DEC R23
		BRNE AGAIN3
	RET
