.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv HEADING 0xffff8010 # Integer: An angle between 0 and 359
# 0 : North (up)
# 90: East (right)
# 180: South (down)
# 270: West (left)
.eqv MOVING 0xffff8050 # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0):
# whether or not to leave a track

.data
#Code postscipt send in
		#------------------------------------D-----------------------------------------------------------------||--------||----------------------------------C----------------------------------------------------------------------||---------------------------------E-------------------------------------||
message1: .word 180 4000 0 90 4000 0 180 11800 1 60 4000 1 40 2000 1 20 1600 1 0 1800 1 -20 1600 1 -40 2000 1 -60 3990 1 90 12500 0 270 1600 1 250 2520 1 225 2260 1 200 2800 1 180 1800 1 155 2800 1 135 2260 1 110 2520 1 90 1600 1 90 800 0 0 12000 1 90 5000 1 180 6000 0 270 5000 1 180 6000 0 90 5000 1 12
		#--------------------------------------------------------------------------------------------------------------------------------------------S----------------------------||---------||---------------------------------------------------o--------------------------------------------------||---------||--------------------I----------------------------||-------||--------------------------------------------------C----------------------------------------------||--------||----------------------T---------------------||
message2: .word 180 4000 0 90 6000 0 270 1200 1 256 1640 1 236 1440 1 207 900 1 180 800 1 146 1440 1 137 4100 1 150 1600 1 180 1200 1 207 900 1 225 720 1 233 1000 1 254 1460 1 270 1400 1 90 8400 0 76 1640 1 27 1780 1 0 1200 1 326 1440 1 291 1700 1 249 1700 1 214 1440 1 180 1200 1 153 1780 1 105 1640 1 90 4000 0 90 4800 1 270 2400 0 0 12000 1 270 2400 0 90 4800 1 90 7800 0 270 1600 1 250 2520 1 225 2260 1 200 2800 1 180 1800 1 155 2800 1 135 2260 1 110 2520 1 90 1600 1 90 3600 0 0 12000 1 270 2400 0 90 4800 1 12
		#-------------------------I---------------------------------------------||--------||--------L----------||--------||---------------------------------------------------o--------------------------------------------||------||-------------v----------------||---------||------------------------------------------------------------------e---------------------------------------------------------------------------||--------||--------------------------------------H--------||--------||---------------------------------U-------------------------------||--------||-------------------------------------S-------------------------------------------------------------------------||--------||-----------T--------------------
message3: .word 180 4000 0 90 6000 0 90 2400 1 270 1200 0 180 4000 1 270 1200 0 90 2400 1 90 1600 0 180 4000 1 90 2400 1 90 1800 0 72 640 1 34 720 1 0 400 1 326 720 1 288 640 1 252 640 1 214 720 1 180 400 1 146 720 1 108 640 1 90 3000 0 333 2240 1 90 2000 0 205 2200 1  90 2600 0 297 440 1 333 440 1 0 800 1 45 560 1 63 440 1 90 400 1 117 440 1 146 720 1 180 400 1 270 2000 1 180 800 0 90 600 0 90 1200 1 45 280 1 225 280 0 90 1800 0 180 4000 1 0 2000 0 90 2400 1 180 2000 0 0 4000 1 90 800 0 180 2800 1 166 820 1 124 720 1 90 800 1 56 720 1 14 820 1 0 2800 1 90 3200 0 270 600 1 256 820 1 252 640 1 225 560 1 180 400 1 124 2880 1 180 400 1 225 560 1 252 640 1 256 820 1 270 600 1 90 4200 0 0 4000 1 270 1200 0 90 2400 1 12 
error:	.asciiz "Select nubmer 0,4,8 to print."
notification: .asciiz "You want to continue?"
.text
main:
#---------------------------------------------------------
# Enable interrupts you expect
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD
#---------------------------------------------------------
	li $t3, 0x80 # bit 7 of = 1 to enable interrupt
	sb $t3, 0($t1 )
#---------------------------------------------------------
Loop: 
	nop
	nop
	nop
	nop
	b Loop # Wait for interrupt
end_main:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
#--------------------------------------------------------
# Processing
#--------------------------------------------------------
#--------------------------------------------------------
#Check the scaned values to key maxtrix
#If this is 0,4,8 --> postscript
#Else not print nothing
#--------------------------------------------------------
Check: 
	li $t3, 0x01 # start with row 0x1
	column_loop:
	sb $t3, 0($t1) # assign expected column
	lb $a0, 0($t2) # read scan code of key button
	beqz $a0, next_column # if scan code is 0, no key pressed, go to next row
#---------------------------------------------------------------------------------
	nop
	bne $a0,0x11,else1
	la $s0,message1
	j loop
else1: 
	bne $a0,0x12,else2
	la $s0,message2
	j loop
else2:
	bne $a0,0x14,end1
	la $s0,message3
#----------------------------------------------------
#Bat dau in CNC Marsbot
#----------------------------------------------------
loop:
	lw $a0,0($s0)
	beq $a0,12,end2
	jal ROTATE
	nop
	jal TRACK # and draw new track line
	nop
	nop
	jal GO
	nop
	addi $v0,$zero,32 # Keep running by sleeping 
	addi $s0,$s0,-4
	lw $a0,0($s0)
	syscall
	jal UNTRACK
	nop
	jal STOP
	addi $s0,$s0,8
	j  loop
	nop
#---------------------------------------------------------------------------------
	sleep:
	li $a0, 100 # sleep 100ms
	li $v0, 32
	syscall
	next_column:
	sll $t3, $t3, 1 # multiply row value by 2
	blt $t3, 0x10, column_loop # if row value is less than 0x10 (16), repeat the row loop
point:
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
	li $at,0x00400010
	mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
return: 
	eret # Return from exception
#-----------------------------------------------------------
# GO procedure, to start running
# param[in] none
#-----------------------------------------------------------
GO:
	li $at, MOVING # change MOVING port
	addi $k0, $zero,1 # to logic 1,
	sb $k0, 0($at) # to start running
	nop
	jr $ra
	nop
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in] none
#-----------------------------------------------------------
STOP: 
	li $at, MOVING # change MOVING port to 0
	sb $zero, 0($at) # to stop
	nop
	jr $ra
	nop
#----------------------------------------------------------
# TRACK procedure, to start drawing line
# param[in] none
#-----------------------------------------------------------
TRACK: 
	li $at, LEAVETRACK # change LEAVETRACK port
	addi $s0,$s0,8
	lw $k0,0($s0)
	sb $k0, 0($at) # to start tracking
	nop
	jr $ra
	nop
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line
# param[in] none
#-----------------------------------------------------------
UNTRACK:
	li $at, LEAVETRACK # change LEAVETRACK port to 0
	sb $zero, 0($at) # to stop drawing tail
	nop
	jr $ra
	nop
#-----------------------------------------------------------
# ROTATE procedure, to rotate the robot
# param[in] $a0, An angle between 0 and 359
# 0 : North (up)
# 90: East (right)
# 180: South (down)
# 270: West (left)
#-----------------------------------------------------------
ROTATE: 
	li $at, HEADING # change HEADING port
	sw $a0, 0($at) # to rotate robot
	nop
	jr $ra
	nop
#------------------------------------------------------------
# Send the mess error for scaner
end1:
	li $v0,55
	la $a0, error
	syscall
	nop
	j point
#-----------------------------------------------------------
# Send the mess for the scnaer what continue or not
end2:
	li $v0,50
	la $a0,notification
	syscall
	bne $a0,0,else
	nop
	j point
	else: # End the program
	li $v0,10
	syscall
