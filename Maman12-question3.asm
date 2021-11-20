# Title: maman 12, question 3                               Filename: question3                       
# Autor: Or Hasson                                          Date: 26/07/21
# Description: The program performs several types of string manipulations and comparison.

################################ DATA SEGMENT #################################
.data 
	welcomeMsg: .asciiz "\nPlease enter some words: "
	invalidInputMsg: .asciiz "\nInvalid input! Please enter again:\n"
	msg1: .asciiz "\nNumber of words = "
	msg2: .asciiz "\nLetters in longest word = "
	msg3: .asciiz "\nLetters in shortest word = "
	msg4: .asciiz "\nDifference = "
	msg5: .asciiz "\nTotal number of letters = "
	msg6: .asciiz "\nThe longest word = "
	msg7: .asciiz "\nThe shortest word = " 
	StringBuffer: .space 0
	
	.eqv printNum 1		# system call code to print an integer
	.eqv printStr 4		# system call code to print a string
	.eqv readStr 8		# system call code to read a string
	.eqv nextLine 10	# ASCII code of '\n' (dec)
	.eqv exit 10 		# system call code to exit
	.eqv printChar 11	# system call code to print a char
	.eqv space 32		# ASCII code of ' ' (dec)
	.eqv A 65		# ASCII code of 'A' (dec)
	.eqv inputMaxLen 81	# the maximal length of the input string (80 chars + null)
	.eqv Z 90		# ASCII code of 'Z' (dec)
	.eqv a 97		# ASCII code of 'a' (dec)
	.eqv z 122		# # ASCII code of 'z' (dec)
	
################################ CODE SEGMENT #################################
.text
.globl main

#******************************************************************************
main: # main()
#******************
# Description:
# executes all the operations required by question 3, maman 12
#
# Register Usage:
# $v0 - returned value of subroutines
# $a0 - argument for called subroutines
# $a1 - argument for called subroutines
# $s0 - str - input string
# $s1 - maxWordLen - the number of letters of the last longest word in the
#                    input string
# $s2 - minWordLen - the number of letters of the last shortest word in the 
#                    input string
#
# Called Procedures:
# print
# get_input
# words_num
# longerst_word_len
# shortest_word_len
# longest_shortest_diff
# word_start
# word_print
#******************

	# prints welcome message
	la $a0, welcomeMsg
	li $a1, printStr
	jal print	
	
	# gets an input string (meets the required conditions by question 3) and saves
	# it for future usages
	jal get_input
	move $s0, $v0
	
	# finds and reports the number of words of the input string and saves it for
	# future usage
	la $a0, msg1
	li $a1, printStr
	jal print
	move $a0, $s0		# calls word_num with the input string as an argument
	jal words_num
	move $a0, $v0
	li $a1, printNum
	jal print
	move $s2, $v0
	
	# finds and reports the length of the longest word of the input string
	# and saves it for future usages
	la $a0, msg2
	li $a1, printStr
	jal print
	move $a0, $s0		# calls longerst_word_len with the input string as an argument
	jal longerst_word_len
	move $s1, $v0
	move $a0, $s1		
	li $a1, printNum
	jal print
	
	# finds and reports the length of the shortest word of the input string
	# and saves it for future usages
	la $a0, msg3
	li $a1, printStr
	jal print
	move $a0, $s0		# calls shortest_word_len with the input string as an argument
	jal shortest_word_len
	move $s2, $v0
	move $a0, $s2
	li $a1, printNum
	jal print
	
	# finds and reports the difference of lengths between shortest and the 
	# longest word of the input string
	la $a0, msg4
	li $a1, printStr
	jal print
	move $a0, $s1		# calls longest_shortest_diff  with longestWordLen and 
	move $a1, $s2           # shortestWordLen as arguments
	jal longest_shortest_diff
	move $a0, $v0
	li $a1, printNum
	jal print
	
	# finds and reports the number of letters of the input string
	la $a0, msg5
	li $a1, printStr
	jal print
	move $a0, $s0		# calls letters_num with the input string as an argument
	jal letters_num		
	move $a0, $v0
	li $a1, printNum
	jal print
	
	# finds and prints the longest word of the input string (the 
	# last one if there is more than one)
	la $a0, msg6
	li $a1, printStr
	jal print
	move $a0, $s0		# calls word_start with str and longestWordLen as arguments
	move $a1, $s1		# and receives the address of the first letter of the of the
	jal word_start          # last longest word of str
	move $a0, $v0		# calls word_print with the address of the first letter of 
	jal word_print	        # the required word and the word and it prints it
	
	# finds and prints the shortest word of the input string (the 
	# last one if there is more than one)
	la $a0, msg7
	li $a1, printStr
	jal print 
	move $a0, $s0		# calls word_start with str and shortestWordLen as arguments
	move $a1, $s2		# and receives the address of the first letter of the of the
	jal word_start          # last shortest word of str
	move $a0, $v0		# calls word_print with the address of the first letter of 
	jal word_print	        # the required word and the word and it prints it
	
	# terminates the run 
	li $v0, exit
	syscall
	
#******************************************************************************	
get_input: # get_input()
#******************
# Description:
# returns a valid input string from the user (valid according to the conditions
# of question 3, maman 12). the validation of the input string is tested and if 
# it's invalid the user is asked to type a new string and tests the new string.
#
# Register Usage:
# $v0 - return value - holds a valid input string
#       **before the validation test is a system call code 
# $a0 - argument for a system call
# $a1 - argument for a system call
# $t0 - str - the input string (not necessarily legal)
# $t1 - i - index of loop0
# $t2 - addrI - holds the i char of str (start from 0)
# $t3 - str[i] - the i char of str (start from 0)
# $t4 - str[i+1] - the i+1 char of str (start from 0)
# $t5 - if str[i] > 'Z' than 1, else 0 (comparison of the ASCII dec values)
# $t6 - if str[i] < 'a' than 1, else 0 (comparison of the ASCII dec values)
# $t7 - if 'Z' < str[i] < 'a' than 1, else 0 (comparison of the ASCII dec val)
#******************	

	# pushes $ra to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sub $sp, $sp, 4
	
	# gets a input string
	la $a0, StringBuffer
	li $a1, inputMaxLen
	li $v0, readStr
	syscall
	move $t0, $a0 
	
	# initialized i = 0 
	li $t1, 0 	
	
	loop0:
		# updates addrI ($t2), str[i] ($t3) and str[i+1] ($t4) for the value of i
		add $t2, $t0, $t1      
		lb $t3, 0($t2) 
		lb $t4, 1($t2) 
		
		# if the str[i] ($t3) is a space
		beq $t3, space, curr_space0
		
		# elif the whole string has been scanned 
		beq $t3, nextLine, curr_next0
		
		# elif the current line isn't a valid letter
		sgt $t5, $t3, Z
		slti $t6, $t3, a
		and $t7, $t5, $t6
		bnez $t7, invalid_input
		blt $t3, A, invalid_input
		bgt $t3, z, invalid_input
		
		# else continue to test the validation of str
		b continue0
		
	curr_space0:
		# if there are two consecutive spaces in the input string than it is invalid  
		beq $t3, $t4, invalid_input
		
		# elif the last char in the in the input string is a space than it is invalid 
		beq $t4, nextLine, invalid_input
		
		# elif the first char of the input string is a space
		beqz $t1, invalid_input 
		
		# else than continue the loop
		b continue0
		
	curr_next0:
		# if the input string is empty than it is invalid
		beqz $t1, invalid_input
		
		# else than the entire string was found to be legal
		b done0
		
	continue0:
		# increments i ($t1) and starts a new iteration
		addi $t1, $t1, 1
		j loop0	
		
	invalid_input:	
		# updates the user that the string input is invalid and asks for a new string 
		la $a0, invalidInputMsg
		li $a1, printStr
		jal print
		
		# incremens stack pointer and pops $ra
		add $sp, $sp, 4
		lw $ra, 0($sp)
		
		# gets a new string input and test its validation 
		j get_input
	
	done0:	
		# increments stack pointer and pops $ra
		add $sp, $sp, 4
		lw $ra, 0($sp)
		
		# moves the input string to $v0
		move $v0, $t0
		
		# goes back to main
		jr $ra
		
#******************************************************************************	
words_num: # get_input(str)
#******************
# Description:
# receives a valid string and returns the number of words in it
#
# Register Usage:
# $v0 - return value - holds the number of words in str
# $a0 - argument str 
# $t0 - i - index of loop1 
# $t1 - wordsNum - the number of words in str 
# $t2 - addrI - the address of str[i] 
# $t3 - str[i]
# $s0 - str - the string 
#******************	
	
	# pushes $ra and $s0 and $s0 to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sw $s0, -4($sp)
	sub $sp, $sp, 8
	
	# move the argument (str) to the registe
	move $s0, $a0
	
	# i ($t0) is initialized to 0 and wordNum (t1) initialized to 1. 
	li $t0, 0 		
	li $t1, 1		

	# during the loop $t1 (wordsNum) will be incremented by the number of spaces
	# in the input string (the number of words is one plus the number of spaces)
	loop1:
		# updates addrI ($t2) and str[i] ($t3) for the current i 
		add $t2, $s0, $t0
		lb $t3, 0($t2)	
		
		# if we already scanned all the chars of str		
		beqz $t3, done1 
		
		# elif str[i] ($t3) is a space 	
		beq $t3, space, counter1	
		j continue1
			
	counter1:
		# increments the wordsNum ($t1) and jump to continue1
		addi $t1, $t1, 1
		j continue1 	
		
	continue1:
		# increments i ($t0) and continues to the next iteration of loop1
		addi $t0, $t0, 1	
		j loop1
		
	done1:	
		# moves wordsNum ($t1) in str to $v0
		move $v0, $t1	
		
		# increments stack pointer and pops $ra and $s0
		add $sp, $sp, 8
		lw $s0, -4($sp)
		lw $ra, 0($sp)
		
		# goes back to main	
		jr $ra
		 
#******************************************************************************
longerst_word_len: # longest_word_len(str)
#******************
# Description:
# receives a valid string and returns the number of letters of the last longest word
# in the input string
#
# Register Usage:
# $v0 - return value - holds the number of letters of the longest word in str
# $a0 - argument str
# $t0 - i - index of loop2 
# $t1 - currWordLen - the length of the word that it's last letter is str[i-1]
# $t2 - maxWordLen - the longest word in the substring str[0,i]
# $t3 - addrI - the address of str[i] 
# $t4 - str[i]
# $s0 - str - the input string
#******************	

	# pushes $ra and $s0 and $s0 to the stack and  decrenets stack pointer
	sw $ra, 0($sp)
	sw $s0, -4($sp)
	sub $sp, $sp, 8
	
	# move the argument (str) to the registe
	move $s0, $a0
	
	# initialises i ($t0), currWordLen ($t1) and maxWordLen ($t2) to 0
	li $t0, 0  
	li $t1, 0 		
	li $t2, 0		

	loop2:
		# updates addrI ($t3) and str[i] ($t4) for the current i value
		add $t3, $t0, $s0  
		lb $t4, 0($t3)  
		
		# if we reached the end of str 
		beqz $t4, done2
		
		# elif str[i] is a space or '\n' we reached the end of the current word
		beq $t4, space, word_end2
		beq $t4, nextLine, word_end2
		
		# else str[i] is a letter of the current word 
		j counter2
		
	done2:
		# moves maxWordLen ($t2) to $v0
		move $v0, $t2	
		
		# increments stack pointer and pops $ra and $s0
		add $sp, $sp, 8
		lw $s0, -4($sp)
		lw $ra, 0($sp)
		
		# goes back to main	
		jr $ra
	
	word_end2:
		# if currWordLen ($t1) is longer than maxWordLen ($t2)
		bgt $t1, $t2, update_max2
		
		# the next char opens a new word 
		j word_start2
		
	update_max2:
		# updates maxWordLen ($t2) to currWordLen ($t1)
		move $t2, $t1
		
		# the next char opens a new word 
		j word_start2
		
	word_start2:
		# initializes currWordLen ($t1) to zero for the new word and jump to 
		# continue2
		move $t1, $zero	
		j continue2
	
	counter2:
		# increments the currWordLen ($t1) and jump to continue2
		addi $t1, $t1, 1
		j continue2
		
	continue2:	
		# increments i ($t0) and continues to the next iteration of loop2
		addi $t0, $t0, 1
		j loop2
		
	
	
#******************************************************************************			
shortest_word_len: # shortest_word_len(str)
#******************
# Description:
# receives a valid string and returns the number of letters of the last shortest 
# word in the input string 
#
# Register Usage:
# $v0 - return value - holds the number of letters of the shortest word in str
# $a0 - argument str 
# $t0 - i - index of loop3 
# $t1 - currWordLen - the length of the word that it's last letter is str[i-1]
#       substring str[0,i]
# $t2 - minWordLen - the shortest word in the substring str[0,i]
# $t3 - addrI - the address of str[i] 
# $t4 - str[i] 
# $s0 - str - the input string
#******************	

	# pushes $ra and $s0 and $s0 to the stack and  decrenets stack pointer
	sw $ra, 0($sp)
	sw $s0, -4($sp)
	sub $sp, $sp, 8
	
	# move the argument (str) to the register $s0
	move $s0, $a0
	
	# i ($t0) will be initalized to 0
	li $t0, 0
	
	# initialises currWordLen ($t1) to 0 and minWordLen ($t2) to 81, the maximal
	# posible length to a word in str		
	li $t1, 0 
	li $t2, inputMaxLen		
	
	loop3:
		# updates addrI ($t3) and str[i] ($t4) for the current i value
		add $t3, $t0, $s0
		lb $t4, 0($t3)
		
		# if we reached the end of str 
		beqz $t4, done3
		
		# elif str[i] is a space or '\n' we reached the end of the current word
		beq $t4, space, word_end3
		beq $t4, nextLine, word_end3
		
		# else str[i] is a letter of the current word 
		j counter3
		
	done3:
		# moves wordsNum ($t2) to $v0
		move $v0, $t2	
		
		# increments stack pointer and pops $ra and $s0
		add $sp, $sp, 8
		lw $s0, -4($sp)
		lw $ra, 0($sp)
		
		# goes back to main	
		jr $ra
		
	word_end3:
		# if currWordLen ($t1) is shorter than minWordLen ($t2)
		blt $t1, $t2, update_min3
		
		# the next char opens a new word 
		j word_start3
		
	update_min3:
		# updates minWordLen ($t2) to currWordLen ($t1)
		move $t2, $t1
		
		# the next char opens a new word 
		j word_start3
		
	word_start3:
		# initializes currWordLen ($t1) to zero for the new word and jump to continue3
		move $t1, $zero	
		j continue3
		
	counter3:
		# increments the currWordLen ($t1) and jump to continue3
		addi $t1, $t1, 1
		j continue3
		
	continue3:	
		# increments i ($t0) and continues to the next iteration of loop3
		addi $t0, $t0, 1
		j loop3


#******************************************************************************
 longest_shortest_diff: # longest_shortest_diff(longestWordLen, sortestWordLen)
#******************
# Description:
# gets the number of letters of the longest word in a valid string
# (longestWordLen) and the number of letters of the shortest word in it
# (shortestWordLen) and  returns the difference between them 
#
# Register Usage:
# $v0 - return value - holds the difference between the number of letters in 
#                      the longest word of the input string and the number of
#		       the letters in the shortest word of it
# $a0 - argument maxWordLen - the number of letters of the longest word in the string
# $a1 - argument minWordLen - the number of letters of the shortest word in the string
#******************
	# pushes $ra to the stack and  decrenets stack pointer
	sw $ra, 0($sp)
	sub $sp, $sp, 4
	
	# execute: return value ($v0) =  maxWordLen ($a0) - minWordLen ($a1)
	sub $v0, $a0, $a1
		
	# increments stack pointer and pops $ra
	add $sp, $sp, 4
	lw $ra, 0($sp)
		
	# goes back to main	
	jr $ra
#******************************************************************************
letters_num: # letters_num(str)
#******************
# Description:
# receives a valid string and returns the number of letters in the input string 
#
# Register Usage:
# $v0 - return value - holds the number of letters in the input string 
# $a0 - argument str
# $t0 - i - index of loop4
# $t1 - counter - the number of words in the substring str[0,i]
# $t2 - addrI - the address of str[i] 
# $t3 - str[i] 
# $s0 - str - the input string
#******************		
	
	# pushes $ra and $s0 to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sw $s0, -4($sp)
	sub $sp, $sp, 8
	
	# move the argument (str) to the register $s0
	move $s0, $a0
	
	# initialize i ($t0) and counter ($t1) to 0
	li $t0, 0 		
	li $t1, 0 
	
	loop4:
		# addrI ($t2) and str[i] ($t3) for the current i value
		add $t2, $t0, $s0
		lb $t3, 0($t2)
		
		# if we reached the end of str 
		beq $t3, nextLine, curr_next4
		
		# elif str[i] is a space
		beq $t3, space, continue4
		
		# else str[i] is a letter
		b counter4

	curr_next4:
		# moves the number of words (the counter) in str to $v0
		move $v0, $t1	
		
		# increments stack pointer and pops $ra and $s0
		add $sp, $sp, 8
		lw $s0, -4($sp)
		lw $ra, 0($sp)
		
		# goes back to main	
		jr $ra
	
	counter4:
		# increments the counter ($t1) and jump to continue4
		addi $t1, $t1, 1
		j continue4
		
	continue4:	
		# increments i ($t0) and continues to the next iteration of loop4
		addi $t0, $t0, 1
		j loop4

#******************************************************************************
word_start: # word_start(str, len)
#******************
# Description:
# receives a string (str) and a length of a word in it (len) and
# returns the first letter of the last word in the string in this length
# 
# Register Usage:
# $v0 - return value - the first letter of the last word in length len
# $a0 - argument str
# $a1- argument len

# $t0 - i - index of loop5
# $t1 - currWordLen - the number of letter in the last word of the substring 
#                     str[0,i]
# $t2 - addrI - the address of str[i] 
# $t3 - str[i]
# $t4 - addrEndW - the address of th first letter of the last word in length
#                  len in the substring str[0,i]
# $s0 - str - the string 
# $s1 - len - the number of letters of a word in str
#******************
		
	# pushes $ra, $s0 and $s1 to the stack and decrenets stack pointer
	sw $ra, 0($sp)
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sub $sp, $sp, 12
	
	# move argument str to the register $s0 and argument len to the register $s1
	move $s0, $a0
	move $s1, $a1
	
	# initialises i ($t0) and currWordLen ($t1) to 0
	li $t0, 0   
	li $t1, 0 
	
	loop5:
		# updates addrI ($t2) and str[i] ($t3) for the current i value
		add $t2, $t0, $s0  
		lb $t3, 0($t2)  
	
		# if we reached the end of str 
		beqz $t3, done5
		
		# elif str[i] is ' ' or '\n' we reached the end of the current word
		beq $t3, space, word_end5
		beq $t3, nextLine, word_end5
		
		# else str[i] is a letter of the current word 
		j counter5
		
	done5:
		# the address of the first char of the last word in length len word is: 
		# addrEndW ($t4) - len ($s1)
		sub $v0, $t4, $s1
		
		# increments stack pointer and pops $rs, $s0 and $s1
		add $sp, $sp, 12
		lw $s1, -8($sp)
		lw $s0, -4($sp)
		lw $ra, 0($sp)
		
		# goes back to main	
		jr $ra
	
	word_end5:
		# if currWordLen ($t1) is equal to len ($s1)
		beq $t1, $s1, update_char_addr
		
		# the next char opens a new word 
		j next_word
		
	update_char_addr:
		# updates addrEndW ($t4) to addrI ($t2)
		move $t4, $t2
		
		# the next char opens a new word 
		j next_word
		
	next_word:
		# initializes currWordLen ($t1) to 0 for the new word and
		# jump to continue5
		li $t1, 0
		j continue5
	
	counter5:
		# increments the currWordLen ($t1), and jump to continue5
		addi $t1, $t1, 1
		j continue5
	
	continue5:
		# increment i ($t0)
		addi $t0, $t0, 1
		j loop5
		
#******************************************************************************
word_print: # word_print(wordStartAddr)
#******************
# Description:
# receives an address of the first letter of a word in a string
# and prints the whole word
# 
# Register Usage:
# $a0 - argument wordStartAddr - the address of the first char of a word in a
#       string 
#       **later is an argument for system calls
# $t0- currCharAddr - address of a char in the word or the char after it's
#                     last letter
# $t1 - currChar - the char in the addres currCharAddr
#******************
	# pushes $ra to the stack and  decrenets stack pointer
	sw $ra, 0($sp)
	sub $sp, $sp, 4
	
	# initialize currCharAddr ($t0) to wordStartAddr ($a0)
	move $t0, $a0
	loop6:
		# updates currChar ($t1) to the char in currCharAddr ($t0)
		lb $t1, 0($t0)
		
		# if the whole word has already been scanned
		beq $t1,nextLine, done6
		beq $t1,space, done6
		
		# prints currChar ($t1)
		move $a0, $t1
		li $a1, printChar
		jal print
		
		# updates currCharAddr ($t0) to the address of the next char and 
		# moves to the next iteration
		addi $t0, $t0, 1
		j loop6
		
	done6:
		# increments stack pointer and pops $ra
		add $sp, $sp, 4
		lw $ra, 0($sp)
		
		# goes back to main	
		jr $ra	
		
	
#******************************************************************************
print: # print(argumentToPrint, syscallCode)
#******************
# Description:
# receives an argument to print and suitable system call code for its print 
# and print it 
# 
# Register Usage:
# $v0 -  suitable system call code to print argumentToPrint
# $a0 - argument argumentToPrint - an argument to print
# $a1 - argument syscallCode
#******************
	# pushes $ra to the stack and  decrenets stack pointer
	sw $ra, 0($sp)
	sub $sp, $sp, 4
	
	move $v0, $a1
	syscall
	
	# increments stack pointer and pops $ra
	add $sp, $sp, 4
	lw $ra, 0($sp)
		
	# goes back to main	
	jr $ra
