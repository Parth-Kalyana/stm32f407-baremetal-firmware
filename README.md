# STM32F407 Bare-Metal Firmware (CMSIS)

Personal project. Bare-metal firmware for the STM32F407G-DISC1, built without HAL —
straight from startup code + linker script + CMSIS, so I actually understand the
boot pipeline instead of hiding behind a framework.

This milestone = confirm the full toolchain pipeline works end to end.

---

## Hardware

- Board: STM32F407G-DISC1
- MCU: STM32F407VGT6 (ARM Cortex-M4)
- Flash: 1 MB
- SRAM used: 128 KB
- Debugger: onboard ST-LINK/V2 (no external programmer needed)

---

## Project Structure

```
stm32f407-baremetal-firmware/
├── cmsis/
│   ├── core/          # CMSIS core headers
│   └── device/        # device-specific headers
├── drivers/           # peripheral drivers (empty for now)
├── examples/
├── lib/
├── src/
│   └── main.c
├── startup/
│   ├── startup_stm32f407xx.s   # vector table + Reset_Handler
│   └── stm32f407.ld            # linker script
├── build/              # generated, not committed
├── Makefile
└── README.md
```

---

## How It All Fits Together (mental model, so I don't forget)

**Build pipeline:**
```
main.c ─────────────┐
startup_stm32f407xx.s ── main.o + startup.o
system_stm32f4xx.c ──────────────────┐
stm32f407.ld (linker script) ────────┴──> LINKER ──> firmware.elf
```

**MCU boot sequence (what happens on reset):**
```
MCU Reset → Vector Table → Reset_Handler → SystemInit()
  → Initialize .data → Clear .bss → main()
```

**End-to-end pipeline this milestone verifies:**
```
Source Code → Compiler → Object Files → Linker → ELF
  → OpenOCD → ST-LINK → STM32 Flash → CPU Execution
```

**Memory map (from `stm32f407.ld`):**

| Region | Start        | Length |
|--------|--------------|--------|
| FLASH  | 0x08000000   | 1024K  |
| RAM    | 0x20000000   | 128K   |

Sections: `.isr_vector` → FLASH, `.text` → FLASH, `.rodata` → FLASH, `.data` → RAM, `.bss` → RAM.
Linker also exports `_estack`, `_sidata`, `_sdata`, `_edata`, `_sbss`, `_ebss` — these are what
`Reset_Handler` uses to copy `.data` and zero `.bss` before calling `main()`.

---

## Setup (Ubuntu 22.04)

```bash
sudo apt update
sudo apt install build-essential \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    gdb-multiarch \
    openocd \
    telnet
```

Verify:
```bash
arm-none-eabi-gcc --version
make --version
openocd --version
```

---

## Build

From project root:
```bash
make
```

Produces `build/firmware.elf` (+ `.map`, `.o` files).

Convert to raw binary if needed:
```bash
arm-none-eabi-objcopy -O binary build/firmware.elf build/firmware.bin
```

---

## Inspect (useful when debugging weird boot behavior)

```bash
arm-none-eabi-size build/firmware.elf              # memory usage
arm-none-eabi-readelf -h build/firmware.elf         # ELF header
arm-none-eabi-readelf -S build/firmware.elf         # sections
arm-none-eabi-nm build/firmware.elf                 # symbol table
arm-none-eabi-nm build/firmware.elf | grep main      # find main()'s address
```

---

## Flash It

**Terminal 1** — start OpenOCD (keep running):
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```
Should show something like `Listening on port 3333 for gdb connections`.

**Terminal 2** — connect via telnet:
```bash
telnet localhost 4444
```

At the `>` prompt:
```
reset halt              # halt the MCU
program build/firmware.elf verify   # flash + verify
reset run                # run the firmware
```

`** Verified OK **` = flash contents match the ELF, pipeline confirmed working.

**Exit:**
- Telnet: `Ctrl + ]` then `quit`
- OpenOCD: `Ctrl + C` in its terminal

---

## Current Status

`main.c` is currently just:
```c
int main(void)
{
    while (1) { }
}
```
No visible output yet — this milestone only proves the toolchain → flash → execution
pipeline works. Next step: actual peripheral drivers, then composite video generation.

---
