; ============================================================
; VerityOS 0.2 Kernel
; ============================================================
;
; VerityOS 0.2
;
; Built-in software:
;   Verity AI 1.1
;   VerityEdit 1.0
;   VerityCraft
;
; 16-bit x86 Real Mode
; NASM flat binary
;
; Kernel loaded at 1000:0000
;
; ============================================================

bits 16
org 0x0000

GAME_SEGMENT equ 0x2000

AI_INPUT_MAX equ 63
EDIT_BUFFER_SIZE equ 1024


; ============================================================
; ENTRY POINT
; ============================================================

start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Save BIOS boot drive
    mov [boot_drive], dl

    ; Stack
    cli

    mov ax, 0x3000
    mov ss, ax
    mov sp, 0xFFFE

    sti

    ; Startup sound
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
; VERITYOS 0.2 DESKTOP
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


    ; --------------------------------------------------------
    ; A = Verity AI
    ; --------------------------------------------------------

    cmp al, 'a'
    je verity_ai

    cmp al, 'A'
    je verity_ai


    ; --------------------------------------------------------
    ; E = VerityEdit
    ; --------------------------------------------------------

    cmp al, 'e'
    je verity_edit

    cmp al, 'E'
    je verity_edit


    ; --------------------------------------------------------
    ; G = VerityCraft
    ; --------------------------------------------------------

    cmp al, 'g'
    je load_game

    cmp al, 'G'
    je load_game


    ; --------------------------------------------------------
    ; I = About
    ; --------------------------------------------------------

    cmp al, 'i'
    je about_screen

    cmp al, 'I'
    je about_screen


    ; --------------------------------------------------------
    ; R = Reboot
    ; --------------------------------------------------------

    cmp al, 'r'
    je reboot

    cmp al, 'R'
    je reboot


    ; --------------------------------------------------------
    ; Q = Shutdown
    ; --------------------------------------------------------

    cmp al, 'q'
    je shutdown

    cmp al, 'Q'
    je shutdown


    jmp desktop_loop


; ============================================================
; ABOUT VERITYOS
; ============================================================

about_screen:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, about_text
    call print_string


.about_wait:
    xor ah, ah
    int 0x16

    cmp al, 27
    je desktop

    cmp al, 13
    je desktop

    jmp .about_wait


; ============================================================
; VERITY AI 1.1
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

    mov si, ai_user_prompt
    call print_string

    mov di, ai_input_buffer
    call ai_read_line

    cmp byte [ai_input_buffer], 0
    je ai_chat_loop


    ; --------------------------------------------------------
    ; EXIT
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_exit
    call strings_equal

    cmp al, 1
    je desktop


    ; --------------------------------------------------------
    ; BYE
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_bye
    call strings_equal

    cmp al, 1
    je desktop


    ; --------------------------------------------------------
    ; HELLO
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_hello
    call strings_equal

    cmp al, 1
    je ai_hello


    ; --------------------------------------------------------
    ; HI
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_hi
    call strings_equal

    cmp al, 1
    je ai_hello


    ; --------------------------------------------------------
    ; HEY
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_hey
    call strings_equal

    cmp al, 1
    je ai_hello


    ; --------------------------------------------------------
    ; HELP
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_help
    call strings_equal

    cmp al, 1
    je ai_help


    ; --------------------------------------------------------
    ; WHO ARE YOU
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_who
    call strings_equal

    cmp al, 1
    je ai_who


    ; --------------------------------------------------------
    ; VERITYOS
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_verityos
    call strings_equal

    cmp al, 1
    je ai_verityos


    ; --------------------------------------------------------
    ; VERITYCRAFT
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_veritycraft
    call strings_equal

    cmp al, 1
    je ai_veritycraft


    ; --------------------------------------------------------
    ; VERITYEDIT
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_verityedit
    call strings_equal

    cmp al, 1
    je ai_verityedit


    ; --------------------------------------------------------
    ; HOW ARE YOU
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_how
    call strings_equal

    cmp al, 1
    je ai_how


    ; --------------------------------------------------------
    ; JOKE
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_joke
    call strings_equal

    cmp al, 1
    je ai_joke


    ; --------------------------------------------------------
    ; VERSION
    ; --------------------------------------------------------

    mov si, ai_input_buffer
    mov di, command_version
    call strings_equal

    cmp al, 1
    je ai_version


    ; --------------------------------------------------------
    ; UNKNOWN
    ; --------------------------------------------------------

    mov si, ai_label
    call print_string

    mov si, reply_unknown
    call print_string

    jmp ai_chat_loop


; ============================================================
; VERITY AI RESPONSES
; ============================================================

ai_hello:
    mov si, ai_label
    call print_string

    mov si, reply_hello
    call print_string

    jmp ai_chat_loop


ai_help:
    mov si, ai_label
    call print_string

    mov si, reply_help
    call print_string

    jmp ai_chat_loop


ai_who:
    mov si, ai_label
    call print_string

    mov si, reply_who
    call print_string

    jmp ai_chat_loop


ai_verityos:
    mov si, ai_label
    call print_string

    mov si, reply_verityos
    call print_string

    jmp ai_chat_loop


ai_veritycraft:
    mov si, ai_label
    call print_string

    mov si, reply_veritycraft
    call print_string

    jmp ai_chat_loop


ai_verityedit:
    mov si, ai_label
    call print_string

    mov si, reply_verityedit
    call print_string

    jmp ai_chat_loop


ai_how:
    mov si, ai_label
    call print_string

    mov si, reply_how
    call print_string

    jmp ai_chat_loop


ai_joke:
    mov si, ai_label
    call print_string

    mov si, reply_joke
    call print_string

    jmp ai_chat_loop


ai_version:
    mov si, ai_label
    call print_string

    mov si, reply_version
    call print_string

    jmp ai_chat_loop


; ============================================================
; AI READ LINE
; ============================================================

ai_read_line:
    push ax
    push bx
    push cx
    push dx
    push di

    xor cx, cx


.read_key:
    xor ah, ah
    int 0x16


    ; ESC = desktop
    cmp al, 27
    je .escape


    ; ENTER
    cmp al, 13
    je .enter


    ; BACKSPACE
    cmp al, 8
    je .backspace


    ; Ignore extended keys
    cmp al, 0
    je .read_key


    ; Maximum size
    cmp cx, AI_INPUT_MAX
    jae .read_key


    ; Convert uppercase to lowercase
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

    call newline

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
; VERITYEDIT 1.0
; ============================================================

verity_edit:
    call restore_kernel_segments

    ; Start with a fresh document
    call editor_clear_buffer

    mov word [editor_length], 0

    call editor_draw_screen

    jmp editor_loop


; ============================================================
; VERITYEDIT MAIN LOOP
; ============================================================

editor_loop:
    xor ah, ah
    int 0x16


    ; --------------------------------------------------------
    ; Extended key / function key
    ; --------------------------------------------------------

    cmp al, 0
    je editor_extended_key


    ; Some BIOSes return E0 for extended keys
    cmp al, 0xE0
    je editor_extended_key


    ; --------------------------------------------------------
    ; ESC = exit editor
    ; --------------------------------------------------------

    cmp al, 27
    je editor_exit


    ; --------------------------------------------------------
    ; ENTER
    ; --------------------------------------------------------

    cmp al, 13
    je editor_enter


    ; --------------------------------------------------------
    ; BACKSPACE
    ; --------------------------------------------------------

    cmp al, 8
    je editor_backspace


    ; --------------------------------------------------------
    ; Ignore control characters
    ; --------------------------------------------------------

    cmp al, 32
    jb editor_loop


    ; --------------------------------------------------------
    ; Normal printable character
    ; --------------------------------------------------------

    call editor_add_char

    jmp editor_loop


; ============================================================
; VERITYEDIT FUNCTION KEYS
; ============================================================

editor_extended_key:

    ; F1 scan code = 3B
    cmp ah, 0x3B
    je editor_help


    ; F2 scan code = 3C
    cmp ah, 0x3C
    je editor_clear


    ; F3 scan code = 3D
    cmp ah, 0x3D
    je editor_demo


    jmp editor_loop


; ============================================================
; ADD CHARACTER
;
; AL = character
; ============================================================

editor_add_char:
    push ax
    push bx
    push si


    mov bx, [editor_length]

    cmp bx, EDIT_BUFFER_SIZE - 1
    jae .full


    mov si, editor_buffer
    add si, bx

    mov [si], al

    inc bx

    mov [editor_length], bx


    ; Null terminate
    mov si, editor_buffer
    add si, bx

    mov byte [si], 0


    pop si
    pop bx
    pop ax


    ; Echo character
    call print_char

    ret


.full:
    pop si
    pop bx
    pop ax

    call editor_full_beep

    ret


; ============================================================
; ENTER / NEW LINE
; ============================================================

editor_enter:
    mov al, 13
    call editor_store_raw

    mov al, 10
    call editor_store_raw

    call newline

    jmp editor_loop


; ============================================================
; STORE RAW CHARACTER
; ============================================================

editor_store_raw:
    push ax
    push bx
    push si


    mov bx, [editor_length]

    cmp bx, EDIT_BUFFER_SIZE - 1
    jae .done


    mov si, editor_buffer
    add si, bx

    mov [si], al

    inc bx

    mov [editor_length], bx


    mov si, editor_buffer
    add si, bx

    mov byte [si], 0


.done:
    pop si
    pop bx
    pop ax

    ret


; ============================================================
; BACKSPACE
; ============================================================

editor_backspace:
    mov bx, [editor_length]

    cmp bx, 0
    je editor_loop


    dec bx
    mov [editor_length], bx


    mov si, editor_buffer
    add si, bx


    ; Was last byte LF?
    cmp byte [si], 10
    jne .normal_character


    ; Remove LF
    mov byte [si], 0


    ; Also remove CR
    cmp bx, 0
    je .redraw


    dec bx
    mov [editor_length], bx

    mov si, editor_buffer
    add si, bx

    mov byte [si], 0


.redraw:
    call editor_draw_screen
    jmp editor_loop


.normal_character:
    mov byte [si], 0

    mov al, 8
    call print_char

    mov al, ' '
    call print_char

    mov al, 8
    call print_char

    jmp editor_loop


; ============================================================
; CLEAR DOCUMENT
; ============================================================

editor_clear:
    call editor_clear_buffer

    mov word [editor_length], 0

    call editor_draw_screen

    jmp editor_loop


editor_clear_buffer:
    push ax
    push cx
    push di

    mov di, editor_buffer

    xor al, al

    mov cx, EDIT_BUFFER_SIZE


.clear_loop:
    mov [di], al
    inc di

    loop .clear_loop


    pop di
    pop cx
    pop ax

    ret


; ============================================================
; DEMO DOCUMENT
; ============================================================

editor_demo:
    call editor_clear_buffer

    mov si, demo_document
    mov di, editor_buffer

    xor cx, cx


.copy:
    mov al, [si]

    cmp al, 0
    je .finished

    mov [di], al

    inc si
    inc di
    inc cx

    cmp cx, EDIT_BUFFER_SIZE - 1
    jb .copy


.finished:
    mov byte [di], 0

    mov [editor_length], cx

    call editor_draw_screen

    jmp editor_loop


; ============================================================
; EDITOR HELP
; ============================================================

editor_help:
    mov ax, 0x0003
    int 0x10

    mov si, editor_help_text
    call print_string


.wait:
    xor ah, ah
    int 0x16

    cmp al, 27
    je .return

    cmp al, 13
    je .return

    jmp .wait


.return:
    call editor_draw_screen

    jmp editor_loop


; ============================================================
; DRAW VERITYEDIT
; ============================================================

editor_draw_screen:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10


    mov si, editor_header
    call print_string


    ; Existing document
    cmp word [editor_length], 0
    je .empty


    mov si, editor_buffer
    call print_string

    ret


.empty:
    ret


; ============================================================
; EXIT VERITYEDIT
; ============================================================

editor_exit:
    jmp desktop


; ============================================================
; EDITOR BUFFER FULL BEEP
; ============================================================

editor_full_beep:
    push ax
    push cx


    mov al, 0xB6
    out 0x43, al


    mov ax, 1193

    out 0x42, al

    mov al, ah
    out 0x42, al


    in al, 0x61
    or al, 3
    out 0x61, al


    mov cx, 0xFFFF


.delay:
    loop .delay


    in al, 0x61
    and al, 0xFC
    out 0x61, al


    pop cx
    pop ax

    ret


; ============================================================
; LOAD VERITYCRAFT
;
; Disk layout remains:
;
; Sector 18 = first game sector
; Head 1 sectors 1-7 = remaining game sectors
;
; ============================================================

load_game:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, loading_game_text
    call print_string


    ; Reset disk
    xor ah, ah

    mov dl, [boot_drive]
    int 0x13

    jc game_error


    ; Destination
    mov ax, GAME_SEGMENT
    mov es, ax

    xor bx, bx


    ; --------------------------------------------------------
    ; Game sector 1
    ;
    ; Cylinder 0
    ; Head 0
    ; Sector 18
    ; --------------------------------------------------------

    mov ah, 0x02
    mov al, 1

    mov ch, 0
    mov cl, 18
    mov dh, 0

    mov dl, [boot_drive]

    int 0x13

    jc game_error


    ; --------------------------------------------------------
    ; Game sectors 2-8
    ;
    ; Cylinder 0
    ; Head 1
    ; Sectors 1-7
    ; --------------------------------------------------------

    mov bx, 0x0200

    mov ah, 0x02
    mov al, 7

    mov ch, 0
    mov cl, 1
    mov dh, 1

    mov dl, [boot_drive]

    int 0x13

    jc game_error


    ; Start game
    mov dl, [boot_drive]

    jmp GAME_SEGMENT:0x0000


; ============================================================
; GAME ERROR
; ============================================================

game_error:
    call restore_kernel_segments

    mov si, game_error_text
    call print_string

    xor ah, ah
    int 0x16

    jmp desktop


; ============================================================
; SHUTDOWN
; ============================================================

shutdown:
    call restore_kernel_segments

    mov ax, 0x0003
    int 0x10

    mov si, shutdown_text
    call print_string


.shutdown_loop:
    cli
    hlt

    jmp .shutdown_loop


; ============================================================
; REBOOT
; ============================================================

reboot:
    jmp 0xFFFF:0x0000


; ============================================================
; STRING COMPARISON
;
; DS:SI = string 1
; DS:DI = string 2
;
; AL = 1 equal
; AL = 0 different
; ============================================================

strings_equal:
    push bx
    push si
    push di


.compare:
    mov al, [si]
    mov bl, [di]

    cmp al, bl
    jne .different

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


.different:
    xor al, al

    pop di
    pop si
    pop bx

    ret


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
; NEWLINE
; ============================================================

newline:
    push ax

    mov al, 13
    call print_char

    mov al, 10
    call print_char

    pop ax

    ret


; ============================================================
; PRINT STRING
;
; Uses CS:SI so kernel strings remain safe even if another
; segment register has been changed.
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
    ; PIT channel 2
    mov al, 0xB6
    out 0x43, al


    ; ~660 Hz
    mov ax, 1808

    out 0x42, al

    mov al, ah
    out 0x42, al


    ; Speaker on
    in al, 0x61

    or al, 00000011b

    out 0x61, al


    ; Delay
    mov cx, 12


.outer:
    push cx

    mov cx, 0xFFFF


.inner:
    loop .inner


    pop cx

    loop .outer


    ; Speaker off
    in al, 0x61

    and al, 11111100b

    out 0x61, al

    ret


; ============================================================
; DATA
; ============================================================

boot_drive:
    db 0


; ============================================================
; VERITYOS 0.2 DESKTOP
; ============================================================

desktop_gui:
    db "+------------------------------------------------------------------------------+",13,10
    db "| VerityOS 0.2                                                     SYSTEM READY |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db "|                                                                              |",13,10
    db "|                         Welcome to VerityOS 0.2!                             |",13,10
    db "|                                                                              |",13,10
    db "|             +----------------+       +----------------+                      |",13,10
    db "|             | [A] Verity AI |       | [E] VerityEdit|                      |",13,10
    db "|             +----------------+       +----------------+                      |",13,10
    db "|                                                                              |",13,10
    db "|             +----------------+       +----------------+                      |",13,10
    db "|             |[G] VerityCraft|       |   [I] About    |                      |",13,10
    db "|             +----------------+       +----------------+                      |",13,10
    db "|                                                                              |",13,10
    db "|                         [R] Reboot                                           |",13,10
    db "|                         [Q] Shutdown                                         |",13,10
    db "|                                                                              |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db "| Verity AI 1.1 | VerityEdit 1.0 | VerityCraft              VerityOS Ready    |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db 0


; ============================================================
; ABOUT SCREEN
; ============================================================

about_text:
    db "+------------------------------------------------------------------------------+",13,10
    db "|                            ABOUT VERITYOS                                    |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db 13,10
    db "VerityOS 0.2",13,10
    db 13,10
    db "16-bit x86 hobby operating system",13,10
    db "Running in BIOS Real Mode",13,10
    db 13,10
    db "Built-in software:",13,10
    db 13,10
    db "  Verity AI 1.1",13,10
    db "  VerityEdit 1.0",13,10
    db "  VerityCraft",13,10
    db 13,10
    db "Press ENTER or ESC to return.",13,10
    db 0


; ============================================================
; VERITY AI
; ============================================================

ai_header:
    db "+------------------------------------------------------------------------------+",13,10
    db "| Verity AI 1.1                                         VerityOS Assistant     |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db 0


ai_welcome:
    db 13,10
    db "Hello! I am Verity AI 1.1. :)",13,10
    db 13,10
    db "Try:",13,10
    db "hello, hi, hey, help, who are you, verityos,",13,10
    db "veritycraft, verityedit, how are you, joke, version",13,10
    db 13,10
    db "Type exit or press ESC to return to VerityOS.",13,10
    db 13,10
    db 0


ai_user_prompt:
    db "You: ",0


ai_label:
    db "Verity AI: ",0


; ============================================================
; AI COMMANDS
; ============================================================

command_hello:
    db "hello",0

command_hi:
    db "hi",0

command_hey:
    db "hey",0

command_help:
    db "help",0

command_who:
    db "who are you",0

command_verityos:
    db "verityos",0

command_veritycraft:
    db "veritycraft",0

command_verityedit:
    db "verityedit",0

command_how:
    db "how are you",0

command_joke:
    db "joke",0

command_version:
    db "version",0

command_exit:
    db "exit",0

command_bye:
    db "bye",0


; ============================================================
; AI RESPONSES
; ============================================================

reply_hello:
    db "Hello! Nice to meet you. :)",13,10
    db "How can I help you today?",13,10
    db 13,10
    db 0


reply_help:
    db "I currently understand:",13,10
    db "hello, hi, hey, help, who are you, verityos,",13,10
    db "veritycraft, verityedit, how are you, joke,",13,10
    db "version, exit and bye.",13,10
    db 13,10
    db 0


reply_who:
    db "I am Verity AI 1.1, the built-in assistant for VerityOS.",13,10
    db "My responses are still hardcoded, but I am learning new tricks.",13,10
    db 13,10
    db 0


reply_verityos:
    db "You are running VerityOS 0.2.",13,10
    db "This release introduces VerityEdit 1.0.",13,10
    db 13,10
    db 0


reply_veritycraft:
    db "VerityCraft is the built-in game for VerityOS.",13,10
    db "You control Verity, a smiling sphere.",13,10
    db 13,10
    db 0


reply_verityedit:
    db "VerityEdit 1.0 is the new text editor in VerityOS 0.2!",13,10
    db "Press E on the desktop to open it.",13,10
    db 13,10
    db 0


reply_how:
    db "I am doing great!",13,10
    db "And nobody is overwriting my sectors today. :)",13,10
    db 13,10
    db 0


reply_joke:
    db "Why did the bootloader cross the disk?",13,10
    db "To get to the other sector.",13,10
    db 13,10
    db 0


reply_version:
    db "Verity AI 1.1",13,10
    db "Running inside VerityOS 0.2.",13,10
    db 13,10
    db 0


reply_unknown:
    db "Hmm... I do not know how to answer that yet.",13,10
    db "Type help to see what I understand.",13,10
    db 13,10
    db 0


; ============================================================
; VERITYEDIT
; ============================================================

editor_header:
    db "+------------------------------------------------------------------------------+",13,10
    db "| VerityEdit 1.0                                             VerityOS 0.2      |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db "| File: UNTITLED.TXT                                                          |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db 13,10
    db 0


editor_help_text:
    db "+------------------------------------------------------------------------------+",13,10
    db "|                         VERITYEDIT 1.0 HELP                                  |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db 13,10
    db "Type normally to edit the document.",13,10
    db 13,10
    db "ENTER      New line",13,10
    db "BACKSPACE  Delete previous character",13,10
    db "F1         Help",13,10
    db "F2         Clear document",13,10
    db "F3         Load demo document",13,10
    db "ESC        Return to VerityOS",13,10
    db 13,10
    db "Documents currently live in RAM only.",13,10
    db "They are not saved after reboot.",13,10
    db 13,10
    db "Press ENTER or ESC to return.",13,10
    db 0


demo_document:
    db "Hello from VerityEdit!",13,10
    db 13,10
    db "This document is running inside VerityOS 0.2.",13,10
    db "VerityEdit 1.0 can type, erase and create new lines.",13,10
    db 13,10
    db "Built one sector at a time. :)",13,10
    db 0


editor_length:
    dw 0


; ============================================================
; GAME TEXT
; ============================================================

loading_game_text:
    db "Loading VerityCraft...",13,10
    db 0


game_error_text:
    db 13,10
    db "ERROR: Could not load VerityCraft!",13,10
    db "Press any key to return to VerityOS.",13,10
    db 0


; ============================================================
; SHUTDOWN TEXT
; ============================================================

shutdown_text:
    db 13,10
    db "+--------------------------------------------------+",13,10
    db "|                                                  |",13,10
    db "|              VerityOS has stopped.               |",13,10
    db "|                                                  |",13,10
    db "|       It is now safe to turn off your            |",13,10
    db "|          extremely imaginary computer.           |",13,10
    db "|                                                  |",13,10
    db "|                       :)                         |",13,10
    db "|                                                  |",13,10
    db "+--------------------------------------------------+",13,10
    db 0


; ============================================================
; AI INPUT BUFFER
; ============================================================

ai_input_buffer:
    times 64 db 0


; ============================================================
; VERITYEDIT BUFFER
;
; 1024 bytes of RAM-backed document storage
; ============================================================

editor_buffer:
    times EDIT_BUFFER_SIZE db 0


; ============================================================
; KERNEL SIZE
;
; VerityOS kernel = 16 sectors = 8192 bytes
; ============================================================

times 8192 - ($ - $$) db 0
