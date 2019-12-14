.data
	dir: .space 20
	
	dir_prompt: .asciiz "Choose a direction (N, S, E, W): "
	open_msg: .asciiz "Welcome to the Walking Grounds!\n"
	wall_msg: .asciiz "Ouch! Your character ran directly into a wall. Please consider not doing that.\n"
	input_error_msg: .asciiz "That's not a valid input, friend\n"
	current_pos_msg: .asciiz "Your current position is "
	monster_msg1: .asciiz "You ran into a monster!"
	monster_msg2: .asciiz "[MONSTER!]"
	
.text

# TODO: Add monster move, monster check, and monster msg logic

# Variables
# s0 = X position of player
# s1 = Y position of player
# s2 = X max
# s3 = Y max
# s4 = X position of monster
# s5 = Y position of monster


main:
	
	la $a0, open_msg
	jal print_str
	li $s0, 1
	li $s1, 1
	
	li $s2, 6
	li $s3, 6
	
	li $s4, 3
	li $s5, 3
	
dir_loop:

	jal print_pos
	la $a0, dir_prompt
	jal print_str
	li $v0, 8
	la $a0, dir
	li $a1, 20
	syscall
	
	lb $a0, ($a0)
	
	beq $a0, 'N', move_north
	beq $a0, 'S', move_south
	beq $a0, 'E', move_east
	beq $a0, 'W', move_west
	
	la $a0, input_error_msg
	jal print_str
	j dir_loop
	
move_north:

	addi $s1, $s1, 1
	jal check_pos
	j dir_loop

move_south:

	addi $s1, $s1, -1
	jal check_pos
	j dir_loop

move_east:

	addi $s0, $s0, 1
	jal check_pos
	j dir_loop

move_west:

	addi $s0, $s0, -1
	jal check_pos
	j dir_loop


check_pos:

	addi $sp, $sp, -4
	sw $ra, 0($sp)	

	slt $t0, $zero, $s0
	beq $t0, $zero, wall_x_low
	slt $t0, $zero, $s1
	beq $t0, $zero, wall_y_low
	slt $t0, $s0, $s2
	beq $t0, $zero, wall_x_high
	slt $t0, $s1, $s3
	beq $t0, $zero, wall_y_high
	j check_pos_end
	
wall_x_low:
	addi $s0, $s0, 1
	j check_pos_msg
	
wall_y_low:
	addi $s1, $s1, 1
	j check_pos_msg
	
wall_x_high:
	addi $s0, $s0, -1
	j check_pos_msg
	
wall_y_high: 
	addi $s1, $s1, -1
	j check_pos_msg
	
check_pos_msg:
	la $a0, wall_msg
	jal print_str
	
check_pos_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

print_str:

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $v0, 4
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

print_pos:
	
	li $v0, 4
	la $a0, current_pos_msg
	syscall
	
	li $v0, 11
	la $a0, '('
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 11
	la $a0, ','
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall
	
	li $v0, 11
	la $a0, ')'
	syscall
	
	li $v0, 11
	la $a0, '\n'
	syscall
	
	jr $ra
