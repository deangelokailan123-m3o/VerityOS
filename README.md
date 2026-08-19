# VerityOS

**A tiny 16-bit operating system with a surprisingly large personality.**

VerityOS is a hobby operating system written in **16-bit x86 Assembly** and built from scratch to boot through the BIOS.

What started as a boot sector displaying:

> Welcome to VerityOS 0.1!

has grown into a tiny operating system with its own kernel, text-mode interface, built-in assistant, sound, and game.

## Current Version

**VerityOS 0.1**

VerityOS will remain version **0.1** while its current features are being developed and expanded.

## Features

VerityOS currently includes:

* Custom BIOS bootloader
* 16-bit x86 Assembly kernel
* PC Speaker startup sound
* ASCII/text-mode graphical interface
* Keyboard controls
* Verity AI
* VerityCraft 1.0
* VerityCraft game menu
* WASD movement
* Arrow-key movement
* Reboot option
* Bootable 1.44 MB floppy disk image

## Verity AI

VerityOS includes its own built-in assistant called **Verity AI**.

Verity AI currently uses hardcoded responses rather than a machine-learning model, but provides an interactive chat-style interface directly inside VerityOS.

Example:

```text
You: hello
Verity AI: Hello! Nice to meet you. :)

You: who are you
Verity AI: I am Verity AI, the assistant built into VerityOS.

You: joke
Verity AI: Why did the bootloader cross the disk?
To get to the other sector.
```

Yes, Verity AI tells bootloader jokes.

## VerityCraft

**VerityCraft 1.0** is a game included with VerityOS.

The player controls **Verity**, a smiling sphere, inside an ASCII game world.

Controls:

```text
W / Up Arrow       Move up
S / Down Arrow     Move down
A / Left Arrow     Move left
D / Right Arrow    Move right
ESC                Return to menu
```

You can also manually bounce Verity around the world like a DVD screensaver.

## Project Structure

```text
VerityOS/
├── boot.asm       # BIOS bootloader
├── kernel.asm     # VerityOS kernel
├── game.asm       # VerityCraft
├── build.sh       # Build script
├── LICENSE
└── README.md
```

Generated builds may also contain:

```text
boot.bin
kernel.bin
game.bin
verityos.img
```

## Disk Layout

The current VerityOS floppy image uses:

```text
Sector 1        Bootloader
Sectors 2-17    VerityOS kernel
Sectors 18-25   VerityCraft
```

The remaining floppy space is available for future VerityOS features.

## Building VerityOS

VerityOS currently uses **NASM** to assemble its source code.

Make the build script executable:

```bash
chmod +x build.sh
```

Then build VerityOS:

```bash
./build.sh
```

A successful build creates:

```text
boot.bin       512 bytes
kernel.bin     8192 bytes
game.bin       4096 bytes
verityos.img   1474560 bytes
```

`verityos.img` is the bootable VerityOS floppy image.

## Running VerityOS

VerityOS is currently tested using **DOSBox-X**.

Boot `verityos.img` as a floppy disk image to start VerityOS.

The boot sequence is roughly:

```text
BIOS
  |
  v
VerityOS Bootloader
  |
  v
VerityOS Kernel
  |
  +----> Verity AI
  |
  +----> VerityCraft 1.0
```

## Development

VerityOS is an experimental hobby operating system.

The project is intentionally small and is being developed as a way to experiment with:

* x86 Assembly
* BIOS interrupts
* bootloaders
* memory
* disk sectors
* keyboard input
* PC Speaker audio
* operating-system development
* game programming

Expect bugs.

Sometimes those bugs may even cause Verity AI to speak alien.

## A Historic VerityOS Bug

During development, Verity AI once responded with seemingly random symbols instead of English.

The cause turned out to be the disk image layout.

VerityCraft was accidentally being written over part of the VerityOS kernel, meaning Verity AI was attempting to interpret pieces of VerityCraft machine code as its response text.

The disk layout was corrected and Verity AI learned English again.

## License

VerityOS is distributed under the **VerityOS Safe Use License v1.0**.

The source may be studied, compiled, experimented with, and modified under the terms of that license.

Malicious or unauthorized uses prohibited by the license are not permitted.

See `LICENSE` for the complete terms.

## Status

🚧 **VerityOS is under active development.**

Current release:

**VerityOS 0.1**

Built one sector at a time. 💾
