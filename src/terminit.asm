terminal_init:
        xor eax, eax  ; terminal row
        xor ebx, ebx  ; terminal column
        xor edx, edx  ; terminal color
        push byte [vga_colors + 7] ; foreground color
        push byte [vga_colors] ; background color
        call vga_entry_color
        pop
        pop

vga_entry_color:
        push ebp
        mov ebp, esp
        mov esi, [ebp + 8] ; background color
        mov edi, [ebp + 12] ; foreground color
        shl esi, 4
        or edi, esi
        mov edx, edi
        pop ebp
        ret
