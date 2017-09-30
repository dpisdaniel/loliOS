org 7C00h
; Hi I like documentation
start:
        jmp boot_start

loader_startup_msg: db "loli loader!", 0
drive_resetting: db "drive resetting!", 0
loading_kernel_msg: db "loading kernel!", 0
kernel_jmp_msg: db "jumping to kernel!", 0
bios_row: db 0

loli_signature:         db 'loliLoader', 0
drive_number:           db 0x00                 ; bios compliant drive num
KERNEL_START_OFFSET     equ 0x8000              ; initial ip value
KERNEL_START_SELECTOR   equ 0x0008              ; initial cs selector value (index 1)
MMAP_LIST_SEG           equ 0x300
MMAP_INT_MAGIC          equ 0x0534D4150
MMAP_START_ADDR         equ 0x2000              ; 24 bytes per entry, max 1024 entries. real address will be 0x20000
MMAP_ENTRY_AMOUNT       equ 0x0002100           ; 2 bytes

; Displays a message using bios interrupts.
; Receives a pointer to a null terminated message to display
; using bios interrupts
; Preserves all registers
%macro display_msg 1
        push bp
        mov bp, %1
        call display
        pop bp
%endmacro

; Clear screen using the bios
; Preserves all registers
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
; Preserves all registers.
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

; Enables the A20 line in preparation for protected mode.
; Does so by ORing a bit that signals the keyboard controller to enable the A20 line
; (yes this is retarded lmao)
; Changes the AX register
enable_a20:
        call a20wait
        mov al, 0xAD
        out 0x64, al

        call a20wait
        mov al, 0xD0
        out 0x64, al

        call a20wait2
        in al, 0x60
        push eax

        call a20wait
        mov al, 0xD1
        out 0x64, al

        call a20wait
        pop eax
        or al, 2
        out 0x60, al

        call a20wait
        mov al, 0xAE
        out 0x64, al

        call a20wait
        ret

a20wait:
        in al, 0x64
        test al, 2
        jnz a20wait
        ret

a20wait2:
        in al, 0x64
        test al, 1
        jz a20wait2
        ret

; Writes a mem map to ES:DI using the INT 0x15, eax=0xE820 BIOS function
; Input: ES:DI -> destination buffer for 24 byte ACPI 3.X compliant entries
; Output: si = amount of entries.
; Changes all registers except bp
dm:
        xor ebx, ebx
        xor si, si
        mov edx, MMAP_INT_MAGIC
        mov eax, 0xE820
        mov [es:di + 20], dword 1       ; Forces a valid ACPI 3.X entry
        mov ecx, 24
        int 0x15
        jc  short dm_err
        mov edx, MMAP_INT_MAGIC
        cmp eax, edx
        jne short dm_err
        test ebx, ebx
        je short dm_err
        jmp short dm_next
dm_list_complete:
        mov eax, 0xE820                 ; ecx and eax get trashed every call
        mov [es:di + 20], dword 1       ; so restore them
        mov ecx, 24
        int 0x15
        jc short dm_finalize
        mov edx, MMAP_INT_MAGIC
dm_next:
        jcxz dm_skip_entry
        cmp cl, 20
        jbe short dm_no_text
        test byte [es:di + 20], 1
        je short dm_skip_entry
dm_no_text:
        mov ecx, [es:di + 8]
        or ecx, [es:di + 12]
        jz dm_skip_entry
        inc si
        add di, 24
dm_skip_entry:
        test ebx, ebx
        jne short dm_list_complete
dm_finalize:
        mov eax, MMAP_ENTRY_AMOUNT
        mov es, eax
        mov [es:0], si
        clc                            ; Jumps here from a cf so clear it
        ret
dm_err:
        stc
        ret

; Loads the kernel into memory.
; Changes ax, dx, si and the carry flag
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

; Main function of the bootloader
; Initializes relevant things to enter protected mode and
; loads the kernel from our disc to then jump to it.
; It is very simple but I wanted to atleast create my own bootloader
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
        push es
        mov ax, MMAP_START_ADDR
        mov es, ax
        call dm
        pop es
        call load_kernel
        display_msg kernel_jmp_msg
        lgdt [GDT_DESC]
        mov eax, cr0
        or eax, 1       ; Enables protected mode
        mov cr0, eax
        mov ax, 10h
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax
        jmp KERNEL_START_SELECTOR:KERNEL_START_OFFSET
        hlt

align 4
disk_address_packet:
db 0x10                 ; a 16 byte packet
db 0x00                 ; Reserved lmaoooooo
dw 0x0064               ; The amount of blocks we want to load (blocksize 512)
dd 0x08000000           ; segment and offset to load the blocks to (segment 0x800 and offset 0, in real mode = 0x8000)
dq 0x0000000000000001   ; First block (the block after the bootloader, starting from index 0)

GDT_DESC:
dw 0x18         ; Size of GDT in bytes, should probably be 0x17 since the rule said to decrease the size by 1
dd GDT          ; Pointer to the GDT

GDT:
; Null selector
dq 0x0000000000000000
; Code selector
dq 0x00C19A0000000000 ; 256 Mega bytes of addresses starting from address 0. granularity is 4KiB
; Data selector
dq 0x00C1920000000000 ; 256 Mega bytes of addresses starting from address 0. granularity is 4KiB

times 200h - 2 - ($ - $$) db 0  ; fill the rest of the boot sector except the last 2 bytes with 0s

dw 0AA55h ; Boot sector sig
