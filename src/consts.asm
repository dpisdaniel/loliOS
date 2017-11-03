; loliOS - a 32 bit OS written in Assembly
; Copyright (C) 2017 dpisdaniel -- see LICENSE

; Constant system strings
SYS_VERSION:            db 'loliOS ver 0.1', 0
READY_MESSAGE:          db 'loliOS is ready', 13, 0

; Mem addresses
BIOS_MMAP               equ 0x00020000 ; 24 bytes per entry, BIO_MMAP_LENGTH x 24 bytes
BIOS_MMAP_LENGTH        equ 0x00021000 ; 2 bytes
KERNEL_START            equ 0x00008000 ; TODO: Add padding to wanted length

; Color pallete
VGA_COLORS:
db 0  ; black
db 1  ; blue
db 2  ; green
db 3  ; cyan
db 4  ; red
db 5  ; magenta
db 6  ; brown
db 7  ; light grey
db 8  ; dark grey
db 9  ; light blue
db 10 ; light green
db 11 ; light cyan
db 12 ; light red
db 13 ; light magenta
db 14 ; light brown
db 15 ; white

; Constant addresses
VGA_BUFFER      equ 0x000B8000
; Constant values
VGA_WIDTH       equ 80
VGA_HEIGHT      equ 25
VGA_DEF_BG      equ 00 ; black - 4 bits
VGA_DEF_FG      equ 01 ; blue  - 4 bits
