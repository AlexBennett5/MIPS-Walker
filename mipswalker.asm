.data
	dir: .space 20
	
	dir_prompt: .asciiz "Choose a direction (N, S, E, W): "
	open_msg: .asciiz "Welcome to the Walking Grounds!\n"
	wall_msg: .asciiz "\nOuch! Your character ran directly into a wall. Please consider not doing that.\n"
	input_error_msg: .asciiz "That's not a valid input, friend\n"
	current_pos_msg: .asciiz "\nYour current position is "
	monster_msg: .asciiz "\nYou ran into a monster!!\n"
	
.text

# TODO: Fix move_monster

# VARIABLES #
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
	
	jal move_monster
	
	lb $a0, ($a0)
	
	beq $a0, 'N', move_north
	beq $a0, 'S', move_south
	beq $a0, 'E', move_east
	beq $a0, 'W', move_west
	
	la $a0, input_error_msg
	jal print_str
	j dir_loop
	
# PLAYER MOVEMENT #	
move_north:

	addi $s1, $s1, 1
	jal check_player_pos
	j dir_loop

move_south:

	addi $s1, $s1, -1
	jal check_player_pos
	j dir_loop

move_east:

	addi $s0, $s0, 1
	jal check_player_pos
	j dir_loop

move_west:

	addi $s0, $s0, -1
	jal check_player_pos
	j dir_loop

check_player_pos:

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
	j check_mons_x
	
wall_x_low:
	addi $s0, $s0, 1
	j check_wall_msg
	
wall_y_low:
	addi $s1, $s1, 1
	j check_wall_msg
	
wall_x_high:
	addi $s0, $s0, -1
	j check_wall_msg
	
wall_y_high: 
	addi $s1, $s1, -1
	j check_wall_msg
	
check_wall_msg:
	la $a0, wall_msg
	jal print_str
	
check_mons_x:
	beq $s0, $s4, check_mons_y
	j check_pos_end	

check_mons_y:
	beq $s1, $s5, print_mons_msg
	j check_pos_end
	
print_mons_msg:
	la $a0, monster_msg
	jal print_str
	
check_pos_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# MONSTER MOVEMENT #

move_monster:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 42
	li $a1, 2
	syscall
	
	beq $a0, 2, mons_x_neg
	beq $a0, 1, mons_x_pos
	
move_monster_2:	
	li $v0, 42
	li $a1, 2
	syscall
	
	beq $a0, 2, mons_y_neg
	beq $a0, 1, mons_y_pos
	j mons_end
	
mons_x_neg:
	addi $s4, $s4, -1
	j move_monster_2
	
mons_x_pos:
	addi $s4, $s4, 1
	j move_monster_2

mons_y_neg:
	addi $s5, $s5, -1
	j mons_end

mons_y_pos:
	addi $s5, $s5, 1
	
mons_end:
	jal check_mons_pos
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

check_mons_pos:
	addi $sp, $sp, -4
	sw $ra, 0($sp)	

	slt $t0, $zero, $s4
	beq $t0, $zero, mons_x_low
	slt $t0, $zero, $s5
	beq $t0, $zero, mons_y_low
	slt $t0, $s4, $s2
	beq $t0, $zero, mons_x_high
	slt $t0, $s5, $s3
	beq $t0, $zero, mons_y_high
	j mons_check_end
	
mons_x_low:
	addi $s4, $s4, 1
	j mons_check_end
	
mons_y_low:
	addi $s5, $s5, 1
	j mons_check_end
	
mons_x_high:
	addi $s4, $s4, -1
	j mons_check_end
	
mons_y_high: 
	addi $s5, $s5, -1
	j mons_check_end
	
mons_check_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# FUNCTIONS #
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
