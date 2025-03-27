org 0x7e00
bits 16

jmp start

; constants

message: db "Hello world!", 0
badahvalue_message: db "Bad AH value!", 0

align 16

start:
    jmp main

; subroutines

;
; clear
; Description:
;   Clears the video memory
; Parameters:
;   - BH: formatting
;
clear:
    pusha
    mov al, bh
    mov cx, 80*25
.loop:
    mov bx, cx
    shl bx, 1
    mov [fs:bx-1], al
    mov byte [fs:bx-2], 0
    dec cx
    jnz .loop
    popa
    ret

;
; setcursor
; Description:
;   Sets the text mode cursor
; Parameters:
;   - CX: 1d cursor
;
set_cursor:
    pusha
    mov [0x7c00], cx
    pusha
    mov ax, cx
    mov cx, 80
    xor dx, dx
    div cx
    shl ax, 8
    or ax, dx
    mov [.cursor], ax
    popa
    mov ax, [.cursor]
    mov bh, 0
    mov dh, ah
    mov dl, al
    mov ah, 0x02
    int 0x10
    mov bh, [putc.lastformat]
    and bh, 0x0f
    mov di, [0x500]
    mov bl, [fs:di+1]
    and bl, 0xf0
    add bh, bl
    mov di, cx
    shl di, 1
    inc di
    mov [fs:di], bh
    popa
    ret
.cursor: dw 0

;
; putc
; Description:
;   Prints a single character
; Parameters:
;   - AL: character
;   - BH: formatting
;
putc:
    pusha
    mov [.lastformat], bh
    mov di, [0x500]
    mov [fs:di], al
    mov [fs:di+1], bh
    add di, 2
    mov [0x500], di
    mov cx, di
    shr cx, 1
    call set_cursor
    popa
    ret
.lastformat: db 0

;
; puts
; Description:
;   Prints a string, null terminated
; Parameters:
;   - SI: pointer to string
;   - BH: formatting
;
puts:
    push ax
    push bx
.loop:
    lodsb
    or al, al
    jz .return
    call putc
    jmp .loop
.return:
    pop bx
    pop ax
    ret

;
; renix_interface
; Description:
;   Interface for RENIX that includes
;   mostly graphics-related functions,
;   and some for user input.
;   Function is selected using AH
; Paramaters:
;   - AH: function
;   - others: function specific
; Returns:
;   - none
;
renix_interface:
    cmp ah, 0
    je .putc
    cmp ah, 1
    je .print
    cmp ah, 2
    je .clear
    cmp ah, 3
    je .set_cursor
    cmp ah, 4
    je .get_key
    jmp .badahvalue
    db "putc"
.putc:
    call putc
    jmp .return
.print:
    call puts
    jmp .return
.clear:
    call clear
    jmp .return
.set_cursor:
    call set_cursor
    jmp .return
.get_key:
    mov ah, 0x00
    int 0x16
    jmp .return
.badahvalue:
    pusha
    push word [0x500]
    mov word [0x500], 0
    mov si, badahvalue_message
    mov bh, 0x1f
    call puts
    pop word [0x500]
    popa
    jmp .return
.return:
    ret

main:
    mov bh, 0x07
    mov ah, 2
    call renix_interface

    hlt

times (512*4)-($-$$) db 0