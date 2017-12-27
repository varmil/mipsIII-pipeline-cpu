00000000 <main>:
   -:	27bd0080 	addiu	sp,sp,128
   0:	27bdffd8 	addiu	sp,sp,-40
   4:	afbf0024 	sw	ra,36(sp)
   8:	afbe0020 	sw	s8,32(sp)
   c:	03a0f025 	move	s8,sp
  10:	afc40028 	sw	a0,40(s8)
  14:	afc5002c 	sw	a1,44(s8)
  18:	24020003 	li	v0,3
  1c:	afc20010 	sw	v0,16(s8)
  20:	24020005 	li	v0,5
  24:	afc20014 	sw	v0,20(s8)
  28:	8fc40010 	lw	a0,16(s8)
  2c:	0c000019 	jal	64 <foo>
  30:	00000000 	nop
  34:	afc20018 	sw	v0,24(s8)
  38:	8fc40014 	lw	a0,20(s8)
  3c:	0c000019 	jal	64 <foo>
  40:	00000000 	nop
  44:	afc2001c 	sw	v0,28(s8)
  48:	00001025 	move	v0,zero
  4c:	03c0e825 	move	sp,s8
  50:	8fbf0024 	lw	ra,36(sp)
  54:	8fbe0020 	lw	s8,32(sp)
  58:	27bd0028 	addiu	sp,sp,40
  5c:	03e00008 	jr	ra
  60:	00000000 	nop

00000064 <foo>:
  64:	27bdfff0 	addiu	sp,sp,-16
  68:	afbe000c 	sw	s8,12(sp)
  6c:	03a0f025 	move	s8,sp
  70:	afc40010 	sw	a0,16(s8)
  74:	8fc20010 	lw	v0,16(s8)
  78:	00000000 	nop
  7c:	00021040 	sll	v0,v0,0x1
  80:	afc20000 	sw	v0,0(s8)
  84:	8fc20000 	lw	v0,0(s8)
  88:	03c0e825 	move	sp,s8
  8c:	8fbe000c 	lw	s8,12(sp)
  90:	27bd0010 	addiu	sp,sp,16
  94:	03e00008 	jr	ra
  98:	00000000 	nop
