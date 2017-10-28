# loliOS ABI/Calling Conventions

## Why
A proper convention for function parameters is necessary to keep
myself from going crazy trying to use my own functions in the future.
I will use a calling convention similiar to cdecl.

## What
Function arguments are passed on the stack.
Integers and memory addresses are returned in EAX.
Floating point values (if I'll ever have the pleasure of using those in this OS)
will be returned on the ST0 register.

Registers EAX, ECX, and EDX are caller-saved and the rest are callee-saved.
ST0-ST7 must be empty upon calling a new function, and ST1-ST7 must be empty upon function exit.
ST0 must also be empty when not used for returning a value.

Function documentation in the source code comments will describe the function signatur with C style.
Therefore, the arguments described in the signature will be pushed to the stack in reverse order,
meaning the rightmost argument is pushed first and goes left i.e:

```C
int callee(int a, int b);

Will translate to:

push b
push a
```

