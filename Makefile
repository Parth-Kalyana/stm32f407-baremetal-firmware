TARGET = firmware

CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc

CFLAGS = -mcpu=cortex-m4 -mthumb
CFLAGS += -mfloat-abi=soft
CFLAGS += -DSTM32F407xx
CFLAGS += -ffreestanding
CFLAGS += -Wall -Wextra

CFLAGS += -Icmsis/core
CFLAGS += -Icmsis/device
CFLAGS += -Isrc

LDFLAGS = -Tstartup/stm32f407.ld
LDFLAGS += -nostdlib
LDFLAGS += -Wl,-Map=build/$(TARGET).map

SRC = src/main.c
SRC += cmsis/device/system_stm32f4xx.c
SYSTEM_SRC = cmsis/device/system_stm32f4xx.c
STARTUP = startup/startup_stm32f407xx.s

OBJ = build/main.o
OBJ += build/startup.o
OBJ += build/system_stm32f4xx.o

all: build/firmware.elf build/firmware.bin

build/$(TARGET).elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

build/main.o: src/main.c
	mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@

build/startup.o: startup/startup_stm32f407xx.s
	mkdir -p build
	$(AS) $(CFLAGS) -c $< -o $@

build/system_stm32f4xx.o: cmsis/device/system_stm32f4xx.c
	mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@

build/firmware.bin: build/firmware.elf
	arm-none-eabi-objcopy -O binary $< $@

clean:
	rm -rf build