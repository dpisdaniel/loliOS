; loliOS - a 32 bit OS written in Assembly
; Copyright (C) 2017 dpisdaniel -- see LICENSE

; General macros and definitions for utilizing the stack better
; For a better explanation of macros refer to the NASM docs
; starting from section 4.3

%macro clean_stack 1
        add esp, %1
        pop ebp
%endmacro

%macro fn_prologue 0
        push ebp
        mov ebp, esp
%endmacro

%macro prologue 1
        push ebp
        mov ebp, esp
        sub esp, %1
%endmacro

; Pushes all the parameters given on the stack.
; Should be used to push arguments to a function.
; The arguments should be ordered like the order
; of the function C declaration for arguments to be pushed
; in the correct order.
; i.e
; void m_eme(int a, char b)
; push_args a, b
; to push the arguments correctrly
%macro push_args 1-*
        %rep %0
        push dword %{-1:-1} ; Will always push the last parameter
        %rotate -1
        %endrep
%endmacro

; Moves the function parameter at index arg_index into
; register reg.
; The parameter indexes start from 2 (yes stupid) for the leftmost parameter
; in the function's C declaration.
%define mov_arg(reg, arg_index) mov reg, [ebp + 4 * arg_index]

%define get_arg(arg_index) [ebp + 4 * arg_index]

; Moves the local function variable at index local_var_ind
; into register reg.
; The variable indexes start from 0 for the variable at address esp
; and are each 4 bytes.
%define mov_local_var(reg, local_var_ind) mov reg, [esp + 4 * local_var_ind]

; Same as mov_local_var but stores a local variable on the stack
%define store_local_var(reg, local_var_ind) mov [esp + 4 * local_var_ind], reg

%define get_local_var(local_var_ind) [esp + 4 * local_var_ind]

