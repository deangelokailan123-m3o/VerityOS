; ============================================================
; VerityOS 0.1 Bootloader
;
; Loads the 16-sector VerityOS kernel in TWO safe chunks:
;
;   Sectors 2-9   -> 1000:0000
;   Sectors 10-17 -> 1000:1000
;
; Then jumps to 1000:0000
; ============================================================

bits 16
org 0x7C00

KERNEL_SEGMENT equ 0x1000

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    ; BIOS boot drive is passed in DL
    mov [boot_drive], dl


; ============================================================
; RESET DISK
; ============================================================

reset_disk:
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    jc disk_error


; ============================================================
; LOAD FIRST HALF OF KERNEL
;
; Disk sectors 2-9
; 8 sectors = 4096 bytes
;
; Destination:
; 1000:0000
; ============================================================

load_kernel_part1:
    mov ax, KERNEL_SEGMENT
    mov es, ax

    xor bx, bx

    mov ah, 0x02
    mov al, 8

    mov ch, 0
    mov cl, 2
    mov dh, 0

    mov dl, [boot_drive]

    int 0x13

    jc disk_error


; ============================================================
; LOAD SECOND HALF OF KERNEL
;
; Disk sectors 10-17
; 8 sectors = 4096 bytes
;
; Destination:
; 1000:1000
; ============================================================

load_kernel_part2:
    mov ax, KERNEL_SEGMENT
    mov es, ax

    mov bx, 0x1000

    mov ah, 0x02
    mov al, 8

    mov ch, 0
    mov cl, 10
    mov dh, 0

    mov dl, [boot_drive]

    int 0x13

    jc disk_error


; ============================================================
; START VERITYOS
; ============================================================

start_kernel:
    mov dl, [boot_drive]

    jmp KERNEL_SEGMENT:0x0000


; ============================================================
; DISK ERROR
; ============================================================

disk_error:
    xor ax, ax
    mov ds, ax

    mov si, disk_error_message

    call print_string


hang:
    cli
    hlt
    jmp hang


; ============================================================
; PRINT STRING
;
; DS:SI = null-terminated string
; ============================================================

print_string:
.next:
    lodsb

    test al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07

    int 0x10

    jmp .next

.done:
    ret


; ============================================================
; DATA
; ============================================================

boot_drive:
    db 0


disk_error_message:
    db 13, 10
    db "BOOT ERROR: Could not load VerityOS kernel.", 13, 10
    db 0


; ============================================================
; BOOT SECTOR PADDING
; ============================================================

times 510 - ($ - $$) db 0

dw 0xAA55
