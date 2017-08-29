#!/bin/bash

cmd=( qemu-system-x86_64
        -m 256
        -drive id=disk,file=./bin/loli.image,if=none,format=raw
        ./bin/loliloader.bin
        -s
        -S
)

"${cmd[@]}"

