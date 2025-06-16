CC = i686-elf-gcc
LD = i686-elf-ld
ASM = nasm

all: os-image

os-image: boot.bin kernel.bin
	cat boot.bin kernel.bin > os-image.bin

boot.bin: src/boot.s
	nasm -f bin src/boot.s -o boot.bin

kernel.bin: src/kernel.o src/kernel_entry.o
	$(LD) -T linker.ld src/kernel_entry.o src/kernel.o -o kernel.elf
	objcopy -O binary kernel.elf kernel.bin

src/kernel_entry.o: src/kernel_entry.s
	$(ASM) -f elf src/kernel_entry.s -o src/kernel_entry.o

src/kernel.o: src/kernel.c
	$(CC) -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c src/kernel.c -o src/kernel.o

run: os-image
	qemu-system-i386 -fda os-image.bin

clean:
	rm -f *.bin *.o *.elf && cd src/ && rm -f *.bin *.o *.elf
