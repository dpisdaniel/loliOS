mkdir -p ./bin
cd ./src
nasm  boot.asm -o ../bin/kernel.sys -l ../bin/kernel-dbgz.txt
cd ../

cd ./boot
nasm -f bin bootloader.asm -o ../bin/loliloader.bin
cd ../

cat ./bin/loliloader.bin ./bin/kernel.sys > ./bin/complete.sys

dd if=./bin/complete.sys of=./bin/loli.image bs=512 conv=notrunc
