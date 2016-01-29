sort: sort.o
	gcc -m32 -o sort sort.o

%.o: %.asm
	nasm -felf -o $@ $<
