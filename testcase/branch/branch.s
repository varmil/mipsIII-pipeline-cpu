.set noreorder
.text
main:
	addi $2, $0, 4
	addi $3, $0, 4
	beq $2, $3, Label1
	addi $4, $0, 4
	j Label3
Label1:
	addi $4, $0, 3
	bne $3, $4, Label2

Label2:
	addi $5, $0, 12
	jr $5

Label3:
	jal final

final:
	addi $6, $0, 42









	# .set noreorder
	# .text
	# main:
	# 	addi $2, $0, 4
	# 	addi $3, $0, 4
	# 	beq $2, $3, Label1
	# 	addi $4, $0, 4
	# 	addi $4, $4, 4
	# 	addi $4, $4, 4
	# 	j Label3
	# Label1:
	# 	addi $4, $0, 3
	# 	bne $3, $4, Label2
	#
	# Label2:
	# 	lui  $5, 0x0040
	# 	ori  $5, $5, 0x0030
	# 	jr $5
	#
	# Label3:
	# 	jal final
	#
	# final:
	# 	addi $6, $0, 42
