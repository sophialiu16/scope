.text

.global vram_test
.align 4

vram_test:
	movia	r6, 0x140000
	movia	r4, 0x140000
	movia	r13, 0x17ffff
	movi	r9, 0xf1
	movi	r7, 0
	movi	r12, 1
start:
	add	r4, r6, r7
	stb		r9, 0(r4)
	ldbu	r5, 0(r4)
	addi	r7, r7, 1

	bne		r5, r9, error
	cmpeq	r11, r4, r13
	beq		r11, r12, done
	jmpi	start
error:
	# movi	r4, -1
	ret
done:
	# movi	r4, 0
	ret


.text

.global vram_test_32
.align 4

vram_test_32:
	movia	r6, 0x140000
	movia	r4, 0x140000
	movia	r13, 0x17fffc
	movhi	r9, 0x7856
	ori     r9, r9, 0x3412
	movi	r7, 0
	movi	r12, 1
start_32:
	add		r4, r6, r7
	stw		r9, 0(r4)
	ldw     r5, 0(r4)
	addi	r7, r7, 4

	bne		r5, r9, error_32
	cmpeq	r11, r4, r13
	beq		r11, r12, done_32
	jmpi	start_32
error_32:
	# movi	r4, -1
	ret
done_32:
	# movi	r4, 0
	ret
