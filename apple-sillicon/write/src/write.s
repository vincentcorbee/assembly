.global main
.align 2

.equ O_RDONLY, 0
.equ O_WRONLY, 1

.macro exit_prog $code
	mov x0, \$code
	mov x16, #1
	svc 0
.endm

.text
main:
  str x30, [sp, #-16]!

  adr x0, filename

  bl open

  cmp x0, #-1
  beq error

  mov x4, x0
  adr x1, msg
  mov x2, #14
  bl write

  bl close

  mov x0, #0

  ldr x30, [sp], #16
  ret

open:
  str x30, [sp, #-16]!
  mov x1, O_WRONLY
  mov x16, #5
  svc 0
  ldr x30, [sp], #16
  ret

write:
  str x30, [sp, #-16]!
  mov x16, #4
  svc 0
  ldr x30, [sp], #16
  ret

close:
  str x30, [sp, #-16]!
  mov x0, x4
  mov x16, #6
  svc 0
  ldr x30, [sp], #16
  ret

error:
  adr x1, error_msg
  mov x2, #6
  mov x16, #4
  svc 0

  exit_prog #1

filename: .string "../test.txt"
.align 2
msg: .string "Hello, World!\n"
.align 2
error_msg: .string "Error\n"