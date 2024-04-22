.global main
.align 4

/*
  Print the command line arguments

  Input registers:

  x0 = argument count
  x1 = pointer to arguments
  x2 = user
  x3 = executable path
 */
main:
  cbz w0, end_print         ; no arguments

  mov w5, w0
  mov w4, w0                ; argument counter
  mov w9, #0                ; character index;
  ldr x7, [x1]              ; pointer to the first argument
print_args:
print_arg:
  add x8, x7, x9

  mov x0, #1
  mov x1, x8
  mov x2, #1
  mov x16, #0x4
  svc 0

  add w9, w9, #1

  ldrb w10, [x8]            ; load the character
  cbnz w10, print_arg       ; if it is not a null character, goto next character

  mov x0, #1
  adr x1, newline
  mov x2, #1
  mov x16, #0x4
  svc 0

  sub w4, w4, #1
  cbnz w4, print_args
end_print:
  mov x0, x5
  mov x16, #0x1
  svc 0

newline: .ascii "\n"