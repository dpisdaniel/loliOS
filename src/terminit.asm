; loliOS - a 32 bit OS written in Assembly
; Copyright (C) 2017 dpisdaniel -- see LICENSE

terminal_init:
        xor eax, eax  ; terminal row
        xor ebx, ebx  ; terminal column
        xor edx, edx  ; terminal color
        push word [VGA_COLORS + 7] ; foreground color
        push word [VGA_COLORS] ; background color

; void write_char(unsigned char c, unsigned char forecolour, unsigned char backcolour, int x, int y)
; Writes one character to the screen at the gives positions
write_char:
        fn_prologue
        push eax
        push ecx
        push edx
        sub esp, 4              ; 1 local var
        mov ebx, VGA_BUFFER
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
        add esp, 4
        pop edx
        pop ecx
        pop eax
        pop ebp
        ret

