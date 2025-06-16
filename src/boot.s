; bootloader
[org 0x7C00]
[BITS 16]

start:
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    mov si, boot_msg
    call print_string
    call load_kernel
    mov si, switching_msg
    call print_string
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

load_kernel:
    mov bx, 0x7E00
    mov dh, 1
    mov dl, 0x00
    call disk_load
    ret

disk_load:
    pusha
    push dx
    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    int 0x13
    jc disk_error
    pop dx
    cmp al, dh
    jne disk_error
    popa
    ret

disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $

[BITS 32]

protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000
    mov edi, 0xb8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    call 0x7E00

gdt_start:
gdt_null:
    dd 0x0
    dd 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dw gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

boot_msg db "ferOs loading kernel...", 13, 10, 0
switching_msg db "Switching to protected mode...", 13, 10, 0
disk_error_msg db "Disk read error", 0

times 510-($-$$) db 0
dw 0xAA55
