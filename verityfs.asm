; ============================================================
; VerityFS 1.0 - VerityOS 0.3
; Included by kernel.asm. 16-bit BIOS floppy I/O.
;
; LBA 63 (human sector 64): directory/signature
; LBA 64-65: NOTES.TXT data (1024 bytes max)
; ============================================================

VFS_DIR_LBA  equ 63
VFS_DATA_LBA equ 64
VFS_MAGIC    equ 0x31534656        ; "VFS1" little-endian

; Initialize filesystem if sector 64 has no VFS1 signature.
vfs_init:
    push ax
    push bx
    push es
    push cs
    pop es
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_read_sector
    jc .format
    cmp dword [vfs_sector_buffer], VFS_MAGIC
    je .done
.format:
    call vfs_format
.done:
    pop es
    pop bx
    pop ax
    ret

vfs_format:
    push ax
    push bx
    push cx
    push di
    push es
    push cs
    pop es
    mov di, vfs_sector_buffer
    xor ax, ax
    mov cx, 256
    rep stosw
    mov dword [vfs_sector_buffer], VFS_MAGIC
    mov byte [vfs_sector_buffer+4], 1       ; filesystem version
    mov byte [vfs_sector_buffer+5], 0       ; NOTES.TXT absent
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_write_sector
    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

; Save editor_buffer as NOTES.TXT. Maximum 1023 bytes.
vfs_save_notes:
    push ax
    push bx
    push cx
    push dx
    push es
    push cs
    pop es

    ; Write first 512 bytes.
    mov bx, editor_buffer
    mov ax, VFS_DATA_LBA
    call vfs_write_sector
    jc .error

    ; Write second 512 bytes.
    mov bx, editor_buffer+512
    mov ax, VFS_DATA_LBA+1
    call vfs_write_sector
    jc .error

    ; Read and update directory.
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_read_sector
    jc .error
    mov dword [vfs_sector_buffer], VFS_MAGIC
    mov byte [vfs_sector_buffer+5], 1
    mov ax, [editor_length]
    mov [vfs_sector_buffer+6], ax
    mov byte [vfs_sector_buffer+8], 'N'
    mov byte [vfs_sector_buffer+9], 'O'
    mov byte [vfs_sector_buffer+10], 'T'
    mov byte [vfs_sector_buffer+11], 'E'
    mov byte [vfs_sector_buffer+12], 'S'
    mov byte [vfs_sector_buffer+13], '.'
    mov byte [vfs_sector_buffer+14], 'T'
    mov byte [vfs_sector_buffer+15], 'X'
    mov byte [vfs_sector_buffer+16], 'T'
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_write_sector
    jc .error
    clc
    jmp .done
.error:
    stc
.done:
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Load NOTES.TXT into editor_buffer.
vfs_load_notes:
    push ax
    push bx
    push es
    push cs
    pop es
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_read_sector
    jc .error
    cmp dword [vfs_sector_buffer], VFS_MAGIC
    jne .error
    cmp byte [vfs_sector_buffer+5], 1
    jne .error
    mov ax, [vfs_sector_buffer+6]
    cmp ax, EDIT_BUFFER_SIZE-1
    jbe .size_ok
    mov ax, EDIT_BUFFER_SIZE-1
.size_ok:
    mov [editor_length], ax
    mov bx, editor_buffer
    mov ax, VFS_DATA_LBA
    call vfs_read_sector
    jc .error
    mov bx, editor_buffer+512
    mov ax, VFS_DATA_LBA+1
    call vfs_read_sector
    jc .error
    mov bx, [editor_length]
    mov byte [editor_buffer+bx], 0
    clc
    jmp .done
.error:
    stc
.done:
    pop es
    pop bx
    pop ax
    ret

vfs_notes_exists:
    push bx
    push es
    push cs
    pop es
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_read_sector
    jc .no
    cmp dword [vfs_sector_buffer], VFS_MAGIC
    jne .no
    cmp byte [vfs_sector_buffer+5], 1
    jne .no
    mov al, 1
    jmp .done
.no:
    xor al, al
.done:
    pop es
    pop bx
    ret

vfs_delete_notes:
    push ax
    push bx
    push es
    push cs
    pop es
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_read_sector
    jc .error
    mov byte [vfs_sector_buffer+5], 0
    mov word [vfs_sector_buffer+6], 0
    mov bx, vfs_sector_buffer
    mov ax, VFS_DIR_LBA
    call vfs_write_sector
    ret
.error:
    stc
    pop es
    pop bx
    pop ax
    ret

; AX=LBA, ES:BX=buffer. One sector.
vfs_read_sector:
    push ax
    push bx
    push cx
    push dx
    call vfs_lba_to_chs
    mov ah, 0x02
    mov al, 1
    mov dl, [boot_drive]
    int 0x13
    pop dx
    pop cx
    pop bx
    pop ax
    ret

vfs_write_sector:
    push ax
    push bx
    push cx
    push dx
    call vfs_lba_to_chs
    mov ah, 0x03
    mov al, 1
    mov dl, [boot_drive]
    int 0x13
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; AX=LBA -> CH=cylinder, DH=head, CL=sector (1..18)
vfs_lba_to_chs:
    push ax
    push bx
    xor dx, dx
    mov bx, 18
    div bx
    mov cl, dl
    inc cl
    xor dx, dx
    mov bx, 2
    div bx
    mov ch, al
    mov dh, dl
    pop bx
    pop ax
    ret

vfs_sector_buffer:
    times 512 db 0
