org 0x7e00
bits 16

jmp start

; constants

message: db "Hello world!", 0
badahvalue_message: db "Bad AH value!", 0
special_message: db "H", 0x0c, "e", 0x0e, "l", 0x0a, "l", 0x09, "o", 0x0b, " ", 0x07, "w", 0x0d, "o", 0x0c, "r", 0x0e, "l", 0x0a, "d", 0x09, "!", 0x0b, 0

align 16

start:
    jmp main

; subroutines

main:
    mov bx, 0x20
    shl bx, 2
    mov word [bx], renix_interface
    add bx, 2
    mov word [bx], es

    mov bh, 0x1e
    mov ah, 2
    int 0x20

    mov ch, 0
    mov cl, 3
    mov ah, 3
    int 0x20

    mov si, message
    mov bh, 0x1f
    mov ah, 1
    int 0x20

    mov si, special_message
    mov ah, 5
    int 0x20

    mov bh, 0x1f
    mov ah, 6
    int 0x20

    jmp $

times (512*8)-($-$$) db 0

%include "src/kernel/renix_interface.asm"

times (512*16)-($-$$) db 0