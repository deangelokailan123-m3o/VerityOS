; ============================================================
; VerityOS 0.1 Kernel
;
; Features:
; - Fake GUI desktop
; - PC Speaker startup sound
; - Verity AI hardcoded chat assistant
; - VerityCraft 1.0 launcher
;
; Kernel is loaded at 1000:0000
; ============================================================

bits 16
org 0x0000

GAME_SEGMENT equ 0x2000
INPUT_MAX    equ 63


; ============================================================
; ENTRY
; ============================================================

start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    mov [boot_drive], dl

    cli
    mov ax, 0x3000
    mov ss, ax
    mov sp, 0xFFFE
    sti

    call startup_sound

    jmp desktop


; ============================================================
; RESTORE KERNEL SEGMENTS
; ============================================================

restore_kernel_segments:
    push cs
    pop ds

    push cs
    pop es

    ret


; ============================================================
; DESKTOP
; ============================================================

desktop:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, desktop_gui
    call print_string


desktop_loop:
    xor ah, ah
    int 0x16

    cmp al, 'y'
    je load_game

    cmp al, 'Y'
    je load_game

    cmp al, 'n'
    je os_home

    cmp al, 'N'
    je os_home

    cmp al, 'a'
    je verity_ai

    cmp al, 'A'
    je verity_ai

    cmp al, 'r'
    je reboot

    cmp al, 'R'
    je reboot

    jmp desktop_loop


; ============================================================
; OS HOME
; ============================================================

os_home:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, home_gui
    call print_string


home_loop:
    xor ah, ah
    int 0x16

    cmp al, 'p'
    je load_game

    cmp al, 'P'
    je load_game

    cmp al, 'a'
    je verity_ai

    cmp al, 'A'
    je verity_ai

    cmp al, 'd'
    je desktop

    cmp al, 'D'
    je desktop

    cmp al, 'r'
    je reboot

    cmp al, 'R'
    je reboot

    jmp home_loop


; ============================================================
; VERITY AI
; ============================================================

verity_ai:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, ai_header
    call print_string

    mov si, ai_welcome
    call print_string


ai_chat_loop:
    call restore_kernel_segments

    mov si, user_prompt
    call print_string

    mov di, input_buffer
    call read_line

    cmp byte [input_buffer], 0
    je ai_chat_loop

    mov si, ai_prompt
    call print_string


    ; hello
    mov si, input_buffer
    mov di, command_hello
    call strings_equal
    cmp al, 1
    je ai_reply_hello


    ; hi
    mov si, input_buffer
    mov di, command_hi
    call strings_equal
    cmp al, 1
    je ai_reply_hello


    ; help
    mov si, input_buffer
    mov di, command_help
    call strings_equal
    cmp al, 1
    je ai_reply_help


    ; who are you
    mov si, input_buffer
    mov di, command_who
    call strings_equal
    cmp al, 1
    je ai_reply_who


    ; veritycraft
    mov si, input_buffer
    mov di, command_veritycraft
    call strings_equal
    cmp al, 1
    je ai_reply_veritycraft


    ; verityos
    mov si, input_buffer
    mov di, command_verityos
    call strings_equal
    cmp al, 1
    je ai_reply_verityos


    ; how are you
    mov si, input_buffer
    mov di, command_how
    call strings_equal
    cmp al, 1
    je ai_reply_how


    ; joke
    mov si, input_buffer
    mov di, command_joke
    call strings_equal
    cmp al, 1
    je ai_reply_joke


    ; exit
    mov si, input_buffer
    mov di, command_exit
    call strings_equal
    cmp al, 1
    je desktop


    ; bye
    mov si, input_buffer
    mov di, command_bye
    call strings_equal
    cmp al, 1
    je desktop


    ; Unknown
    mov si, reply_unknown
    call print_string

    jmp ai_chat_loop


; ============================================================
; AI RESPONSES
; ============================================================

ai_reply_hello:
    call restore_kernel_segments

    mov si, reply_hello
    call print_string

    jmp ai_chat_loop


ai_reply_help:
    call restore_kernel_segments

    mov si, reply_help
    call print_string

    jmp ai_chat_loop


ai_reply_who:
    call restore_kernel_segments

    mov si, reply_who
    call print_string

    jmp ai_chat_loop


ai_reply_veritycraft:
    call restore_kernel_segments

    mov si, reply_veritycraft
    call print_string

    jmp ai_chat_loop


ai_reply_verityos:
    call restore_kernel_segments

    mov si, reply_verityos
    call print_string

    jmp ai_chat_loop


ai_reply_how:
    call restore_kernel_segments

    mov si, reply_how
    call print_string

    jmp ai_chat_loop


ai_reply_joke:
    call restore_kernel_segments

    mov si, reply_joke
    call print_string

    jmp ai_chat_loop


; ============================================================
; READ LINE
; ============================================================

read_line:
    push ax
    push bx
    push cx
    push dx
    push di

    xor cx, cx


.read_key:
    xor ah, ah
    int 0x16

    cmp al, 27
    je .escape

    cmp al, 13
    je .enter

    cmp al, 8
    je .backspace

    cmp al, 0
    je .read_key

    cmp cx, INPUT_MAX
    jae .read_key


    ; uppercase -> lowercase
    cmp al, 'A'
    jb .store

    cmp al, 'Z'
    ja .store

    add al, 32


.store:
    mov [di], al
    inc di
    inc cx

    call print_char

    jmp .read_key


.backspace:
    cmp cx, 0
    je .read_key

    dec di
    dec cx

    mov al, 8
    call print_char

    mov al, ' '
    call print_char

    mov al, 8
    call print_char

    jmp .read_key


.enter:
    mov byte [di], 0

    mov al, 13
    call print_char

    mov al, 10
    call print_char

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    ret


.escape:
    mov byte [di], 0

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    jmp desktop


; ============================================================
; STRING COMPARE
; ============================================================

strings_equal:
    push bx
    push si
    push di

.compare:
    mov al, [si]
    mov bl, [di]

    cmp al, bl
    jne .not_equal

    cmp al, 0
    je .equal

    inc si
    inc di

    jmp .compare


.equal:
    mov al, 1

    pop di
    pop si
    pop bx

    ret


.not_equal:
    xor al, al

    pop di
    pop si
    pop bx

    ret


; ============================================================
; LOAD VERITYCRAFT
; ============================================================

load_game:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, loading_text
    call print_string


    ; Reset disk
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    jc game_error


    ; Load VerityCraft at 2000:0000
    mov ax, GAME_SEGMENT
    mov es, ax
    xor bx, bx


    ; First game sector:
    ; Cylinder 0
    ; Head 0
    ; Sector 18
    mov ah, 0x02
    mov al, 1

    mov ch, 0
    mov cl, 18
    mov dh, 0
    mov dl, [boot_drive]

    int 0x13

    jc game_error


    ; Remaining 7 sectors:
    ; Cylinder 0
    ; Head 1
    ; Sector 1
    mov bx, 0x0200

    mov ah, 0x02
    mov al, 7

    mov ch, 0
    mov cl, 1
    mov dh, 1
    mov dl, [boot_drive]

    int 0x13

    jc game_error


    mov dl, [boot_drive]

    jmp GAME_SEGMENT:0x0000


game_error:
    call restore_kernel_segments

    mov si, game_error_text
    call print_string

    xor ah, ah
    int 0x16

    jmp desktop


; ============================================================
; REBOOT
; ============================================================

reboot:
    jmp 0xFFFF:0x0000


; ============================================================
; PRINT CHARACTER
; ============================================================

print_char:
    push ax
    push bx

    mov ah, 0x0E
    mov bh, 0
    mov bl, 7

    int 0x10

    pop bx
    pop ax

    ret


; ============================================================
; PRINT STRING
;
; IMPORTANT:
; We now read directly from CS:SI.
; That means even if DS gets screwed up somewhere,
; Verity AI's strings still come from the kernel itself.
; ============================================================

print_string:
.next:
    mov al, [cs:si]
    inc si

    test al, al
    jz .done

    push si
    push bx

    mov ah, 0x0E
    mov bh, 0
    mov bl, 7

    int 0x10

    pop bx
    pop si

    jmp .next


.done:
    ret


; ============================================================
; STARTUP SOUND
; ============================================================

startup_sound:
    mov al, 0xB6
    out 0x43, al

    mov ax, 1808

    out 0x42, al

    mov al, ah
    out 0x42, al


    in al, 0x61
    or al, 00000011b
    out 0x61, al


    mov cx, 12


.delay_outer:
    push cx

    mov cx, 0xFFFF


.delay_inner:
    loop .delay_inner

    pop cx
    loop .delay_outer


    in al, 0x61
    and al, 11111100b
    out 0x61, al

    ret


; ============================================================
; DATA
; ============================================================

boot_drive db 0


; ============================================================
; DESKTOP GUI
; ============================================================

desktop_gui:
    db "+------------------------------------------------------------------------------+", 13, 10
    db "| VerityOS 0.1                                                     SYSTEM READY |", 13, 10
    db "+------------------------------------------------------------------------------+", 13, 10
    db "|                                                                              |", 13, 10
    db "|           +------------------------------------------------------+           |", 13, 10
    db "|           |                                                      |           |", 13, 10
    db "|           |             Welcome to VerityOS 0.1!                 |           |", 13, 10
    db "|           |                                                      |           |", 13, 10
    db "|           |        Do you want to play VerityCraft?              |           |", 13, 10
    db "|           |                                                      |           |", 13, 10
    db "|           |          [Y] YES          [N] NO                     |           |", 13, 10
    db "|           |                                                      |           |", 13, 10
    db "|           |              [A] VERITY AI                           |           |", 13, 10
    db "|           |                                                      |           |", 13, 10
    db "|           +------------------------------------------------------+           |", 13, 10
    db "|                                                                              |", 13, 10
    db "+------------------------------------------------------------------------------+", 13, 10
    db "| [A] Verity AI     [Y] VerityCraft      [R] Reboot        VerityOS Ready     |", 13, 10
    db "+------------------------------------------------------------------------------+", 13, 10
    db 0


; ============================================================
; HOME GUI
; ============================================================

home_gui:
    db "+------------------------------------------------------------------------------+", 13, 10
    db "| VerityOS 0.1                                                        HOME     |", 13, 10
    db "+------------------------------------------------------------------------------+", 13, 10
    db "|                                                                              |", 13, 10
    db "|                           Welcome to VerityOS                                |", 13, 10
    db "|                                                                              |", 13, 10
    db "|                    [P] Launch VerityCraft                                    |", 13, 10
    db "|                                                                              |", 13, 10
    db "|                    [A] Open Verity AI                                        |", 13, 10
    db "|                                                                              |", 13, 10
    db "|                    [D] Back to Desktop                                       |", 13, 10
    db "|                                                                              |", 13, 10
    db "|                    [R] Reboot                                                |", 13, 10
    db "|                                                                              |", 13, 10
    db "+------------------------------------------------------------------------------+", 13, 10
    db 0


; ============================================================
; VERITY AI
; ============================================================

ai_header:
    db "+------------------------------------------------------------------------------+", 13, 10
    db "| Verity AI                                              VerityOS Assistant    |", 13, 10
    db "+------------------------------------------------------------------------------+", 13, 10
    db 0


ai_welcome:
    db 13, 10
    db "Verity AI:", 13, 10
   	db "Copyright (c) 2026 kaiman18 Studios", 13, 10
   	db "Welcome to Verity AI 1.0!", 13, 10
    db "My brain is currently made of hardcoded responses. :)", 13, 10
    db 13, 10
    db "Try: hello, help, who are you, veritycraft, verityos,", 13, 10
    db "     how are you, joke, exit", 13, 10
    db 13, 10
    db "Press ESC while typing to return to the desktop.", 13, 10
    db 13, 10
    db 0


user_prompt:
    db "You: ", 0


ai_prompt:
    db "Verity AI: ", 0


; ============================================================
; COMMANDS
; ============================================================

command_hello:
    db "hello", 0

command_hi:
    db "hi", 0

command_help:
    db "help", 0

command_who:
    db "who are you", 0

command_veritycraft:
    db "veritycraft", 0

command_verityos:
    db "verityos", 0

command_how:
    db "how are you", 0

command_joke:
    db "joke", 0

command_exit:
    db "exit", 0

command_bye:
    db "bye", 0


; ============================================================
; RESPONSES
; ============================================================

reply_hello:
    db "HELLO TEST WORKS!", 13, 10
    db "Nice to meet you. :)", 13, 10
    db 13, 10
    db 0


reply_help:
    db "I understand:", 13, 10
    db "hello, hi, help, who are you, veritycraft,", 13, 10
    db "verityos, how are you, joke, exit, bye", 13, 10
    db 13, 10
    db 0


reply_who:
    db "I am Verity AI, the assistant built into VerityOS.", 13, 10
    db "My responses are hardcoded for now.", 13, 10
    db 13, 10
    db 0


reply_veritycraft:
    db "VerityCraft 1.0 is included with VerityOS.", 13, 10
    db "Move Verity with WASD or the arrow keys.", 13, 10
    db 13, 10
    db 0


reply_verityos:
    db "You are running VerityOS 0.1.", 13, 10
    db "It includes VerityCraft and Verity AI.", 13, 10
    db 13, 10
    db 0


reply_how:
    db "I am doing great! My bytes seem to be behaving.", 13, 10
    db 13, 10
    db 0


reply_joke:
    db "Why did the bootloader cross the disk?", 13, 10
    db "To get to the other sector.", 13, 10
    db 13, 10
    db 0


reply_unknown:
    db "I do not understand that yet.", 13, 10
    db "Type help to see what I know.", 13, 10
    db 13, 10
    db 0


; ============================================================
; GAME TEXT
; ============================================================

loading_text:
    db "Loading VerityCraft 1.0...", 13, 10
    db 0


game_error_text:
    db 13, 10
    db "ERROR: Could not load VerityCraft!", 13, 10
    db "Press any key to return.", 13, 10
    db 0


; ============================================================
; INPUT BUFFER
; ============================================================

input_buffer:
    times 64 db 0


; ============================================================
; 16 SECTOR KERNEL
; ============================================================

times 8192 - ($ - $$) db 0
