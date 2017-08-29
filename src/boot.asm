org 0x8000

start:
        jmp short kern_start

display:
        pusha
        xor cx, cx
        mov ax, 0x1300  ; write a string without attributes
        mov bx, 0x0007  ; page=0, attributes are lgray/black
        mov dl, 0
        mov dh, [bios_row]
        inc byte [bios_row]
        mov si, bp

calc_length:
        cmp byte [si], 0
        je found
        inc cx
        inc si
        jmp calc_length
found:
        int 0x10
        popa
        ret

kern_start:
        push bp
        mov bp, kern_start_msg
        call display
        pop bp
.hang:  hlt
        jmp .hang

bios_row: db 5
kern_start_msg: db "Welcome to loliOS!", 0
.end:
