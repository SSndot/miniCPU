export
CROSS	:=	riscv64-linux-gnu-
GCC		:=	${CROSS}gcc
LD		:=	${CROSS}ld
OBJCOPY	:=	${CROSS}objcopy
OBJDUMP	:=	${CROSS}objdump

NAME=kernel
TARGET_DIR=build
ELF=${TARGET_DIR}/${NAME}.elf
BIN=${TARGET_DIR}/${NAME}.bin
DUMP=${TARGET_DIR}/${NAME}.dump
SIM=${TARGET_DIR}/sim.elf
COE=${TARGET_DIR}/${NAME}.coe

ISA  	:=	rv64ifd
ABI  	:=	lp64d

INCLUDE := 	-I $(shell pwd)/include -I $(shell pwd)/arch/riscv/include
CF 		:= 	-g3 -march=$(ISA) -mabi=$(ABI) -mcmodel=medany 		\
			-fno-builtin -ffunction-sections -fdata-sections 	\
			-nostartfiles -nostdlib -nostdinc -static -lgcc -Wl,--nmagic -Wl,--gc-sections
LDFLAGS	:= -L $(shell dirname $(shell ${GCC} “-march=$(ISA)” -print-libgcc-file-name)) -lgcc
CFLAG 	:= 	${CF} ${INCLUDE}

.PHONY:all run debug clean

all:
	${MAKE} -C lib all
	${MAKE} -C init all
	${MAKE} -C arch/riscv all
	@echo -e '\n'Build Finished OK
	mkdir -p build
	make $(ELF)
	make $(BIN)
	make $(DUMP)
	make $(COE)

run: all
	@echo Launch the qemu ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default 

debug: all
	@echo Launch the qemu for debug ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default -S -s


$(ELF): vmlinux
	cp vmlinux $(ELF)

$(BIN): $(ELF)
	${OBJCOPY} -O binary $(ELF) $(BIN)

$(DUMP): $(ELF)
	$(OBJDUMP) -d $^ > $@

$(COE): $(BIN)
	od -t x4 -An -w1 -v $^ | sed -e 's/ //g' -e 's/$$/,/' > $@
	sed -i '1i memory_initialization_vector=' $@
	sed -i '1i memory_initialization_radix=16;' $@

clean:
	${MAKE} -C lib clean
	${MAKE} -C init clean
	${MAKE} -C arch/riscv clean
	$(shell test -f vmlinux && rm vmlinux)
	$(shell test -f vmlinux.asm && rm vmlinux.asm)
	$(shell test -f System.map && rm System.map)
	$(shell rm -rf boot)
	$(shell rm -rf build)
	@echo -e '\n'Clean Finished