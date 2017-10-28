#!/bin/bash

cmd=( qemu-system-x86_64
        -m 256
        -hda ./bin/loli.image
        #-drive id=disk,file=./bin/loli.image,if=none,format=raw
        -s
        -S
)

"${cmd[@]}"

