.text
.global main
.align 2
.equ SYS_EXIT, 2

.macro exit_prog $code
  mov x0, \$code
  mov x16, #1
  svc 0
.endm

main:
  str x30, [sp, #-32]!

  adr x0, filename
  mov x1, #0

  bl open

  cmp x0, #-1
  beq error

  mov x4, x0
  mov x1, sp
  mov x2, #1
  mov x0, x4

  bl read

  mov x0, #1
  mov x2, #1

  bl write

  bl close

  mov x0, #0

  ldr x30, [sp], #16

  ret

open:
  str x30, [sp, #-16]!

  mov x16, #5
  svc 0

  ldr x30, [sp], #16

  ret

read:
  str x30, [sp, #-16]!

  mov x16, #3
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

  mov x16, #6
  ldr x30, [sp], #16

  ret

error:
  adr x0, error_msg
  mov x1, #1
  mov x16, #4
  svc 0

  exit_prog SYS_EXIT

filename:
  .string "test.txt"

.align 2

error_msg:
  .string "Error\n"