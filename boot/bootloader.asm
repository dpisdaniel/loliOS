org 7C00h

start:
        jmp boot_start

loader_startup_msg: db "loli loader!", 0
drive_resetting: db "drive resetting!", 0
loading_kernel_msg: db "loading kernel!", 0
kernel_jmp_msg: db "jumping to kernel!", 0
bios_row: db 0

loli_signature:         db 'loliLoader', 0
drive_number:           db 0x00      ; bios compliant drive num
KERNEL_START_OFFSET    equ 0x8000 ; initial ip value
KERNEL_START_SELECTOR  equ 0x0008 ; initial cs selector value (index 1)

%macro display_msg 1
        push bp
        mov bp, %1
        call display
        pop bp
%endmacro

; Clear screen using the bios
cls:
        pusha
        mov ax, 0x0600 ; clear the window
        mov cx, 0x0000 ; from 0,0
        mov dx, 0x184f ; to 24,79
        mov bh, 0x07   ; keep light gray display
        int 0x10
        popa
        ret

; Displays a null terminated string on the screen and incrementing the row counter
; takes the string from es:bp as required by the bios. assumes ds == es
display:
        pushf
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
        popf
        ret

enable_a20:
        ret

detect_mem:
        ret

; Loads the kernel into memory.
; Changes ax, dx, si and carry flag
load_kernel:
        xor ax, ax
        xor dh, dh
        display_msg drive_resetting
reset_drive:
        mov dl, [drive_number]
        int 0x13
        jc reset_drive ; cf is set if failed
        display_msg loading_kernel_msg
load:
        mov dl, [drive_number]
        mov ah, 42h
        mov si, disk_address_packet ; dap in ds:si
        int 0x13
        jc load ; cf is set if failed
        ret

boot_start:
        cli
        mov [drive_number], dl
        xor ax,ax
        mov dx, ax
        mov ss, ax
        mov es, ax
        mov sp, 0x7c00 ; will grown downwards from the beginning of the boot sector in RAM
        call cls
        display_msg loader_startup_msg
        call enable_a20
        call detect_mem
        call load_kernel
        display_msg kernel_jmp_msg
        jmp 0x8000
        hlt

align 4
disk_address_packet:
db 0x10
db 0x00
dw 0x64
dd 0x08000000
dq 0x01

gdt_pointer:
dw 0x1234
dq 0x1234123412341234

times 200h - 2 - ($ - $$) db 0  ; fill the rest of the boot sector except the last 2 bytes with 0s

dw 0AA55h ; Boot sector sig
