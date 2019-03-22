# Author: Aristos Georgiou
# Implementation of a Sudoku solver using recursive backtracking. 

.data

# Hard-coded one for testing the method.	
sudoku:	.word	4, 0, 0, 0, 0, 0, 0, 0, 9
		.word	0, 9, 1, 0, 0, 0, 2, 8, 0
		.word	0, 0, 0, 0, 1, 0, 0, 0, 0
		.word	0, 4, 0, 7, 0, 8, 0, 1, 0
		.word	0, 0, 7, 0, 0, 0, 8, 0, 0
		.word	0, 1, 0, 3, 0, 2, 0, 5, 0
		.word	0, 0, 0, 0, 9, 0, 0, 0, 0
		.word	0, 5, 8, 0, 0, 0, 7, 3, 0
		.word	6, 0, 0, 0, 0, 0, 0, 0, 5
		
newline: .asciiz	"\n"
space:	 .asciiz	" "
									
.text
	
main:
	
	# solve(sudoku, row, col)
	la 	$a0, sudoku
	li  $a1, 0
	li  $a2, 0
	jal	solve
	
	# print(sudoku)
	la  $a0, sudoku
	jal print
	
	# Exit Program
	li	$v0, 10
	syscall
	
# booolean solve(sudoku, row, col) -> parameters($a0, $a1, $a2), returns ($v0)	
solve:

	# while (row != 9)
	solveFor1: beq  $a1, 9, solveFor1Esc
		
		# while (col != 9)
		solveFor2: beq  $a2, 9, solveFor2Esc
		
			# if (sudoku[i][j] == 0)
			lw	 $t0, 0($a0)
			bne  $t0, 0, cellNotZero
				
				# num = 1
				li 	$t0, 1
				
				# while (num != 10)
				solveFor3: beq  $t0, 10, solveFor3Esc
					
					# Save registers($t0, $a0, $a1, $a2, $ra)
					sub  $sp, $sp, 20
					sw   $t0, 0($sp)
					sw   $a0, 4($sp)
					sw   $a1, 8($sp)
					sw   $a2, 12($sp)
					sw   $ra, 16($sp)
					
					# canPlace(cascading ($a0, $a1, $a2), num) -> returns ($v0)
					move $a3, $t0
					jal  canPlace
					
					# Restore registers($t0, $a0, $a1, $a2, $ra)
					lw   $t0, 0($sp)
					lw   $a0, 4($sp)
					lw   $a1, 8($sp)
					lw   $a2, 12($sp)
					lw   $ra, 16($sp)
					add  $sp, $sp, 20
					
					# if (canPlace(cascading ($a0, $a1, $a2), num))
					beq  $v0, -1, cannotPlace
						# sudoku[i][j] = num
						sw  $t0, 0($a0)
						
						# Save registers($t0, $a0, $a1, $a2, $ra)
						sub  $sp, $sp, 20
						sw   $t0, 0($sp)
						sw   $a0, 4($sp)
						sw   $a1, 8($sp)
						sw   $a2, 12($sp)
						sw   $ra, 16($sp)
						
						# solve(cascading ($a0, $a1, $a2)) -> returns ($v0)
						jal  solve
						
						# Restore registers($t0, $a0, $a1, $a2, $ra)
						lw   $t0, 0($sp)
						lw   $a0, 4($sp)
						lw   $a1, 8($sp)
						lw   $a2, 12($sp)
						lw   $ra, 16($sp)
						add  $sp, $sp, 20
						
						# if (solve(sudoku))
						beq  $v0, -1, cannotSolve
						
							# return true
							li  $v0, 1
							jr  $ra
							
						cannotSolve:
						# sudoku[i][j] = 0
						li  $t1, 0
						sw  $t1, 0($a0)
					cannotPlace:
					
					# num++, loop
					add  $t0, $t0, 1
					j    solveFor3
				solveFor3Esc:
				# return false
				li  $v0, -1
				jr  $ra
			
		cellNotZero:	
			# sudoku address += 4, col++, loop
			add  $a0, $a0, 4
			add  $a2, $a2, 1
			j    solveFor2
		solveFor2Esc:
		
		# row++, col = 0, loop
		add  $a1, $a1, 1
		li   $a2, 0
		j    solveFor1
	solveFor1Esc:		

	# return true
	li  $v0, 1
	jr 	$ra
	
# booolean canPlace(sudoku, row, col, num) -> parameters($a0, $a1, $a2, $a3) -> returns ($v0)
canPlace:

	# Translate $a0 to the start address $a0 - ((row * 9 + col) * 4)
	move $t0, $a1
	mul  $t0, $t0, 9
	add  $t0, $t0, $a2
	mul  $t0, $t0, 4
	sub  $a0, $a0, $t0
	
	
	# i = 0
	li   $t0, 0
	
	canPlaceFor1: beq $t0, 9, canPlaceFor1Esc
		# sudoku[row][i] = $a0 + ((row * 9 + i) * 4)
		move $t1, $a1
		mul  $t1, $t1, 9
		add  $t1, $t1, $t0
		mul  $t1, $t1, 4
		add  $t1, $t1, $a0
		lw   $t1, 0($t1)
		
		# if (sudoku[row][i] == num)
		bne  $t1, $a3, okayFromRow
			# return false
			li $v0, -1
			jr $ra
		
		okayFromRow:
	
		# sudoku[i][col] = $a0 + ((i * 9 + col) * 4)
		move $t1, $t0
		mul  $t1, $t1, 9
		add  $t1, $t1, $a2
		mul  $t1, $t1, 4
		add  $t1, $t1, $a0
		lw   $t1, 0($t1)
		
		# if (sudoku[i][col] == num)
		bne  $t1, $a3, okayFromCol
			# return false
			li $v0, -1
			jr $ra
		
		okayFromCol:
	
		# i++, loop
		add  $t0, $t0, 1
		j   canPlaceFor1
	canPlaceFor1Esc:
	
	# row = (row / 3) * 3
	div  $a1, $a1, 3
	mul  $a1, $a1, 3
	
	# col = (col / 3) * 3
	div  $a2, $a2, 3
	mul  $a2, $a2, 3
	
	add  $t0, $a1, 3
	add  $t1, $a2, 3
	# while (row != row + 3)
	canPlaceFor2: beq $a1, $t0, canPlaceFor2Esc
		# while (col != col + 3)
		canPlaceFor3: beq $a2, $t1, canPlaceFor3Esc
			# sudoku[row][col] = $a0 + ((row * 9 + col) * 4)
			move $t2, $a1
			mul  $t2, $t2, 9
			add  $t2, $t2, $a2
			mul  $t2, $t2, 4
			add  $t2, $t2, $a0
			lw   $t2, 0($t2)
			
			# if (sudoku[row][col] == num)
			bne  $t2, $a3, okayFromSubgrid
				# return false
				li $v0, -1
				jr $ra
			okayFromSubgrid:
			
			# col++, loop
			add, $a2, $a2, 1
			j    canPlaceFor3
		canPlaceFor3Esc:
		
		# row++, reset col index, loop
		add, $a1, $a1, 1
		sub  $a2, $t1, 3
		j    canPlaceFor2
	canPlaceFor2Esc:
	# return true
	li   $v0, 1
	jr   $ra
	
	
# void print(sudoku) -> parameters($a0)
print:
	# sudoku address
	move $t9, $a0

	# i = 0
	li	 $t0, 0
	
	# while (i != 9)
	printFor1: beq  $t0, 9, printFor1Esc
	
		# j = 0
		li   $t1, 0

		# while (j != 9)
		printFor2: beq  $t1, 9, printFor2Esc
		
			# print(sudoku[i][j] + ' ')
			li	 $v0, 1
			lw	 $a0, 0($t9)
			syscall
			li	 $v0, 4
			la	 $a0, space
			syscall	
		
			# sudoku address += 4, j++, loop
			add  $t9, $t9, 4
			add  $t1, $t1, 1
			j    printFor2
		printFor2Esc:
		
		# print('\n')
		li	 $v0,	4
		la	 $a0,	newline
		syscall
		
		# i++, loop
		add  $t0, $t0, 1
		j    printFor1
	printFor1Esc:		
	
	# return
	jr	$ra
	