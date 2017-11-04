; loliOS - a 32 bit OS written in Assembly
; Copyright (C) 2017 dpisdaniel -- see LICENSE

BITS 32
org 0x8000

%include "helpers/stack_help.asm"

start:
        jmp short kern_start

; Main kernel function.
; A few assumptions about how we were loaded from loliBooter:
; We have been loaded in physical address 0x8000
; Interrupts are off
; We are in protected mode (Should not use BIOS interrupts here)
; No IDT set
kern_start:
        call copy_vga_buf
        push_args 0x63, VGA_DEF_FG, VGA_DEF_BG, 50, 20
        call write_char
.hang:  hlt
        jmp .hang

bios_row: db 5
kern_start_msg: db "Welcome to loliOS!", 0

%include "consts.asm"
%include "terminit.asm"

.end:
