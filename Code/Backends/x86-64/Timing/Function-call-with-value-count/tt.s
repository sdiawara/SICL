	BITS 64
	global _start
_start:
	mov r15, 10000000000
	mov rbx, function
again:	
	call rbx
	sub r15, 1
	jnz again
	mov rax, 60		; System call 60 is exit.
        xor rdi, rdi		; We want return code 0.
        syscall                 ; Invoke operating system to exit.
function:
	mov rdi, 1
	ret
