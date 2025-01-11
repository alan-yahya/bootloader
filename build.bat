@echo off
echo Building bootloader...

:: Assemble the bootloader
nasm -f bin bootloader.asm -o bootloader.bin

if %ERRORLEVEL% NEQ 0 (
    echo Failed to assemble bootloader!
    pause
    exit /b 1
)

echo Build successful!
echo Running bootloader in QEMU...

:: Run the bootloader in QEMU
qemu-system-x86_64 -drive format=raw,file=bootloader.bin

if %ERRORLEVEL% NEQ 0 (
    echo Failed to run bootloader!
    pause
    exit /b 1
)

pause 