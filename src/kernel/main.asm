org 0x7e00
bits 16

jmp near start
nop

; header very important

header:
db 0, 8, 1, 2, 2, 0, 1

; constants

message: db "Hello world!", 0
badahvalue_message: db "Bad AH value!", 0
special_message: db "H", 0x0c, "e", 0x0e, "l", 0x0a, "l", 0x09, "o", 0x0b, " ", 0x07, "w", 0x0d, "o", 0x0c, "r", 0x0e, "l", 0x0a, "d", 0x09, "!", 0x0b, 0
but_colorful: db " (but colorful)", 0

align 16

start:
    jmp main

; subroutines

;
; check_header
; Description:
;   function to verify the header
;
check_header: db \
    0x60, 0xBF, 0x04, 0x7E, 0x8A, 0x25, 0x02, 0x65, \
    0x01, 0x02, 0x65, 0x02, 0x02, 0x65, 0x03, 0x02, \
    0x65, 0x04, 0x02, 0x65, 0x05, 0x02, 0x65, 0x06, \
    0x80, 0xF4, 0x0E, 0x75, 0x05, 0x61, 0x31, 0xC0, \
    0xC3, 0x61, 0xB8, 0xFF, 0xFF, 0xC3

main:
    call check_header
    cmp ax, -1
    je .halt

    mov bx, 0x20
    shl bx, 2
    mov word [bx], renix_interface
    add bx, 2
    mov word [bx], es

    mov bh, 0x07
    mov ah, 2
    int 0x20

    mov ch, 0
    mov cl, 0
    mov ah, 3
    int 0x20

    mov si, message
    mov bh, 0x07
    mov ah, 1
    int 0x20

    mov ch, 2
    mov cl, 0
    mov ah, 3
    int 0x20

    mov si, special_message
    mov ah, 5
    int 0x20

    mov cx, [0x500]
    mov ch, 3
    dec cl
    mov ah, 3
    int 0x20

    mov si, but_colorful
    mov bh, 0x07
    mov ah, 1
    int 0x20

    mov ch, 4
    mov cl, 0
    mov ah, 3
    int 0x20

.loop:
    mov ah, 4
    int 0x20

    cmp al, 0x0d
    je .newline

    cmp al, 0x08
    je .backspace

    mov bh, 0x0f
    mov ah, 0
    int 0x20

    jmp .loop

.newline:
    mov cx, [0x500]
    inc ch
    mov cl, 0
    mov ah, 3
    int 0x20

    mov ah, 7
    int 0x20

    jmp .loop

.backspace:
    mov cx, [0x500]
    dec cl
    cmp cl, 0
    jnl .backspace.after_adjust_cl
    mov cl, 0
.backspace.after_adjust_cl:
    mov ah, 3
    int 0x20

    mov al, " "
    mov bh, 0x0f
    mov ah, 0
    int 0x20

    mov cx, [0x500]
    dec cl
    mov ah, 3
    int 0x20

    jmp .loop

.halt:
    jmp $

times (512*8)-($-$$) db 0x90

%include "src/kernel/renix_interface.asm"

times (512*16)-($-$$) db 0x90