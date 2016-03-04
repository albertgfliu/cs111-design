#comment out V line for verbose output
V=@

#define CC as GCC if not already defined
CC?=gcc

#make targets
all: ioctl-nwrite

ioctl-nwrite: main.o
	$(CC) -o ../ioctl-nwrite main.o

main.o: main.c
	$(CC) -c main.c

clean:
	@echo + clean
	$(V)-rm -f main.o ../ioctl-nwrite

.PHONY: clean