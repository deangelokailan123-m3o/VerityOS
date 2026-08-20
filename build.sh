#!/bin/bash
set -e

echo "=============================="
echo "     Building VerityOS 0.3"
echo "=============================="
echo

echo "[1/5] Assembling bootloader..."
nasm -f bin boot.asm -o boot.bin

echo "[2/5] Assembling kernel + VerityFS..."
nasm -f bin kernel.asm -o kernel.bin

echo "[3/5] Assembling VerityCraft 1.2..."
nasm -f bin game.asm -o game.bin

BOOT_SIZE=$(wc -c < boot.bin | tr -d ' ')
KERNEL_SIZE=$(wc -c < kernel.bin | tr -d ' ')
GAME_SIZE=$(wc -c < game.bin | tr -d ' ')

[ "$BOOT_SIZE" -eq 512 ] || { echo "ERROR: boot.bin is $BOOT_SIZE bytes; expected 512."; exit 1; }
[ "$KERNEL_SIZE" -eq 8192 ] || { echo "ERROR: kernel.bin is $KERNEL_SIZE bytes; expected 8192."; exit 1; }
[ "$GAME_SIZE" -eq 4096 ] || { echo "ERROR: game.bin is $GAME_SIZE bytes; expected 4096."; exit 1; }

echo "[4/5] Creating 1.44 MB floppy image..."
dd if=/dev/zero of=verityos.img bs=512 count=2880 2>/dev/null

# Sector 1: bootloader
dd if=boot.bin of=verityos.img bs=512 seek=0 conv=notrunc 2>/dev/null
# Sectors 2-17: kernel (16 sectors)
dd if=kernel.bin of=verityos.img bs=512 seek=1 conv=notrunc 2>/dev/null
# Sectors 18-25: VerityCraft (8 sectors)
dd if=game.bin of=verityos.img bs=512 seek=17 conv=notrunc 2>/dev/null
# Sector 64+ is deliberately left blank. VerityFS initializes it on first boot.

echo "[5/5] Checking build..."
IMAGE_SIZE=$(wc -c < verityos.img | tr -d ' ')
[ "$IMAGE_SIZE" -eq 1474560 ] || { echo "ERROR: bad image size: $IMAGE_SIZE"; exit 1; }

echo
echo "boot.bin     : $BOOT_SIZE bytes"
echo "kernel.bin   : $KERNEL_SIZE bytes"
echo "game.bin     : $GAME_SIZE bytes"
echo "verityos.img : $IMAGE_SIZE bytes"
echo
echo "=============================="
echo "    VERITYOS 0.3 COMPLETE"
echo "=============================="
echo " Sector 1       : Bootloader"
echo " Sectors 2-17   : Kernel + VerityFS code"
echo " Sectors 18-25  : VerityCraft 1.2"
echo " Sectors 26-63  : Reserved safety gap"
echo " Sector 64      : VerityFS directory"
echo " Sectors 65-66  : NOTES.TXT data"
echo " Sector 67+     : Free"
echo
echo "No overlapping sectors. :)"
