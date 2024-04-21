/*
  struct sockaddr_in {
    uint8       sin_len;
    uint8       sin_family;
    uint16      sin_port;
    uint32      sin_addr;
    char        sin_zero[8];
  }

  int socket(int domain, int type, int protocol)
  int bind(int fd, const struct sockaddr *, socklen_t)
  int listen(int fd, int backlog)
  int close(int fd)
  int fcntl(int fd, int cmd, long arg)
 */

.global main
.align 4

.equ AF_INET, 0x2
.equ SOCK_STREAM, 0x1
.equ IPPROTO_IP, 0x0
.equ INADDR_ANY, 0x00000000
.equ PF_INET, 0x2
.equ PORT, 4321
.equ F_SETFL, 0x4
.equ O_NONBLOCK, 0x00000004

.macro exit_prog $code
  mov x0, \$code
  mov x16, #1
  svc 0
.endm

.macro handle_error $error_message, $error_message_len
  mov x19, x0
  mov x0, #1
  adr x1, \$error_message
  ldr x2, =\$error_message_len
  mov x16, #4
  svc 0

  exit_prog x19
.endm

error_message_socket: .string "Could not create socket\n"
error_message_socket_len = . - error_message_socket
.align 2
error_message_bind: .string "Could not bind to port\n"
error_message_bind_len = . - error_message_bind
.align 2
error_message_listen: .string "Error while listening\n"
error_message_listen_len = . - error_message_listen
.align 2
message_listen: .string "Listening for connections\n\n"
message_listen_len = . - message_listen
.align 2

main:
  ; server_socket
  mov x0, AF_INET            ; domain = AF_INET = 2
  mov x1, SOCK_STREAM        ; type = SOCK_STREAM = 1
  mov x2, IPPROTO_IP         ; protocol = IPPROTO_IP = 0
  mov x16, #97               ; syscall socket
  svc 0

  cmp x0, xzr
  ble error_socket

  mov x19, x0                ; store server_socket fd in x19

  ;fcntl
  mov x0, x19                ; sockfd = server_socket;
  mov x1, F_SETFL            ; cmd = F_SETFL = 4
  mov x2, O_NONBLOCK         ; arg = O_NONBLOCK = 4
  mov x16, #92               ; syscall fcntl
  svc 0

  ; server_address
  mov  x3, #0x0200           ; sin_len = 0, sin_family = PF_INET = 2
  movk x3, #0xD204, lsl #0x10  ; sin_port = 1234
  movk x3, 0x0000, lsl #0x20   ; sin_addr = INADDR_ANY
  movk x3, 0x0000, lsl #0x30   ; ...
  stp  x3, xzr, [sp, #-0x10]!  ; push server_address to the stack

  ; bind
  mov x0, x19                ; sockfd = server_socket;
  add x1, sp, xzr            ; *sockaddr = server_address;
  mov x2, #0x10              ; socklen_t = sizeof(server_address) = 16 bytes
  mov x16, #104              ; syscall bind
  svc 0

  cmp x0, xzr
  b.ne error_listen

  ; listen
  mov x0, x19                ; sockfd = server_socket;
  mov x1, #1                 ; backlog = 1
  mov x16, #106              ; syscall listen
  svc 0

  cmp x0, xzr
  b.ne error_listen

  mov x0, #1
  adr x1, message_listen
  ldr x2, =message_listen_len
  mov x16, #4
  svc 0

  ; loop
  loop:
  ; accept
  ; client_socket
  b loop

  ; close
  mov x0, x19                ; sockfd = server_socket;
  mov x16, #6                ; syscall close
  svc 0

  exit_prog xzr
error_listen:
  mov x19, x0
  mov x0, #1
  adr x1, error_message_listen
  ldr x2, =error_message_listen_len
  mov x16, #4
  svc 0

  exit_prog x19
error_bind:
  mov x19, x0
  mov x0, #1
  adr x1, error_message_bind
  ldr x2, =error_message_bind_len
  mov x16, #4
  svc 0

  exit_prog x19
error_socket:
  mov x19, x0
  mov x0, #1
  adr x1, error_message_socket
  ldr x2, =error_message_socket_len
  mov x16, #4
  svc 0

  exit_prog x19