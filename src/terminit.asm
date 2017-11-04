; loliOS - a 32 bit OS written in Assembly
; Copyright (C) 2017 dpisdaniel -- see LICENSE

; void copy_vga_buf(void)
; Copies the VGA buffer VGA_BUFFER to our kernel's local buffer
; KERNEL_SCREEN_BUF.
copy_vga_buf:
        push ecx
        pushfd
        cld
        mov ecx, VGA_WIDTH * VGA_HEIGHT
        mov edi, KERNEL_SCREEN_BUF
        mov esi, VGA_BUFFER
        rep movsw
        popfd
        pop ecx
        ret

terminal_init:
        xor eax, eax  ; terminal row
        xor ebx, ebx  ; terminal column
        xor edx, edx  ; terminal color
        call clear_screen

; void write_char(unsigned char c, unsigned char forecolour, unsigned char backcolour, int x, int y)
; Writes one character to the screen at the gives positions.
write_char:
        fn_prologue
        push eax
        push ecx
        push edx
        sub esp, 4              ; 1 local var
        mov ebx, KERNEL_SCREEN_BUF
        mov_arg(ecx, 3)         ; Forecolour
        mov_arg(edx, 4)         ; Backcolour
        shl edx, 4
        and ecx, 0x0F
        or edx, ecx             ; Attribute
        store_local_var(edx, 0)
        mov_arg(eax, 6)         ; y
        mov_arg(ecx, 5)         ; x
        mov edx, VGA_WIDTH
        mul edx                 ; Should never contain anythign relevant to the result after the multiplication
        add eax, ecx            ; The write offset before the 2 scalar (every VGA char is a short)
        mov esi, get_local_var(0)
        shl esi, 8
        or esi, get_arg(2)
        mov [ebx + eax * 2], esi
        call update_vga_buf
        add esp, 4
        pop edx
        pop ecx
        pop eax
        pop ebp
        ret

; void write_string(
write_string:
        fn_prologue
        push eax
        push ecx
        push edx

        pop edx
        pop ecx
        pop eax
        ret

; void clear_screen(void)
; Clears the screen by placing blank characters in the buffer.
clear_screen:
        push ecx
        push eax
        pushfd
        cld
        xor ecx, ecx
        mov edi, KERNEL_SCREEN_BUF
        mov ax, VGA_BLANK_CHAR
        mov cx, VGA_WIDTH * VGA_HEIGHT
        rep stosw
        call update_vga_buf
        popfd
        pop eax
        pop ecx
        ret

; void update_vga_buf(void)
; Updates the VGA buffer according to our internal system buffer
update_vga_buf:
        push ecx
        pushfd
        cld
        mov esi, KERNEL_SCREEN_BUF
        mov edi, VGA_BUFFER
        mov cx, VGA_WIDTH * VGA_HEIGHT
        rep movsw
        popfd
        pop ecx
        ret


