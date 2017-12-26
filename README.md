# mipsIII-pipeline-cpu

## How to create testcase

```sh
# ex) hello.c
mipsel-sde-elf-gcc -mips3 -c hello.c
mipsel-sde-elf-objcopy -j .text -O binary hello.o hello.bin

# show assembly
mipsel-sde-elf-objdump -d hello.o

# show machine instructions which are loadable with ModelSim
od -An -tx4 -w4 hello.bin | tr -d ' '
```

## TODO
* 5-stage pipeline
* TLB
* address decoder (for memory mapped I/O)
* connect with SDRAM Controller (for Altera DE-10 Lite board)
* I-Memory and D-Memory set its width to 32bits, but it is not correct in some cases
* cache for I-memory and D-memory (modified harvard architecture)
