# System Monitor Bootloader

A 16-bit real mode bootloader which displays system information including CPU, graphics, memory, and time. Designed for x86 architecture and Windows operating system.

## Features

- CPU Information
- Graphics Information
  - Video Mode
  - Adapter Type (VGA/EGA/CGA/MDA)
- Memory Size
- Current Time

## System Requirements

- Windows OS (Windows 10 recommended)
- x86/x86_64 processor architecture
- NASM (Netwide Assembler)
- QEMU (for testing)

## Installation

1. Install NASM:
   ```powershell
   choco install nasm
   ```
   Or download from [NASM website](https://www.nasm.us/)

2. Install QEMU:
   ```powershell
   choco install qemu
   ```
   Or download from [QEMU website](https://www.qemu.org/download/)

## Building and Running

1. Build the bootloader:
   ```bash
   build.bat
   ```

2. The script will:
   - Assemble the bootloader using NASM
   - Create a binary file (bootloader.bin)
   - Launch QEMU to run the bootloader

## File Structure

- `bootloader.asm` - Main bootloader source code
- `build.bat` - Build and run script
- `.gitignore` - Git ignore file
- `README.md` - This documentation

## Technical Details

- x86 16-bit Real Mode
- 512-byte boot sector
- BIOS interrupts for system information
- Text mode display (80x25)
- Color-coded information display
- Windows-specific build tools
- DOS interrupts for system time

## License

Available under MIT license.