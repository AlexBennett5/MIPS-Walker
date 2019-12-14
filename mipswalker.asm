.data
	dir: .space 20
	
	dir_prompt: .asciiz "Choose a direction (N, S, E, W): "
	open_msg: .asciiz "Welcome to the Walking Grounds!\n"
	wall_msg: .asciiz "Ouch! Your character ran directly into a wall. Please consider not doing that.\n"
	input_error_msg: .asciiz "That's not a valid input, friend\n"
	current_pos_msg: .asciiz "Your current position is "
	
.text

# Variables
# s0 = X position
# s1 = Y position
# s2 = X max
# s3 = Y max

# TODO: Test the position checker & movement options

main:
	
	la $a0, open_msg
	jal print_str
	li $s0, 0
	li $s1, 0
	
	li $s2, 5
	li $s3, 5
	
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

	j dir_loop

move_south:

	j dir_loop

move_east:

move_west:



check_pos:
	slti $t0, $zero, $s0
	beq $t0, $zero, wall_x_low
	slti $t0, $zero, $s0
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
	print_str
	
check_pos_end:
	jr $ra
	

print_str:

	li $v0, 4
	syscall
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
