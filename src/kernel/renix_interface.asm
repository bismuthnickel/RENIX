; system interface routines

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
    je .puts
    cmp ah, 2
    je .clear
    cmp ah, 3
    je .set_cursor
    cmp ah, 4
    je .get_key
    cmp ah, 5
    je .special_puts
    cmp ah, 6
    je .set_format
    jmp .badahvalue
    db "putc"
.putc:
    call putc
    jmp .return
.puts:
    call puts
    jmp .return
.clear:
    call clear
    jmp .return
.set_cursor:
    call set_cursor
    jmp .return
.get_key:
    xor ah, ah
    int 0x16
    jmp .return
.special_puts:
    call special_puts
    jmp .return
.set_format:
    push cx
    mov [putc.lastformat], bh
    mov cx, [0x500]
    call set_cursor
    pop cx
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
    retf

renix_interface_interrupt:
    call renix_interface
    iret

;
; clear
; Description:
;   Clears the video memory
; Parameters:
;   - BH: formatting
;
clear:
    pusha
    mov [putc.lastformat], bh
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
;   Sets the cursor, including hardware
;   cursor, and changes the foreground
;   color at the new position to match
;   the last character printed.
; Parameters:
;   - CH: row
;   - CL: column
;
set_cursor:
    pusha
    mov [0x500], cx
    mov dx, cx
    xor bh, bh
    mov ah, 0x02
    int 0x10
    mov al, ch
    xor ch, ch
    xor ah, ah
    mov bx, 80
    mul bx
    mov bx, ax
    add bx, cx
    shl bx, 1
    mov dl, [fs:bx+1]
    and dl, 0xf0
    mov dh, [putc.lastformat]
    and dh, 0x0f
    or dl, dh
    mov byte [fs:bx+1], dl
    popa
    ret
.cursor: dw 0

;
; get_1d
; Description:
;   Converts 2D cursor to
;   1D
; Parameters:
;   - CH: row
;   - CL: column
; Returns:
;   - CX: 1D cursor
;
get_1d:
    pusha
    mov al, ch
    xor ch, ch
    xor ah, ah
    mov bx, 80
    mul bx
    mov bx, ax
    add bx, cx
    shl bx, 1
    mov [.results], bx
    popa
    mov cx, [.results]
    ret
.results: dw 0

;
; get_2d
; Description:
;   Converts 1D cursor to
;   2D
; Parameters:
;   - CX: 1D cursor
; Returns:
;   - CH: row
;   - CL: column
;
get_2d:
    pusha
    mov ax, cx
    mov cx, 80
    xor dx, dx
    div cx
    shl ax, 8
    or ax, dx
    mov [.results], ax
    popa
    mov cx, [.results]
    ret
.results: dw 0

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
    mov dh, bh
    mov dl, al
    mov [.lastformat], dh
    mov cx, [0x500]
    call get_1d
    mov bx, cx
    mov [fs:bx], dx
    mov cx, [0x500]
    inc cl
    cmp cl, 80
    jng .le
    inc ch
    xor cl, cl
.le:
    call set_cursor
    popa
    ret
.lastformat: db 0x07

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
; puts
; Description:
;   Prints a string with formatting
;   information after every byte
; Parameters:
;   - SI: pointer to string
;
special_puts:
    push ax
    push bx
.loop:
    mov al, [si]
    or al, al
    jz .return
    mov ah, [si+1]
    add si, 2
    mov bh, ah
    call putc
    jmp .loop
.return:
    pop bx
    pop ax
    ret