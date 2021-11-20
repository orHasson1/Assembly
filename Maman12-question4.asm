# Title: maman 12, question 4                              Filename: question4                      
# Autor: Or Hasson                                         Date: 26/07/21
# Description: The program implements the game "Bulls and cows".

################################ DATA SEGMENT #################################
.data 
	welcomeMsg: .asciiz "\nPlease enter 3 different integers in range 1-9:\n"
	invalidInputMsg: .asciiz "\nInvalid input! Please enter again:\n"
	guessMsg: .asciiz "\nGuess my number\t\t"
	anotherGameMsg: .asciiz "\nAnother game?\t\t"
	n: .asciiz "\t\tn"
	p: .asciiz "\t\tp"
	pp: .asciiz "\t\tpp"
	ppp: .asciiz "\t\tppp"
	b: .asciiz "\t\tb"
	bb: .asciiz "\t\tbb"
	bbb: .asciiz "\t\tbbb"
	bp: .asciiz "\t\tbp"
	bbp: .asciiz "\t\tbbp"
	bpp: .asciiz "\t\tbpp"
	bool: .space 3
	guess: .space 3
	.eqv printStr 4
	.eqv charsNum 4
	.eqv readStr 8
	.eqv end 10
	.eqv readChar 12
	.eqv zero 48
	.eqv nine 57
################################ CODE SEGMENT #################################
.text
.globl main

#******************************************************************************
main: # main()
#******************
# Description:
# executes all the operations required by question 4, maman 12
#******************

	# asks the user to type 3 different integers in range 1-9
	la $a0, welcomeMsg
	li $v0, printStr
	syscall
	
	# load the arrays bool and guess from data
	la $s0, bool
	la $s1, guess

	# calls get_number(bool)
	move $a0, $s0				# the address of bool
	jal get_number
	
	# calls get_guess(bool, guess) 
	move $a0, $s0				# the address of bool
	move $a1, $s1				# the address of guess
	jal get_guess
	
	# print message that asks the player if he\she wants to start a new game
	la $a0, anotherGameMsg
	li $v0, printStr
	syscall
	
	# get an answer for the question
	li $v0, readChar
	syscall
	
	# terminates the run if the player answered no (n)
	beq $v0, 'n', exit
	
	# starts a new game if the player answered yes (y) by jumping main
	j main

#******************************************************************************
exit: # exit()
#******************
# Description:
# terminates the run
#******************

	li $v0, end
	syscall

#******************************************************************************
get_number: # get_number(bool)
#******************
# Description:
# gets 3 different integers in range '1'-'9' from the user.if the input is 
# invalid calls invalid_input. else locates the input in the array bool
#
# Input:
# $a0 - bool - an array in size 3 (fits size for the input)
#******************	

	# pushes $ra and $a0 to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sw $a0, -4($sp)
	sub $sp, $sp, 8
	
	# moves argument bool ($a0) to the register $t0
	move $t0, $a0
	
	# read the first digit given by the user
	li $v0, readChar
	syscall

	# if the digit is not an integer between '0'-'9' asks for a new input
	move $t1, $v0				# $t1 = the first digit
	blt $t1, zero, invalid_input
	bgt $t1, nine, invalid_input
	
	# read the second digit given by the user
	li $v0, readChar
	syscall
	
	# if the digit is not an integer between '0'-'9' asks for a new input
	move $t2, $v0				# $t2 = the second digit
	blt $t2, zero, invalid_input
	bgt $t2, nine, invalid_input
	
	
	# read the third digit given by the user
	li $v0, readChar
	syscall
	
	# if the digit is not an integer between '0'-'9' asks for a new input
	move $t3, $v0				# $t3 = the third digit
	blt $t3, zero, invalid_input
	bgt $t3, nine, invalid_input
	
	# if there are identical integers in the input asks for a new input
	beq $t1, $t2, invalid_input
	beq $t2, $t3, invalid_input
	beq $t1, $t3, invalid_input
	
	# stores the input in the array bool
	sb $t1, ($t0)
	addi $t0, $t0, 1
	sb $t2, ($t0)
	addi $t0, $t0, 1
	sb $t3, ($t0)
	move $v0, $t0
	
	# increments stack pointer and pops $ra and $a0 
	add $sp, $sp, 8
	lw $a0, -4($sp)
	lw $ra, 0($sp)
		
	# goes back to main	
	jr $ra

#******************************************************************************
invalid_input: # invalid_input()
#******************
# Description:
# reports the user that the input was invalid and jumps to get_number to
# receive a new input
#******************		

	# prints a message that reports that the input is invalid and asks for a new input
	la $a0, invalidInputMsg
	li $v0, printStr
	syscall
	
	# increments stack pointer and pops $ra and $a0 
	add $sp, $sp, 8
	lw $a0, -4($sp)
	lw $ra, 0($sp)
	
	# jumps to get_number to receive a new input
	j get_number

#******************************************************************************
get_guess: # get_guess(bool, guess)
#******************
# Description:
# invites the user to try to guess the 3 digits in the array bool and calls 
# compare. if compare returns -1 than the user guessed correctly the digits
# (the same digits and the same order) and the program gumps to main. else,
# get_guess is executed again.
#
# Input:
# $a0 - bool - the array with the 3 digits that the user should guess
# $a1 - guess - an array in size 3 (fits size for the input)
#
# Output:
# $v0 - -1 - indicates that the current game is over
#******************	

	# pushes $ra, $a0 and $a1 and to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sw $a0, -4($sp)
	sw $a1, -8($sp)
	sub $sp, $sp, 12

	move $t0, $a0 				# the address of bool
	move $t1, $a1 				# the address of guess
	
	# prints a message that asks the user to guess digits
	la $a0, guessMsg
	li $v0, printStr
	syscall
	
	# gets the guess of the user 
	move $a0, $t1
	li $a1, charsNum
	li $v0, readStr
	syscall
	
	# calls compare(bool, guess)
	move $a0, $t0 				# the address of bool
	move $a1, $t1 				# the address of guess
	jal compare
	
	# increments stack pointer and pops $ra, $a0 and $a1
	add $sp, $sp, 12
	lw $a1, -8($sp)
	lw $a0, -4($sp)
	lw $ra, 0($sp)
	
	beqz $v0, get_guess			# if compare returned 0 continues the current game  
	jr $ra					# else returns -1 to main to main
	
#******************************************************************************
compare: # compare(bool, guess)
#******************
# Description:
# prints output that informs the user about the success of the last attempt to
# guess the digits of bool
#
# Input:
# $a0 - bool - the array that contains 3 digits that the user should guess
# $a1 - guess - the array that contains the guess of the user
#
# Output:
# $v0 - return value - equals -1 if the user guessed all the digits in the 
#                      right order. else equals 0
#******************	

	# pushes $ra, $s0 and $s1 to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sub $sp, $sp, 12
	
	la $s0, ($a0) 				# the address of bool
	la $s1, ($a1) 				# the address of guess
	li $t0, 0    				# counterB - counts bs initialized to 0
	li $t1, 0    				# counterP - counts ps initialized to 0
	li $t2, 0    				# i - initialized to 0
	
	externalLoop: # for(i = 0; i < 3; i++)
		beq $t2, 3, reply   	 	# ends if i == 3
		li $t3, 0		  	# initializes j = 0
		add $t4, $s0, $t2		# $t4 = addrI (bool)
		lb $t5, ($t4)			# $t5 = bool[i] 
		
	internalLoop: # for(j = 0; j < 3; j++)
		beq $t3, 3, continue_external	# ends if j == 3 
		add $t6, $s1, $t3		# $t6 = addrJ (guess)
		lb $t7, ($t6)			# $t7 = guess[j] 
		
		bne $t5, $t7, continue_iternal  # if it isn't a b or a p than continues			
		beq $t2, $t3, counterB	  	# elif it's a b (i == j && bool[i] == guess[j]) than counterB++
		b counterP			# else it's a p (i != j && bool[i] == guess[j]) than counterP++ 	

	counterB:
		# executes counterB++ and jumps to the next iteration 
		addi $t0, $t0, 1
		j continue_iternal
		
	counterP:
		# executes counterP++ and jumps to the next iteration 
		addi $t1, $t1, 1
		j continue_iternal
		
	continue_external:
		addi $t2, $t2, 1	 	# i++
		j externalLoop			# continue to the next iteration of externalLoop
		
	continue_iternal:
		addi $t3, $t3, 1	 	# j++
		j internalLoop			# continue to the next iteration of internalLoop
		
	reply:
		# $v0 = return value (initialized to 0, indicates a failure)
		li $v0, 0			
		
		beqz $t0, zero_b		# if counterB = 0
		beq $t0, 1, one_b		# elif counterB = 1
		beq $t0, 2, two_b		# elif counterB = 2
		
		la $a0, bbb			# else counterB = 3 than the message ($a0) should be bbb and 
		sub $v0, $v0, 1			# the return value ($v0) should be -1 (indicates a win) 
		b done			
		
	zero_b: 				# if counterB = 0
		beqz $t1,  message_n		#	if counterP = 0 than the message should be n
		beq $t1, 1, message_p		#	elif counterP = 1 than the message should be p
		beq $t1, 2, message_pp		#	elif counterP = 2 than the message should be pp
		b message_ppp			#	else counterP = 3 than the message should be ppp
		
	one_b:					# if counterB = 1
		beqz $t1,  message_b		#	if counterP = 0 than the message should be b
		beq $t1, 1, message_bp		#	elif counterP = 1 than the message should be bp
		b message_bpp			#	else counterP = 2 than the message should be bpp
		
	two_b:					# if counterB = 2
		beqz $t1,  message_bb		#	if counterP = 0 than the message should be bb
		b message_bbp			#	else counterP = 1 than the message should be bbp		
				
	message_n:
		# updates the message ($a0) to be n and jumps 
		la $a0, n
		j done
			
	message_p:
		# prints the message p and returns 1
		la $a0, p
		j done
		
	message_pp:
		# prints the message pp and returns 1
		la $a0, pp
		j done
		
	message_ppp:
		# prints the message ppp and returns 1
		la $a0, ppp
		j done
			
	message_b:
		# prints the message b and returns 1
		la $a0, b
		j done
		
	message_bp:
		# prints the message bp and returns 1
		la $a0, bp
		j done
		
	message_bpp:
		# prints the message bpp and returns 1
		la $a0, bpp
		j done
		
	message_bb:
		# prints the message bb and returns 1
		la $a0, bb
		j done
		
	message_bbp:
		# prints the message bbp and returns 1
		la $a0, bbp
		j done
		
	done:	
		# pushes $v0 to the stack and decrenets stack pointer
		sw $v0, 0($sp)
		sub $sp, $sp, 4
		
		# prints an appropriate message 
		li $v0, printStr		
		syscall
		
		# increments stack pointer and pops $v0
		add $sp, $sp, 4
		lw $v0, 0($sp) 			# $v0 = return value

		# increments stack pointer and pops $ra, $a0 and $s0
		add $sp, $sp, 12
		lw $s1, -8($sp)
		lw $s0, -4($sp)
		lw $ra, 0($sp)
		
		# gumps back to get_guess
		jr $ra
	
