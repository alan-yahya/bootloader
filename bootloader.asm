; Enhanced System Monitor Bootloader
[org 0x7c00]
[bits 16]

; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Set video mode (clear screen)
    mov ah, 0x00
    mov al, 0x03      ; 80x25 text mode
    int 0x10

    ; Hide cursor
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10

main_loop:
    ; Clear screen
    mov ah, 0x06    ; Scroll up function
    xor al, al      ; Clear entire screen
    xor cx, cx      ; Upper left corner
    mov dx, 0x184F  ; Lower right corner
    mov bh, 0x07    ; Normal attributes
    int 0x10
    
    ; Display title
    mov si, title
    mov dh, 0       ; Row 0
    mov dl, 25      ; Column 25
    mov bl, 0x0F    ; White on black
    call print_string
    
    ; Display CPU info
    mov si, cpu_msg
    mov dh, 2       ; Row 2
    mov dl, 2       ; Column 2
    mov bl, 0x0A    ; Green
    call print_string
    
    ; Display GPU info
    mov si, gpu_msg
    mov dh, 4       ; Row 4
    mov dl, 2       ; Column 2
    mov bl, 0x0D    ; Magenta
    call print_string
    
    ; Get video mode
    mov ah, 0x0F
    int 0x10
    push ax         ; Save video mode
    
    mov si, mode_msg
    mov dh, 5
    mov dl, 4
    mov bl, 0x07
    call print_string
    
    pop ax
    xor ah, ah      ; Clear AH, keep AL (mode)
    call print_number
    
    ; Get video state
    mov ah, 0x12
    mov bl, 0x10
    int 0x10
    
    ; Display adapter type
    mov si, adapter_msg
    mov dh, 6
    mov dl, 4
    call print_string
    
    mov si, unknown_msg   ; Default to unknown
    cmp ch, 0
    je .print_adapter
    mov si, vga_msg
    cmp ch, 1
    je .print_adapter
    mov si, ega_msg
    cmp ch, 2
    je .print_adapter
    mov si, cga_msg
    cmp ch, 3
    je .print_adapter
    mov si, mda_msg
    cmp ch, 4
    je .print_adapter
    
.print_adapter:
    call print_string
    
    ; Display memory
    mov si, mem_msg
    mov dh, 8       ; Row 8
    mov dl, 2
    mov bl, 0x0B    ; Cyan
    call print_string
    
    int 0x12        ; Get memory size in AX
    call print_number
    mov si, kb_msg
    call print_string
    
    ; Display time/date
    mov si, time_msg
    mov dh, 10      ; Row 10
    mov dl, 2
    mov bl, 0x0E    ; Yellow
    call print_string
    
    ; Get time
    mov ah, 0x2C
    int 0x21
    
    mov al, ch      ; Hours
    call print_dec
    mov si, colon
    call print_string
    mov al, cl      ; Minutes
    call print_dec
    
    ; Check for keypress
    mov ah, 0x01
    int 0x16
    jnz exit_monitor
    
    mov cx, 0x0FFF
    loop $
    jmp main_loop

exit_monitor:
    int 0x20        ; Exit to DOS

; Print string (SI=string, DH=row, DL=col, BL=color)
print_string:
    push ax
    mov ah, 0x02    ; Set cursor position
    xor bh, bh
    int 0x10
.loop:
    lodsb           ; Load next character
    test al, al     ; Check for null terminator
    jz .done
    mov ah, 0x09    ; Write character
    mov cx, 1       ; One character
    int 0x10
    inc dl          ; Move cursor right
    mov ah, 0x02    ; Set new cursor position
    int 0x10
    jmp .loop
.done:
    pop ax
    ret

; Print number in AX
print_number:
    push ax
    push cx
    push dx
    mov cx, 0       ; Digit counter
    mov bx, 10      ; Divisor
.divide:
    xor dx, dx
    div bx
    push dx         ; Save remainder
    inc cx
    test ax, ax
    jnz .divide
.print:
    pop dx
    add dl, '0'
    mov ah, 0x09
    mov al, dl
    mov cx, 1
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    loop .print
    pop dx
    pop cx
    pop ax
    ret

; Print decimal byte (AL)
print_dec:
    push ax
    push bx
    xor ah, ah
    mov bl, 10
    div bl
    add al, '0'
    mov bl, ah
    mov ah, 0x09
    mov cx, 1
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    mov al, bl
    add al, '0'
    mov ah, 0x09
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    pop bx
    pop ax
    ret

; Data section
title:       db 'System Monitor', 0
cpu_msg:     db 'CPU: 8086/8088', 0
gpu_msg:     db 'Graphics:', 0
mode_msg:    db 'Mode: ', 0
adapter_msg: db 'Type: ', 0
vga_msg:     db 'VGA', 0
ega_msg:     db 'EGA', 0
cga_msg:     db 'CGA', 0
mda_msg:     db 'MDA', 0
unknown_msg: db 'Unknown', 0
mem_msg:     db 'Memory: ', 0
kb_msg:      db 'KB', 0
time_msg:    db 'Time: ', 0
colon:       db ':', 0

; Boot sector magic
times 510-($-$$) db 0
dw 0xAA55 