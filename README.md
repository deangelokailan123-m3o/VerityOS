# 💾 VerityOS 0.3

**VerityOS 0.3** is a tiny experimental 16-bit hobby operating system written primarily in x86 Assembly.

It boots from a floppy disk image, runs its own text-based environment, includes built-in programs and a game, and — starting with VerityOS 0.3 — can actually remember files after a reboot.

> **VerityOS remembers.**

---

## ✨ What's New in VerityOS 0.3?

The biggest addition to VerityOS 0.3 is:

# 💾 VerityFS 1.0

VerityFS is VerityOS's first persistent filesystem.

Previous versions could keep information in memory while VerityOS was running, but that information disappeared after rebooting.

Not anymore.

With VerityFS 1.0, VerityOS can write file data to the disk image and load it again later.

You can:

1. Write something in VerityEdit.
2. Save it.
3. Shut down VerityOS.
4. Close the emulator.
5. Start VerityOS again.
6. Open your file.

**It's still there.**

Yes, we tested it.

Yes, it worked.

First try. :)

---

## 📝 VerityEdit

VerityEdit is the built-in text editor for VerityOS.

With VerityFS, documents are no longer limited to temporary memory.

You can now write something, save it to disk, reboot, and return to it later.

Technically, this means you could write your school essay in VerityOS.

Whether you *should* trust your school essay to an experimental homemade 16-bit operating system is another question.

---

## 📁 VerityFiles 1.0

VerityFiles provides a simple way to view files stored by VerityFS.

VerityOS 0.3 is the first VerityOS release where files can persist between sessions.

---

## 🤖 Verity AI 1.2

Verity AI returns in version **1.2**.

Verity AI is a small built-in simulated AI/chat program using predefined responses.

It is not an internet-connected large language model.

It's just Verity being Verity.

And yes, Verity AI speaks English now.

We don't talk about the Alien Language Incident.

---

## 🎮 VerityCraft 1.2

VerityCraft was introduced alongside Verity AI and continues to share its version progression.

VerityCraft 1.2 features **Verity**, the friendly smiling sphere.

Move Verity around using:

- WASD
- Arrow keys

VerityCraft is inspired by sandbox-game ideas while being its own tiny text-mode game built for VerityOS.

---

## 🟢 Who Is Verity?

Verity is a friendly **smiling sphere** and the mascot/character of VerityOS.

Not a cube.

Not an alien.

A smiling sphere. :)

---

## 💿 Disk Layout

VerityOS uses a carefully planned floppy-disk layout.

The bootloader, kernel, VerityCraft, and VerityFS storage occupy separate areas of the disk.

This is extremely important because:

> **NO OVERLAPPING SECTORS.**

We learned that lesson already.

---

## 🛠️ Building VerityOS

### Requirements

You will need:

- NASM
- Bash
- `dd`
- A compatible emulator or virtual machine capable of booting the generated floppy image

Make the build script executable:

```bash
chmod +x build.sh
