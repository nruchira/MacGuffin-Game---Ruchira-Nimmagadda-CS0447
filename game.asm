.include "constants.asm"
.include "macros.asm"

.globl game

.data
	points: .word 0		# stores the current number of points that the player has
	lives: .word 9		# the variable that stores the current number of lives the player has
	
	oscillation_counter:
		.word 0		# oscillation counter for macguffins
		.word 0		# toggle for macguffins
		.word 0		# oscillation counter for enemies	
		.word 0		# toggle for enemies
		.word 0		# oscillation counter for player invincibility	
		.word 0 	# toggle for player to blink during invincibility
		
		
	arena:  # matrix to represent the arena
	    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  # row 1
	    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1  
	    .byte 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1  
	    .byte 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1 
	    .byte 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1  
	    .byte 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1  
	    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1  
	    .byte 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1  
	    .byte 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1  
	    .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1  
	    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  # row 11
	    

	wall_pattern:	# storing the pattern for the blits
	    .byte 1, 0, 1, 0, 1  
	    .byte 0, 1, 0, 1, 0   
	    .byte 1, 0, 1, 0, 1  
	    .byte 0, 1, 0, 1, 0  
	    .byte 1, 0, 1, 0, 1   
	
	mg_matrix:  # matrix to represent the arena
	    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  # row 1
	    .byte 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0  
	    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  
	    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
	    .byte 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0  
	    .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0  
	    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 
	    .byte 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0  
	    .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
	    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  
	    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  # row 11
	    
	mg_pattern1:   # storing the first pattern for the macguffins
		.byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY   
	    .byte COLOR_LIGHT_GREY, COLOR_BLUE, COLOR_LIGHT_GREY, COLOR_BLUE, COLOR_LIGHT_GREY   
	    .byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_BLUE, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY 
	    .byte COLOR_LIGHT_GREY, COLOR_BLUE, COLOR_LIGHT_GREY, COLOR_BLUE, COLOR_LIGHT_GREY  
	    .byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY      
	mg_pattern2:   # storing the second pattern for the macguffins
		.byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY   
	    .byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_YELLOW, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY
	    .byte COLOR_LIGHT_GREY, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_LIGHT_GREY  
	    .byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_YELLOW, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY   
	    .byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY, COLOR_LIGHT_GREY    
	    
	player_pattern:   # storing the pattern for the player
		.byte COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE   
	    .byte COLOR_PURPLE, COLOR_WHITE, COLOR_PURPLE, COLOR_WHITE, COLOR_PURPLE   
	    .byte COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE  
	    .byte COLOR_PURPLE, COLOR_WHITE, COLOR_PURPLE, COLOR_WHITE, COLOR_PURPLE   
	    .byte COLOR_PURPLE, COLOR_PURPLE, COLOR_WHITE, COLOR_PURPLE, COLOR_PURPLE 
	    
	player_invincible_pattern:   # storing the pattern for the player
		.byte COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE   
	    .byte COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE   
	    .byte COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE     
	    .byte COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE      
	    .byte COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_NONE     

	enemy1_pattern:   # storing the pattern for the first enemy
		.byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE   
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE   
	    .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE  
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_ORANGE  
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE  
	    
	enemy2_pattern:   # storing the pattern for the enemy2
		.byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE    
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE  
	    .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE 
	    .byte COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE  
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE   
	
	enemy3_pattern:   # storing the pattern for the enemy3
		.byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE    
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE, COLOR_WHITE, COLOR_ORANGE   
	    .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE
	    .byte COLOR_ORANGE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_ORANGE   
	    .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE   
	
	
	enemy_coords:    # array that holds the coordinates of the enemies
		.word 50		# x coord of enemy1
		.word 5			# y coord of enemy1
		.word 35		# x coord of enemy2
		.word 30		# y coord of enemy2
		.word 20		# x coord of enemy3
		.word 45		# y coord of enemy3

	xyplayer: 	# top left x and y position for the player
		.word 5	
		.word 5
	
	mgCount: .word 7		# number of macguffins	
	isEnd: .word 0		# end or not
	invTimer: .word 0	# player invincibility timer - count
	isInv: .word 0		# player invincibility toggle, 0 if not invincible, 1 if invincible 

.text
	
game:
	enter
	
	game_start:
		jal print_start			# prints text that tells the user to press a possible key to start
		jal	handle_input
		jal check_start 	# returns 1 if a possible key was pressed
		beqz v0, game_start		# if v0 = 1, the game will begin, if not, the screen will continue to display
	 
		
	_game_while:
		
		jal	handle_input
			
			
		jal info_display 	# displaying the points/lives at the bottom
		jal display_board	# displaying the walls of the arena
		
		jal display_mg		# displaying macguffins
		jal display_player	# displaying the player and handling its movement
		jal player_v_mg		# handles the collection of macguffins by the player
	
		jal enemy_move		# displaying the enemies and handling its movement
		jal enemies_v_mg		# handles the collection of macguffins by the enemies		
		
		jal check_end		# checks if the game fulfils the conditions to end
		la t0, isEnd		
		lw t1, 0(t0)		
		bnez t1, _game_end	# if isEnd = 1, the game is over
		
		# Must update the frame and wait
		jal	display_update_and_clear
		jal	wait_for_next_frame
		
		j	_game_while
	
	_game_end:
		
		jal	display_update_and_clear		# clear the display
		jal print_end						# print the game over screen
		jal	display_update_and_clear		# update the display to show the screen
		jal wait_for_next_frame
	
		leave

# ------ board / information displays --------------------------------------------------------------------------------------

info_display:	# displaying information at the bottom of the screen
 
	# creating the line of LEDS
	enter
	li a0, 0
	li a1, 55
	li a2, 64
	jal display_draw_hline
	
	# print the text for points
	li	a0, 1
	li	a1, 57
	lstr a2, "PTS: "
	jal	display_draw_text
	
	# print points
	li a0, 22
	li a1, 57
	lw a2, points
	jal display_draw_int
	
	# print the text for lives
	li a0, 30
	li a1, 57
	lstr a2, "Hrts:"
	jal	display_draw_text
	
	# print lives
	li a0, 58
	li a1, 57
	lw a2, lives
	jal display_draw_int

	leave

display_board: # function that will display the arena

	enter s0, s1, s2
	
    la s2, arena           # base address of the matrix
    li s0, 0               # row index = 0
    
    _row_loop:
	    bge s0, 11, _end_loop  # if row index >= 10, exit loop
	    li s1, 0       # column index = 0
		
	_col_loop:
		# infinite loop happening here		
	    bge s1, 12, _next_row   # if column index >= 11, go to next row
	
	    # calculate address of matrix[s0][s1]
	    mul t1, s0, 12       # t1 = row_index * total_columns
	    add t1, t1, s1       # t1 = (row_index * total_columns) + column_index
	    add t1, s2, t1      # t1 = base_address + offset
	    
	    lb t2, 0(t1)          # load the value from matrix[s0][s1]
	
	    # if the value is 0, dont create a blit
	 	beqz t2, _skip	
	
		# if the value is 1, create a blit 
		mul a0, s1, 5	# getting the x pixel number from the tile col
		mul a1, s0, 5	# getting the y pixel number from the tile row
		la a2, wall_pattern  #	a2 = pointer to blit pattern 

		jal display_blit_5x5
	
	_skip:
		inc s1		# increment col index
		j _col_loop	# jump back to col loop

	_next_row:
		inc s0       # increment row index
	    j _row_loop   # jump back to row loop
	
	_end_loop:
	    leave s0, s1, s2


# ------ player implementation --------------------------------------------------------------------------------

display_player:		# function to display the player based on keys pressed, bounds, and invincibility
	enter s0, s1, s2
	
	la s0, xyplayer		# get address of where player x and y value are held
	lw s1, 0(s0)		# top left x coord of player
	lw s2, 4(s0)		# top left y coord of player
		
	lw t0, up_pressed
	beq t0, 1, _up 			# if up_pressed = 1, go to up
	
	lw t1, down_pressed
	beq t1, 1, _down
	
	lw t2, left_pressed
	beq t2, 1, _left
	
	lw t3, right_pressed
	beq t3, 1, _right
	
	j _update
	
	_up:	
		sub t0, s2, 1			# hypothetical coordinate change
		
		move a0, s1
		move a1, t0
		jal check_four_corners 		# if the next tile that the player would move to is a wall
		beq v0, 1, _update
		
		sw t0, 4(s0)			# update the y - coordinate = move "up"
		j _update
		
	_down:
		addi t0, s2, 1			# hypothetical coordinate change
		
		move a0, s1
		move a1, t0
		jal check_four_corners
		beq v0, 1, _update	
		
		sw t0, 4(s0)			# update the y - coordinate = move "up"
		j _update
		
	_left:
		sub t0, s1, 1			# hypothetical coordinate change
		
		move a0, t0
		move a1, s2
		jal check_four_corners 
		beq v0, 1, _update
		
		sw t0, 0(s0)		# update the x - coordinate = move left
		j _update
		
	_right:
		addi t0, s1, 1			# hypothetical coordinate change
		
		move a0, t0
		move a1, s2
		jal check_four_corners
		beq v0, 1, _update
		
		sw t0, 0(s0)		# update the x - coordinate = move right
		
	_update:
		lw s1, 0(s0)		# updated top left x coord of player
		lw s2, 4(s0)		# updated top left y coord of player
	
		jal check_collisions
		la t3, isInv
		lw t4, 0(t3)
		bnez t4,  _display_invincible			# if the player is invincible right now or not
		
		move a0, s1			# print regular player pattern
		move a1, s2
		la a2, player_pattern  
		jal display_blit_5x5
		
		j _end

	_display_invincible:
		la t3, invTimer
		lw t4, 0(t3)
		
		bge t4, 120, _reset_invincibility		# if invincibility timer >= 300
		inc t4
		sw t4, 0(t3)
		
		jal player_oscillation_counter
		la t0, oscillation_counter		
		lw t1, 20(t0)					# load address of the player frame toggle, if the player is currently displayed or "blinked"
		
		bnez t1, _print_invisible		#if invisble player toggled, print invisible player ("blinked" player)
		
		# if not toggled, print normal player
		move a0, s1	
		move a1, s2
		la a2, player_pattern  
		jal display_blit_5x5
		
		j _end
		
	_print_invisible:
		move a0, s1			# print regular player pattern
		move a1, s2
		la a2, player_invincible_pattern  
		jal display_blit_5x5
		j _end
		
	_reset_invincibility:
		la t3, invTimer		# reseting the timer that times when the player disappears when invincible
		sw zero, 0(t3)
		
		la t3, isInv		# setting the toggle of if the player is invincible or not to 0 (not invincible)
		sw zero, 0(t3)				
		
		move a0, s1			# print regular player pattern
		move a1, s2
		la a2, player_pattern  
		jal display_blit_5x5

	_end:
		leave s0, s1, s2
	
	
check_four_corners:  # checks if a blit is in bounds or not by checking its four corners
	enter s0, s1, s2, s3
	
	move s0, a0 	# t0 = left x coordinate
	move s1, a1		# t1 = top y coordinate
	addi s2, s0, 4	# t2 = right x coord
	addi s3, s1, 4	# t2 = bottom y coord
	
	bltz s0, _fail	 	# left x < 0
	bltz s1, _fail	 	# top y < 0
	bge s2, 55, _fail	# right x >= max
	bge s3, 50, _fail	# bottom >= max
	
	# check top left corner
	move a0, s0            # x = left x
    move a1, s1            # y = top y
    jal is_wall
    beq v0, 1, _fail
	
	# check bottom left corner
    move a0, s0            # x = left x
    move a1, s3            # y = bottom y
    jal is_wall
    beq v0, 1, _fail

    # check top right corner
    move a0, s2            # x = right x
    move a1, s1            # y = top y
    jal is_wall	
    beq v0, 1, _fail

    # check bottom right corner
    move a0, s2            # x = right x
    move a1, s3            # y = bottom y
    jal is_wall
    beq v0, 1, _fail
    
    # if all checks pass
    li v0, 0
    j _end
	
	_fail:
		li v0, 1		# out of bounds
		
	_end:
		leave s0, s1, s2, s3 
	

	
player_oscillation_counter:		# updates the oscillation counter and toggle for the frames of the player
	enter s0, s1

    la t0, oscillation_counter			# load address of the counter
	lw s0, 16(t0)						# load value of counter
	
	lw s1, 20(t0)		# get value of the player frames

    inc s0				# increment the counter

    blt s0, 5, _end     # if counter < threshold, dont toggle      

	_toggle:	    	# if counter >= threshold, toggle
	    xori s1, s1, 1		# toggle the value (0 becomes 1, 1 becomes 0)
	    li s0, 0                # reset counter to 0
	
	_end:
	    sw s0, 16(t0)		    # storing updated counter value
	    sw s1, 20(t0)
	    leave s0, s1

# ------ enemy implementation ------------------------------------------------------------------------------------

display_enemy:		# function to display the enemy 
	enter s0
	
	la s0, enemy_coords
	
	# display enemy1
	lw a0, 0(s0)
	lw a1, 4(s0)
	la a2, enemy1_pattern
	jal display_blit_5x5
	
	# display enemy2
	lw a0, 8(s0)
	lw a1, 12(s0)
	la a2, enemy2_pattern
	jal display_blit_5x5
	
	# display enemy3
	lw a0, 16(s0)
	lw a1, 20(s0)
	la a2, enemy3_pattern
	jal display_blit_5x5
	
	jal check_collisions	# handles collisions between enemies and the player
		
	leave s0
	
	
chase_player: 
    enter s0, s1, s2

    move s0, a0          # s0 = enemy_x
    move s1, a1          # s1 = enemy_y

	la t0, xyplayer		# get address of where player x and y value are held
	lw t1, 0(t0)		# top left x coord of player

    sub s2, t1, s0       # s2 = player_x - enemy_x
    
	# horizontal movement
	beqz s2, _vertical_check	# if same horizontal coord, go to vertical check
    bgtz s2, _right 		# if s2 > 0, go to move right
    j _left					# if s2 < 0, go to move left
   

	_right:
	    inc s0        # hypothetically move enemy_x right 
	    
	    move a0, s0
	    move a1, s1
	    jal check_four_corners	# testing if that tile is valid
	    beqz v0, _vertical_check	# if its valid, continue to vertical checks
	    
	    dec s0 		# if next tile was out of bounds, reset s0 
	    j _vertical_check				
	    
	_left:
		dec s0        		# hypothetical move enemy_x left 
		
		move a0, s0
	    move a1, s1
	    jal check_four_corners	# testing if that tile is valid
	    beqz v0, _vertical_check	# if its valid, continue to vertical checks
	    
	    inc s0		# if next tile was out of bounds, reset s0 
    	j _vertical_check     		# go to vertical movement check
	
	_vertical_check:
		la t0, xyplayer		# get address of where player x and y value are held
		lw t1, 4(t0)		# top left y coord of player
		
	    sub t2, t1, s1        # t2 = player_y - enemy_y
	
		beqz t2, _end			# if same horizontal coord, go to end
	    bgtz t2, _down   		# if t2 > 0, go to move down
	    j _up					# if t2 < 0, go to move down
	    
	
	_down:
	    inc s1        	# hypothetical, move enemy_y down 
	    
	    move a0, s0
	    move a1, s1
	    jal check_four_corners	# testing if that tile is valid
	    beqz v0, _end	# if its valid, continue to end
	    
	    dec s1		# if next tile was out of bounds, reset s1 
	    j _end      		# update coordinates and return
	    
	_up:
		dec s1        # hypothetical, move enemy_y up by 5
		
		move a0, s0
	    move a1, s1
	    jal check_four_corners	# testing if that tile is valid
	    beqz v0, _end	# if its valid, go to end
	    
		inc s1		# if next tile was out of bounds, reset s1 
	
	_end:
	    move v0, s0          # return enemy_x coordinate
	    move v1, s1          # return enemy_y coordinate
	    leave s0, s1, s2
	
	
enemy_move:
	enter s0
	
	jal enemy_frame_oscillation_counter
	la t2, oscillation_counter		
	lw t3, 12(t2)			# load address of the enemy frame toggle
		
	beqz t3, _end		# if the enemy frame counter has been toggled, go to pattern1

	_move:
		la s0, enemy_coords
		
		# first enemy
		lw a0, 0(s0)			
		lw a1, 4(s0)
		jal chase_player
		move t0, v0			
		move t1, v1
				
		sw, t0, 0(s0)
		sw, t1, 4(s0)
		
		# second enemy
		lw a0, 8(s0)			
		lw a1, 12(s0)
		jal chase_player
		move t0, v0			
		move t1, v1
				
		sw, t0, 8(s0)
		sw, t1, 12(s0)
		
		# third enemy
		lw a0, 16(s0)			
		lw a1, 20(s0)
		jal chase_player
		move t0, v0			
		move t1, v1
				
		sw, t0, 16(s0)
		sw, t1, 20(s0)
		
	_end:
		jal display_enemy
		
		leave s0

enemy_frame_oscillation_counter:	# updates the oscillation counter and toggle for the frames of enemies
	enter s0, s1

    la t0, oscillation_counter			# load address of the counter
	lw s0, 8(t0)						# load value of counter
	
	lw s1, 12(t0)		# toggle value of the enemy frames

    inc s0		# increment the counter

    blt s0, 3, _end     # if counter < threshold, dont toggle      

	_toggle:	    	# if counter >= threshold, toggle
	    xori s1, s1, 1		# toggle the value (0 becomes 1, 1 becomes 0)
	    li s0, 0                # reset counter to 0
	
	_end:
	    sw s0, 8(t0)		    # storing updated counter value
	    sw s1, 12(t0)
	    leave s0, s1
	    
	
# ------ macguffin implementation ------------------------------------------------------------------------------------

display_mg: # function that will display the macguffins

	enter s0, s1, s2
    la s2, mg_matrix       # base address of the matrix
    li s0, 0               # row index = 0
    
    _row_loop:
	    bge s0, 11, _end_loop  # if row index >= 11, exit loop
	    li s1, 0       # column index = 0
		
	_col_loop:
		# infinite loop happening here		
	    bge s1, 12, _next_row   # if column index >= 12, go to next row
	
	    # calculate address of matrix[t0][t1]
	    mul t2, s0, 12       # t2 = row_index * total_columns
	    add t2, t2, s1       # t2 = (row_index * total_columns) + column_index
	    add t2, s2, t2       # t2 = base_address + offset
	    
	    lb t3, 0(t2)          # load the value from matrix[t0][t1]
	
	    # if the value is 0, dont create a blit
	 	beqz t3, _skip	
	
		# if the value is 1, create a blit 
		mul a0, s1, 5	# getting the x pixel number from the tile col
		mul a1, s0, 5	# getting the y pixel number from the tile row
		
		jal mg_frame_oscillation_counter
		la t0, oscillation_counter		
		lw t1, 4(t0)			# load address of the macguffin frame toggle
		
		bnez t1, _pattern1		# if the mg frame counter has been toggled, go to pattern1

		# printing pattern2 if the counter has not been toggled
		la a2, mg_pattern2 
		jal display_blit_5x5
		
		j _skip
	
	_pattern1:
		la a2, mg_pattern1  
		jal display_blit_5x5
		
		
	_skip:
		inc s1		# increment col index
		j _col_loop	# jump back to col loop

	_next_row:
		inc s0       # increment row index
	    j _row_loop   # jump back to row loop
	
	
	_end_loop:
	    leave s0, s1, s2
	    
	    
check_corners_mg: # checks if a 5x5 blit is in a tile with a macguffin or not by checking its four corners
	enter s0, s1, s2, s3
	
	move s0, a0 	# s0 = left x coordinate
	move s1, a1		# s1 = top y coordinate
	addi s2, s0, 4	# s2 = right x coord
	addi s3, s1, 4	# s2 = bottom y coord
	
	# check top left corner
	move a0, s0            # x = left x
    move a1, s1            # y = top y
    jal is_mg
    beq v0, 1, _yes
	
	# check bottom left corner
    move a0, s0            # x = left x
    move a1, s3            # y = bottom y
    jal is_mg
    beq v0, 1, _yes

    # check top right corner
    move a0, s2            # x = right x
    move a1, s1            # y = top y
    jal is_mg
    beq v0, 1, _yes

    # check bottom right corner
    move a0, s2            # x = right x
    move a1, s3            # y = bottom y
    jal is_mg
    beq v0, 1, _yes
    
 	# if there is no macguffin
    li v0, 0
    j _end
	
	_yes:
		li v0, 1		# there is a macguffin
		
	_end:
		leave s0, s1, s2, s3 
	
	
is_mg:	# returns 0 if the given coordinates contain a macguffin, returns 1 if they do
	enter
	
	# a0 = x, a1 = y
	jal get_tile_from_pixels
  
    move t0, v1		# t0 = row index, y
    move t1, v0		# t1 = col index
    la t2, mg_matrix	# base address of macguffin matrix
    
	mul t3, t0, 12       # t7 = row_index * total_columns
	add t3, t3, t1       # t7 = (row_index * total_columns) + column_index
	add t3, t2, t3       # t7 = base_address + offset
	    
	lb t4, 0(t3)          # load the value from matrix[t0][t1]
	
	move v0, t4			# v0 will be 0 if no macguffin, 1 if macguffin
	
	leave
	
mg_disappear:	# sets the value of the macguffin matrix to 0 in tiles where the macguffin is meant to disappear
	enter s0, s1
	
	# a0 = x coord of blit in mg tile
	# a1 = y coord of blit in mg tile
	jal get_tile_from_pixels
	move s0, v0		# t0 = x index of tile, col index
	move s1, v1		# t1  = y index of tile, row index
	
	la t0, mg_matrix	# base address of macguffin matrix
	
	mul t1, s1, 12		# t3 = row_index * total_columns
	add t1, t1, s0		# t3 = (row_index * total_columns) + column_index
	add t1, t0, t1		# t3 = base_address + offset
		
	sb zero, 0(t1)		# store 0 at the address in t3
	
	la t2, mgCount
	lw t3, 0(t2)
	dec t3				# decrement the number of macguffins
	sw t3, 0(t2)

	leave s0, s1
	
	
player_v_mg:
	
	enter
	
	# a0 = x coord of player 
	# a1 = y coord of player
	jal check_corners_mg		# checks if the player is in a tile with a mg
	beq v0, 1, _yes 			# if it is a mg tile
	
	j _end
	
	_yes:
		# increasing the points
		la t0, points
		lw t1, 0(t0)
		inc t1
		sw t1, 0(t0)
		
		jal mg_disappear
		
	_end:
		leave
		
enemies_v_mg:
    enter s0, s1

    la s0, enemy_coords     
    li s1, 0                 # counter for enemies (0, 1, 2)
    
	_loop:
	    # get the x and y coordinates for the current enemy
	    lw a0, 0(s0)             # x coord of current enemy
	    lw a1, 4(s0)             # y coord of current enemy
	
	    # check enemy's position is on a macguffin tile
	    jal check_corners_mg    
	    beq v0, 1, _yes          # if it is a mg tile, go to _yes

	    j _next                   # if not an mg tile, go to next enemy
	
	_yes:	# if current enemy is on a mg tile
	    jal mg_disappear         # if current enemy is on a mg tile, trigger mg disappearance
	    j _next                   # Exit after handling one enemy
	
	_next:
	    addi s0, s0, 8           # move to the next enemy's coordinates
	    inc s1           		# increment enemy counter
	    blt s1, 3, _loop        # if not all enemies checked, continue the loop
		
	_end:
	    leave s0, s1


mg_frame_oscillation_counter:	# updates the oscillation counter and toggle for the frames of macguffins
	enter

    la t0, oscillation_counter			# load address of the counter
	lw t1, 0(t0)						# load value of counter
	
	lw t2, 4(t0)		# toggle value of the macguffin frames

    inc t1		# increment the counter

    blt t1, 120, _end     # if counter < threshold, toggle      

	_toggle:	    	# if counter >= threshold, toggle
	    xori t2, t2, 1		# toggle the value (0 becomes 1, 1 becomes 0)
	    li t1, 0                # reset counter to 0
	
	_end:
	    sw t1, 0(t0)		    # storing updated counter value
	    sw t2, 4(t0)
	    leave 

# ------ enemy / player collisions -------------------------------------------------------------------------------------------------

check_collisions:
	enter s0, s1
	
	la s0, enemy_coords
		
	# first enemy
	lw a0, 0(s0)			
	lw a1, 4(s0)
	jal on_player
	bnez, v0, _collided
	
	# second enemy
	lw a0, 8(s0)			
	lw a1, 12(s0)
	jal on_player
	bnez, v0, _collided
	
	# third enemy
	lw a0, 16(s0)			
	lw a1, 20(s0)
	jal on_player
	bnez, v0, _collided
	
	j _end
	
	_collided:		# decrement the player's lives if collision and not invincible
		la s1, isInv  # don't decrement the lives if invincible
		lw t0, 0(s1)
		bnez t0, _end	# don't decrement the lives if invincible
		
		la t1, lives		# decrement the lives if not invincible
		lw t2, 0(t1)
		dec t2
		sw t2, 0(t1)
		 
		li t0, 1
		sw t0, 0(s1)		# toggle the invincibility to invincible if not already invincible
		
		# reset the player's oscillation counters
		la t3, oscillation_counter			# load address of the counter
		li t4, 0
		li t5, 0
		sw t4, 16(t3)		# store 0
		sw t5, 20(t3)		# store 0 
		
	_end:
		leave s0, s1

on_player:		# determines iif the given enemy coordinates are colliding with the coordinates of the player
    enter 

	la t0, xyplayer		# get address of where player x and y value are held
	lw t4, 0(t0)		# top left x coord of player
	lw t5, 4(t0)		# top left y coord of player
		
    # horizontal checks
    move t0, a0              # t0 = left x coordinate of enemy
    move t1, t4              # t1 = left x coordinate of player
    addi t2, t0, 4           # right x of enemy
    addi t3, t1, 4           # right x of player
    
    blt t2, t1, _no_collision # if enemy right x < player left x , no collision
    blt t3, t0, _no_collision # if player right x < enemy left x, no collision

    # vertical checks
    move t0, a1              # t0 = top y coordinate of enemy
    move t1, t5              # t1 = top y coordinate of player
    addi t2, t0, 4           # bottom y of enemy
    addi t3, t1, 4           # bottom y of player
    
    blt t2, t1, _no_collision # if enemy bottom y < player top y, no collision
    blt t3, t0, _no_collision # if player bottom y < enemy top y , no collision

    # if checks fail, enemy and player are colliding
    li v0, 1                # return 1
    j _end

	_no_collision:
	    li v0, 0                # return 0 (no collision)
	
	_end:
	    leave 
		
				
# ------ start / end conditions -------------------------------------------------------------------------------------------------

check_start:  # returns 1 if a possible key was pressed
	enter
	
	lw t0, b_pressed
	lw t1, z_pressed
	lw t2, x_pressed
	lw t3, c_pressed
	
	beq, t0, 1, _yes
	beq, t1, 1, _yes
	beq, t2, 1, _yes
	beq, t3, 1, _yes
	
	# if no key was pressed
	li v0, 0
	j _end
	
	_yes:
		li v0, 1
	
	_end:
		leave 

print_start:		# prints text telling the user to press a key to begin the game
	enter
	
	li	a0, 5
	li	a1, 15
	lstr a2, "Press any"
	jal	display_draw_text
	
	li	a0, 15
	li	a1, 25
	lstr a2, "key to"
	jal	display_draw_text
	
	li	a0, 15
	li	a1, 35
	lstr a2, "start! "
	jal	display_draw_text
	
	jal	display_update_and_clear
	jal	wait_for_next_frame
	
	leave

check_end:  # updates isEnd to 0 if game is still going, or 1 if it reached the end
	enter
	
	# if lives = 0, return 1
	la t0, lives
	lw t1, 0(t0)
	blez t1, _over
		
	# if no more macguffins, return 1
	la t2, mgCount
	lw t3, 0(t2)
	beqz t3, _over
	
	# if neither conditions are true, s3 stays 0
	j _end
	
	_over:
		la t0, isEnd
		li t1, 1	# set isEnd to 1
		sw t1, 0(t0)
		
	_end:
		leave 

print_end:
	enter
		
	li	a0, 7
	li	a1, 15
	lstr	a2, "GAME"
	li a3, COLOR_RED
	jal display_draw_colored_text
	
	li	a0, 34
	li	a1, 15
	lstr	a2, "OVER"
	li a3, COLOR_RED
	jal display_draw_colored_text
	
	li	a0, 10
	li	a1, 32
	lstr	a2, "Points:"
	jal	display_draw_text

	li	a0, 50
	li	a1, 32
	lw a2, points
	jal display_draw_int
	
	leave
	

# ------ helper functions -------------------------------------------------------------------------------------------------

is_wall:	# returns 0 if the given coordinates are not a wall, returns 1 if they are
	enter
	
	# a0 = x, a1 = y
	jal get_tile_from_pixels
  
    move t4, v1		# v1 = row index
    move t5, v0		# v0 = col index
    la t6, arena	# base address of arena matrix
    
	mul t7, t4, 12       # t7 = row_index * total_columns
	add t7, t7, t5       # t7 = (row_index * total_columns) + column_index
	add t7, t6, t7       # t7 = base_address + offset
	    
	lb t3, 0(t7)          # load the value from matrix[t0][t1]
	
	move v0, t3			# v0 will be 0 if no wall, 1 if wall
	
	leave

    
get_tile_from_pixels:
    # a0 = x, a1 = y
    # v0 = col index, v1 = row index
    enter s0

	move s0, a0
	move t1, a1
	li t2, 5		# since all blits/blocks are 5x5
	
    div s0, t2      # divide the pixel value by 5 to get the tile index
    mflo v0         # get the quotient, without the remainder to round down

    div t1, t2     
    mflo v1         

    leave s0
    
	
	

