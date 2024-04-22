.global main
.align 4

main:
  ;open x0 = filename, x1 = flags
  adr x0, filename
  mov x1, #0
  mov x16, #5
  svc 0

  cmp x0, #-1
  beq error

  ;read x0 = fd, x1 = buffer, x2 = size
  sub sp, sp, #16
  mov x5, x0
  ldr x1, [sp]
  mov x2, #4
  mov x16, #3
  svc 0

  cmp x0, #0
  beq error_read

  ;write x0 = fd, x1 = buffer, x2 = size
  mov x0, #1
  ldr x1, [sp]
  mov x2, #4
  mov x16, #4
  svc 0

  ;close x0 = fd
  mov x0, x5
  mov x16, #6
  svc 0

  ;exit x0 = code
  mov x0, #0
  mov x16, #1
  svc 0

error:
  mov x0, #1
  adr x1, error_message
  mov x2, #16
  mov x16, #4
  svc 0

  mov x0, #2
  mov x16, #1
  svc 0

error_read:
  mov x0, #1
  adr x1, error_message_read
  mov x2, #16
  mov x16, #4
  svc 0

  mov x0, #2
  mov x16, #1
  svc 0

filename:
  .string "test.txt"
.align 2
error_message:
  .string "Error opening file\n"

error_message_read:
  .string "No bytes read\n"

/* mov x0, #1
  mov x1, #0x4142
  movk x1, #0xA, lsl #16
  str x1, [sp, #-16]!
  mov x1, sp
  mov x2, #3
  mov x16, #4
  svc 0

  mov x0, #0
  mov x16, #1
  svc 0 */
