running_mode:
	cpi result, '#'
	breq running_printtime
	jmp running_checkopen
running_printtime:
	ldi temp1, 0	
	sts pausetype, temp1
	ldl mode, PAUSEMODE
	jmp running_mode_end

running_checkopen:
	cpl open, 1
	breq running_printtime2
	jmp running_checkStart
running_printtime2:
	ldi temp1, 1
	sts pausetype, temp1
	ldl mode, PAUSEMODE
	jmp running_mode_end

running_checkStart:
	cpi result, '*'
	brne running_checkC
	inc minutes
running_checkC:
	cpi result, 'C'
	brne running_checkD
	ldi temp1, 30
	add seconds, temp1
	cpl seconds, 127
	brlo check_max_case
	cpl minutes, 98
	brlt notcapped
	ldl minutes, 99
	ldl seconds, 99
	jmp check_max_case
notcapped:
	inc minutes
	ldi temp1, 60
	sub seconds, temp1
running_checkD:
	cpi result, 'D'
	brne check_max_case
	ldi temp1, 30
	sub seconds, temp1

check_max_case:
	cpl minutes, 99
	brlt running_seconds_of
	cpl seconds, 100
	brlt check_careful
	ldl minutes, 99
	ldl seconds, 99
	jmp running_mode_end

check_careful:
	cpl seconds, 0
	brlt running_seconds_uf
	jmp running_minutes_of

running_seconds_of:
	cpl seconds, 61
	brlt running_seconds_uf
	inc minutes
	ldi temp1, 60
	sub seconds, temp1
	cpl seconds, 61
	brlt running_seconds_uf
	inc minutes
	ldi temp1, 60
	sub seconds, temp1
	
running_seconds_uf:
	cpl seconds, 0
	brge running_minutes_of
	dec minutes
	ldi temp1, 60
	add seconds, temp1
	
running_minutes_of:
	cpl minutes, 100
	brlt running_minutes_uf
	ldl minutes, 99
	cpl seconds, 40
	brlt normal_add
	ldl seconds, 99
	jmp running_mode_end
normal_add:
	ldi temp1, 60
	add seconds, temp1

running_minutes_uf:
	cpl minutes, 0
	brge running_mode_end
	ldl minutes, 0
	ldl seconds, 0	

running_mode_end:
	print_time	
	ldl pmode, RUNNINGMODE
	ret
	
