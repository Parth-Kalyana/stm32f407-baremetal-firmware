Design and Development of a Bare-Metal Firmware Framework for STM32F407 Using CMSIS

FIRST FIRMWARE

main.c
   ↓
main.o
   +
startup_stm32f407xx.s
   ↓
startup.o
   +
system_stm32f4xx.c
   ↓
system_stm32f4xx.o
   +
stm32f407.ld
   ↓
LINKER
   ↓
firmware.elf        