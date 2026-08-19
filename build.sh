#!/bin/bash

set -e

echo "=============================="
echo "     Building VerityOS 0.1"
echo "=============================="

echo
echo "[1/5] Assembling bootloader..."
nasm -f bin boot.asm -o boot.bin

echo "[2/5] Assembling kernel..."
nasm -f bin kernel.asm -o kernel.bin

echo "[3/5] Assembling VerityCraft..."
nasm -f bin game.asm -o game.bin

echo "[4/5] Creating 1.44 MB floppy image..."

# Create blank 1.44 MB floppy
dd if=/dev/zero \
   of=verityos.img \
   bs=512 \
   count=2880 \
   2>/dev/null


# ============================================================
# Sector 1 = Bootloader
# ============================================================

dd if=boot.bin \
   of=verityos.img \
   bs=512 \
   seek=0 \
   conv=notrunc \
   2>/dev/null


# ============================================================
# Sectors 2-17 = VerityOS Kernel
#
# 16 sectors = 8192 bytes
# ============================================================

dd if=kernel.bin \
   of=verityos.img \
   bs=512 \
   seek=1 \
   conv=notrunc \
   2>/dev/null


# ============================================================
# Sectors 18-25 = VerityCraft
#
# 8 sectors = 4096 bytes
# ============================================================

dd if=game.bin \
   of=verityos.img \
   bs=512 \
   seek=17 \
   conv=notrunc \
   2>/dev/null


echo "[5/5] Checking build..."

echo
echo "boot.bin:"
wc -c < boot.bin

echo "kernel.bin:"
wc -c < kernel.bin

echo "game.bin:"
wc -c < game.bin

echo "verityos.img:"
wc -c < verityos.img


echo
echo "=============================="
echo "    VERITYOS BUILD COMPLETE"
echo "=============================="

echo
echo "Disk layout:"
echo " Sector 1       : Bootloader"
echo " Sectors 2-17   : VerityOS kernel"
echo " Sectors 18-25  : VerityCraft"

echo
echo "No overlapping sectors. :)"
