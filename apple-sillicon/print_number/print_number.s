.global main
.align 4

.macro exit_prog $code
  mov x0, \$code
  mov x16, #1
  svc 0
.endm

main:
  mov x0, #137                    ; input number
  mov w5, #0

  cmp x0, #0
  b.lt negative

negative:
  mov w5, #1

  cmp x0, #0
  b.eq print_zero

  mov x1, #10                     ; divisor
  mov x2, x0                      ; current quotient

  sub sp, sp, #16                 ; allocate 16 bytes on the stack
  mov x9, #0                      ; byte counter
  mov x10, #0                     ; container for ASCII character

div:
  cmp x0, #0
  b.eq div_end

  sdiv x2, x2, x1                 ; divide number by divisor
  msub x3, x2, x1, x0             ; calculate remainder (number - (quotient * divisor))
  mov x0, x2                      ; update number with quotient

  add w10, w3, #48                ; convert number to ASCII

  strb w10, [sp, x9]              ; store character on the stack

  add w9, w9, #1                  ; increment byte counter

  b div

div_end:
  sub w9, w9, #1                   ; decrement byte counter
  b print

print_zero:
  add w10, w0, #48
  strb w10, [sp, x9]              ; store character on the stack

print:                             ; print ASCII characters
  mov w11, #0

reverse:                           ; reverse stack
  sub w12, w9, w11

  ldrb w13, [sp, x11]             ; load first character from the stack
  ldrb w10, [sp, x12]             ; load last character from the stack

  strb w13, [sp, x12]             ; store first character on the stack
  strb w10, [sp, x11]             ; store last character on the stack

  add w11, w11, #1                ; increment counter

  cmp w11, w9                      ; check if we have reached end
  b.lt reverse

  add x9, x9, #1

  mov w10, #0xa                  ; newline
  strb w10, [sp, x9]              ; store newline on the stack
  add x9, x9, #1

  mov w10, #0x0                  ; null terminator
  strb w10, [sp, x9]              ; store null terminator on the stack
  add x9, x9, #1
write:
  mov x0, #1                      ; file descriptor for stdout
  mov x1, sp                      ; pointer to the string
  mov x2, x9                      ; byte length
  mov x16, #4                     ; syscall number for write
  svc 0

  add sp, sp, #16                 ; deallocate 16 bytes from the stack

  exit_prog #0                    ; exit program
