
; Constant system strings
sys_version:            db 'loliOS ver 0.1', 0
ready_message:          db 'loliOS is ready', 13, 0
; Color pallete
vga_colors:
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
vga_buffer:             equ 0x000B8000
; Byte global variables DB
vga_width:  equ 80
vga_height: equ 25

