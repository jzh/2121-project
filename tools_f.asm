sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret

sleep_20ms:
	rcall sleep_5ms
	rcall sleep_5ms
	rcall sleep_5ms
	rcall sleep_5ms
	ret

sleep_100ms:
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	ret

sleep_500ms:
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	ret

; ---------------------------------------------------------
; get_input - returns keypad numbers, ASCII values of letters/symbols
; and pre-defined values of pushbuttons. behaves a bit like c scanf
; holds the program up and waits for input until it's received
get_input:
	ldl cmask, INITCOLMASK
	clr col
	cpl pressed, 1
	brne keypad_colloop

input_debouncer:
	; check for keypad presses
	lds temp1, PINL
	nop
	andi temp1, ROWMASK
	cpi temp1, ROWMASK
	brne input_debouncer

	; check for button presses
	in temp1, PINB
	andi temp1, (1<<BUT1)|(1<<BUT0)
	cpi temp1, (1<<BUT1)|(1<<BUT0)
	brne input_debouncer

	clr pressed
	jmp get_input

button_detect:
	clr temp3
	in temp1, PINB
	mov temp2, temp1
	andi temp2, (1<<BUT1)
	breq button1_pressed
	mov temp2, temp1
	andi temp2, (1<<BUT0)
	breq button0_pressed
	jmp get_input
button1_pressed: ; open
	rcall reset_fadetimer
	ldl pressed, 1
	ldi iskeypad, 1
	start_beeper
	ldi result, BUT1PRESSED
	;out PORTC, temp1
	ret
button0_pressed: ; closed
	rcall reset_fadetimer
	ldl pressed, 1
	ldi iskeypad, 1
	start_beeper
	ldi result, BUT0PRESSED
	;out PORTC, temp1
	ret

keypad_colloop:
	cpl col, 4
	breq button_detect
	sts PORTL, cmask

	rcall sleep_5ms

	lds temp1, PINL
	nop
	andi temp1, ROWMASK
	breq keypad_nextcol

	ldl rmask, INITROWMASK
	clr row

keypad_rowloop:
	cpl row, 4
	breq keypad_nextcol
	mov temp2, temp1
	and temp2, rmask
	breq keypad_parse
	inc row
	lsl rmask
	jmp keypad_rowloop

keypad_nextcol:
	lsl cmask
	sbrl cmask, 1 ; pull resistor up
	inc col
	jmp keypad_colloop

keypad_parse:
	ldl pressed, 1
	cpl col, 3
	breq keypad_letters
	cpl row, 3
	breq keypad_symbols
	mov temp1, row
	lsl temp1
	add temp1, row
	add temp1, col
	subi temp1, -1
	jmp keypad_store

keypad_letters:
	ldi temp1, 'A'
	add temp1, row
	jmp keypad_store

keypad_symbols:
	cpl col, 0
	breq keypad_star
	cpl col, 1
	breq keypad_zero
	ldi temp1, '#'
	jmp keypad_store

keypad_star:
	ldi temp1, '*'
	jmp keypad_store

keypad_zero:
	clr temp1

keypad_store:
	mov result, temp1 ; global var for determining what was pressed
	ldi iskeypad, 1
	start_beeper
	rcall reset_fadetimer

keypad_end:
	rcall sleep_5ms
	ret

reset_fadetimer:
	push temp1
	clr temp1
	sts tim3counter, temp1
	sts tim3counter+1, temp1
	ldl fadedir, INCREASING
	pop temp1
	ret

display_power:
	push temp1
	cpl power, 4
	brne power_check2
	ldi temp1, 0xFF
	jmp display_power_end
power_check2:
	cpl power, 2
	brne power_check1
	ldi temp1, 0x0F
	jmp display_power_end
power_check1:
	ldi temp1, 0x03

display_power_end:
	out PORTC, temp1
	pop temp1
	ret
