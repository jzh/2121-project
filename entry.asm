entry_mode:
	cpl pmode, ENTRYMODE	
	breq skip_initialisation
	do_lcd_command 0b00000001
	ldl numpressed, 0
	ldl enterpl, 0
	ldl power, 4
	clr minutes
	clr seconds

skip_initialisation:
	cpi result, '*'
	brne entry_mode_type	
	cpl numpressed, 0
	brne nofix
	ldl minutes, 1
nofix:
	ldl mode, RUNNINGMODE
	jmp entry_mode_end	

entry_mode_type:
	cpl enterpl, 1
	brne normal_entry_mode

	cpi result, 3	
	brne plentry_check2
	ldl power, 4
plentry_check2:
	cpi result, 2
	brne plentry_check1
	ldl power, 2
plentry_check1:
	cpi result, 1	
	brne plentry_end
plentry_end:
	cpi result, '#'
	breq exit_time
	jmp entry_mode_end
exit_time:
	ldl enterpl, 0
	do_lcd_command 0b00000001
	jmp entry_normal_mode_end

normal_entry_mode:
	cpi result, 'B'
	brlt entry_checkhash
	jmp entry_normal_mode_end
entry_checkhash:
	cpi result, '#'
	brne entry_checkA
	ldl pmode, FINISHMODE
	jmp TheEndOfAll

entry_checkA:
	cpi result, 'A'
	breq switch_modes
	jmp digit_input
switch_modes:
	ldl enterpl, 1
	do_lcd_command 0b10000000
	do_lcd_data_im 'S'
	do_lcd_data_im 'e'
	do_lcd_data_im 't'
	do_lcd_data_im ' '
	do_lcd_data_im 'P'
	do_lcd_data_im 'o'
	do_lcd_data_im 'w'
	do_lcd_data_im 'e'
	do_lcd_data_im 'r'
	do_lcd_data_im ' '
	do_lcd_data_im '1'
	do_lcd_data_im '/'
	do_lcd_data_im '2'
	do_lcd_data_im '/'
	do_lcd_data_im '3'
	jmp entry_mode_end		
	
digit_input:
	cpl numpressed, 4
	brlt add_digit
	jmp entry_normal_mode_end
add_digit:
	inc numpressed
	ldi temp2, 10
	mul minutes, temp2
	mov minutes, r0
	mov temp1, seconds
	divide temp1, temp2, temp3	
	add minutes, temp1
	ldi temp3, 10
	mul temp2, temp3
	mov seconds, r0
	add seconds, result		
	
entry_normal_mode_end:
	print_time

entry_mode_end:
	ldl pmode, ENTRYMODE
TheEndOfAll:
	ret
