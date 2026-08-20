# VerityOS 💾

**A tiny 16-bit operating system with a surprisingly large personality.**

VerityOS is a hobby operating system written almost entirely in **16-bit x86 Assembly** and built from scratch to boot through the BIOS.

What started as a boot sector displaying:

> Welcome to VerityOS 0.1!

has grown into a tiny operating system with its own kernel, text-mode desktop, built-in AI-style assistant, text editor, PC Speaker sound, and game.

## Current Version

**VerityOS 0.3**

VerityOS is still an experimental hobby operating system and is actively being developed.

## What's New in 0.3?

VerityOS 0.3 introduces:

* 📝 **VerityEdit 1.1**
* 🤖 **Verity AI 1.2**
* 🎮 **VerityCraft 1.2**
* 🖥️ Updated VerityOS desktop

## 🖥️ VerityOS Desktop

VerityOS boots into a text-mode desktop that acts as the main launcher for the operating system.

Current applications and options:

```text
[A] Verity AI
[E] VerityEdit
[G] VerityCraft
[I] About
[R] Reboot
[Q] Shutdown
```

Everything runs in **16-bit x86 real mode** using BIOS services and direct hardware access where appropriate.

## 📝 VerityEdit 1.1

New in VerityOS 0.3!

**VerityEdit** is the first text editor built into VerityOS.

It allows you to type and edit a document directly inside the operating system.

Features include:

* Normal keyboard input
* Backspace
* Multiple lines
* RAM-based text buffer
* Clear document
* Demo document
* Built-in help
* ESC to return to VerityOS

Example:

```text
+------------------------------------------------------------------------------+
| VerityEdit 1.1                                             VerityOS 0.3      |
+------------------------------------------------------------------------------+
| File: UNTITLED.TXT                                                          |
+------------------------------------------------------------------------------+

Hello from VerityOS!
This text was typed inside VerityEdit.
_
```

### The Current Limitation That Are Not There

VerityEdit 1.1 stores documents in i dont know.

Well it does save when you reboot it so it works.

## 🤖 Verity AI 1.2

VerityOS includes its own built-in assistant called **Verity AI**.

Verity AI is not a machine-learning model. Its responses are currently hardcoded directly into VerityOS, but it provides a chat-style interface where the user can type messages and receive responses.

Verity AI 1.2 understands commands including:

```text
hello
hi
hey
help
who are you
verityos
veritycraft
verityedit
how are you
joke
version
exit
bye
```

Example:

```text
You: hello
Verity AI: Hello! Nice to meet you. :)
How can I help you today?

You: who are you
Verity AI: I am Verity AI 1.2, the built-in assistant for VerityOS.

You: joke
Verity AI: Why did the bootloader cross the disk?
To get to the other sector.
```

Yes.

The bootloader joke survived the update.

## 🎮 VerityCraft 1.2

**VerityCraft** is the built-in game included with VerityOS.

You control **Verity**, a smiling sphere, inside a text-mode game world.

### Controls

```text
W / Up Arrow       Move up
S / Down Arrow     Move down
A / Left Arrow     Move left
D / Right Arrow    Move right
ESC                Return to menu
```

### VerityCraft 1. Features
none

You can also manually bounce Verity around the walls like a DVD screensaver.

If you manage to get Verity into the right place:

```text
*** PERFECT CORNER HIT! ***
```
was in 0.2

## 🔊 PC Speaker Audio

VerityOS uses the classic PC Speaker for sound.

It currently provides sounds for things such as:

* VerityOS startup
* VerityCraft startup
* Wall bounces
* Collecting stars
* Corner hits
* Editor warnings

No giant audio framework required.

Just the PC Speaker.

## 💾 Disk Layout

VerityOS currently uses a 1.44 MB floppy disk image.

The current layout is:

```text
Sector 1        Bootloader
Sectors 2-17    VerityOS kernel
Sectors 18-25   VerityCraft
Sector 26+      Available for future expansion
```

Keeping these regions separate is important.

Very important.

## 👽 The Alien Language Incident

During development of VerityOS 0.1, Verity AI suddenly started responding with seemingly random symbols.

At first, it appeared that the string-handling code or memory segments were broken.

They weren't.

The actual disk image looked roughly like this:

```text
Bootloader
Kernel
     ↓
     ↓
VerityCraft
     ↑
     ↑
OVERLAP
```

VerityCraft had accidentally been written over the second half of the VerityOS kernel.

Verity AI was therefore attempting to print pieces of VerityCraft machine code as text.

The disk layout was corrected.

Verity AI learned English again.

VerityOS development now has one extremely important rule:

> **NO OVERLAPPING SECTORS.**

## 🛠️ Building VerityOS

VerityOS uses **NASM** to assemble its source code.

Make the build script executable:

```bash
chmod +x build.sh
```

Then build:

```bash
./build.sh
```

A successful build produces a bootable floppy image:

```text
verityos.img
```

The image size should be:

```text
1474560 bytes
```

or exactly **1.44 MB**.

## 🚀 Running VerityOS

VerityOS has primarily been developed and tested using **DOSBox-X**.

Boot `verityos.img` as a floppy disk image to start the operating system.

The basic architecture is:

```text
BIOS
  |
  v
VerityOS Bootloader
  |
  v
VerityOS Kernel
  |
  +----> Verity AI 1.1
  |
  +----> VerityEdit 1.0
  |
  +----> VerityCraft 1.1
```

## 📂 Project Structure

```text
VerityOS/
├── boot.asm
├── kernel.asm
├── game.asm
├── build.sh
├── LICENSE
└── README.md
```

Generated builds may also include:

```text
boot.bin
kernel.bin
game.bin
verityos.img
```

## 🧠 What VerityOS Is For

VerityOS is an experimental hobby project built for learning and having fun with low-level programming.

Development involves experimenting with:

* x86 Assembly
* BIOS interrupts
* Boot sectors
* Real-mode programming
* Memory segments
* Disk sectors
* Keyboard input
* Text-mode interfaces
* PC Speaker programming
* Operating-system design
* Game programming
* Text editing
* Extremely questionable bootloader jokes

VerityOS is not intended to compete with Windows, macOS, or Linux.

Especially not yet.

## 📜 License

VerityOS is distributed under the **VerityOS Safe Use License v1.0**.

The source may be studied, compiled, experimented with, and modified according to the terms of that license.

Malicious and unauthorized uses prohibited by the license are not permitted.

See `LICENSE` for the complete terms.

## ⚠️ Development Status

🚧 **VerityOS is under active development.**

Current release:

**VerityOS 0.2**

Current built-in software:
```text
Verity AI       1.1
VerityEdit      1.0
VerityCraft     1.1
```

Expect bugs.

Expect experiments.

But hopefully don't expect any more alien language.

---

# VerityOS 0.3

**New editor. Smarter Verity. Bigger game. Same tiny computer.**

*Built one sector at a time.* 💾
