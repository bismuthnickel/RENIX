org 0x7c00
bits 16

main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov ss, ax
    
    mov ax, 0xb800
    mov fs, ax

    mov sp, 0x7c00

    mov word [0x500], 0

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    mov ah, 0x01
    mov cx, 0x0007
    int 0x10

    mov ah, 0x02
	mov al, 16
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov bx, 0x7e00
	int 0x13

    jmp 0x7e00

    jmp $

times 510-($-$$) db 0x90
dw 0xaa55