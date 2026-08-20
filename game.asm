
; VerityCraft 1.2
; Built for VerityOS 0.3
;
; 16-bit x86 Real Mode
; NASM flat binary
;
; Features:
; - Main menu
; - Verity = smiling sphere "O"
; - WASD movement
; - Arrow-key movement
; - Walls
; - Collectible stars
; - Score
; - Bounce counter
; - Corner-hit detection
; - PC Speaker effects
; - ESC returns to game menu
;
; Loaded by VerityOS at 2000:0000
;
; IMPORTANT:
; game.bin is exactly 4096 bytes = 8 sectors.
; ============================================================

bits 16
org 0x0000


; ============================================================
; CONSTANTS
; ============================================================

SCREEN_WIDTH  equ 80
SCREEN_HEIGHT equ 25

PLAY_LEFT     equ 2
PLAY_RIGHT    equ 77
PLAY_TOP      equ 4
PLAY_BOTTOM   equ 21


; ============================================================
; ENTRY
; ============================================================

start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    cli

    mov ax, 0x4000
    mov ss, ax
    mov sp, 0xFFFE

    sti

    call game_start_sound

    jmp game_menu


; ============================================================
; RESTORE SEGMENTS
; ============================================================

restore_segments:
    push cs
    pop ds

    push cs
    pop es

    ret


; ============================================================
; GAME MENU
; ============================================================

game_menu:
    call restore_segments

    mov ax, 0x0003
    int 0x10

    mov si, menu_text
    call print_string


menu_loop:
    xor ah, ah
    int 0x16


    ; ENTER = Play
    cmp al, 13
    je new_game


    ; P = Play
    cmp al, 'p'
    je new_game

    cmp al, 'P'
    je new_game


    ; H = Help
    cmp al, 'h'
    je help_screen

    cmp al, 'H'
    je help_screen


    ; A = About
    cmp al, 'a'
    je about_screen

    cmp al, 'A'
    je about_screen


    ; ESC = stay in VerityCraft menu
    cmp al, 27
    je game_menu


    jmp menu_loop


; ============================================================
; HELP SCREEN
; ============================================================

help_screen:
    mov ax, 0x0003
    int 0x10

    mov si, help_text
    call print_string


.help_wait:
    xor ah, ah
    int 0x16

    cmp al, 27
    je game_menu

    cmp al, 13
    je game_menu

    jmp .help_wait


; ============================================================
; ABOUT SCREEN
; ============================================================

about_screen:
    mov ax, 0x0003
    int 0x10

    mov si, about_text
    call print_string


.about_wait:
    xor ah, ah
    int 0x16

    cmp al, 27
    je game_menu

    cmp al, 13
    je game_menu

    jmp .about_wait


; ============================================================
; NEW GAME
; ============================================================

new_game:
    call restore_segments

    ; Starting position
    mov byte [player_x], 40
    mov byte [player_y], 13

    ; Reset score
    mov word [score], 0

    ; Reset bounce count
    mov word [bounce_count], 0

    ; Reset star
    mov byte [star_x], 20
    mov byte [star_y], 10

    call draw_world

    jmp game_loop


; ============================================================
; MAIN GAME LOOP
; ============================================================

game_loop:
    xor ah, ah
    int 0x16


    ; --------------------------------------------------------
    ; ESC
    ; --------------------------------------------------------

    cmp al, 27
    je game_menu


    ; --------------------------------------------------------
    ; WASD
    ; --------------------------------------------------------

    cmp al, 'w'
    je move_up

    cmp al, 'W'
    je move_up


    cmp al, 's'
    je move_down

    cmp al, 'S'
    je move_down


    cmp al, 'a'
    je move_left

    cmp al, 'A'
    je move_left


    cmp al, 'd'
    je move_right

    cmp al, 'D'
    je move_right


    ; --------------------------------------------------------
    ; EXTENDED KEY
    ; --------------------------------------------------------

    cmp al, 0
    je extended_key

    cmp al, 0xE0
    je extended_key


    jmp game_loop


; ============================================================
; ARROW KEYS
; ============================================================

extended_key:

    ; Up
    cmp ah, 0x48
    je move_up


    ; Down
    cmp ah, 0x50
    je move_down


    ; Left
    cmp ah, 0x4B
    je move_left


    ; Right
    cmp ah, 0x4D
    je move_right


    jmp game_loop


; ============================================================
; MOVE UP
; ============================================================

move_up:
    mov al, [player_y]

    cmp al, PLAY_TOP + 1
    jbe bounce_up

    dec byte [player_y]

    call after_move

    jmp game_loop


bounce_up:
    call register_bounce

    call check_corner

    jmp game_loop


; ============================================================
; MOVE DOWN
; ============================================================

move_down:
    mov al, [player_y]

    cmp al, PLAY_BOTTOM - 1
    jae bounce_down

    inc byte [player_y]

    call after_move

    jmp game_loop


bounce_down:
    call register_bounce

    call check_corner

    jmp game_loop


; ============================================================
; MOVE LEFT
; ============================================================

move_left:
    mov al, [player_x]

    cmp al, PLAY_LEFT + 1
    jbe bounce_left

    dec byte [player_x]

    call after_move

    jmp game_loop


bounce_left:
    call register_bounce

    call check_corner

    jmp game_loop


; ============================================================
; MOVE RIGHT
; ============================================================

move_right:
    mov al, [player_x]

    cmp al, PLAY_RIGHT - 1
    jae bounce_right

    inc byte [player_x]

    call after_move

    jmp game_loop


bounce_right:
    call register_bounce

    call check_corner

    jmp game_loop


; ============================================================
; AFTER MOVEMENT
; ============================================================

after_move:
    call check_star

    call draw_world

    ret


; ============================================================
; REGISTER WALL BOUNCE
; ============================================================

register_bounce:
    inc word [bounce_count]

    call bounce_sound

    call draw_world

    ret


; ============================================================
; CHECK FOR CORNER HIT
;
; Because movement is manual, a "corner hit" means Verity is
; sitting directly beside both a horizontal and vertical wall.
; ============================================================

check_corner:

    ; Left side?
    mov al, [player_x]

    cmp al, PLAY_LEFT + 1
    je .check_vertical


    ; Right side?
    cmp al, PLAY_RIGHT - 1
    je .check_vertical

    ret


.check_vertical:
    mov al, [player_y]


    ; Top?
    cmp al, PLAY_TOP + 1
    je .corner


    ; Bottom?
    cmp al, PLAY_BOTTOM - 1
    je .corner

    ret


.corner:
    call corner_sound

    call draw_world

    call show_corner_message

    ret


; ============================================================
; CORNER MESSAGE
; ============================================================

show_corner_message:
    ; Row 23
    mov dh, 23

    ; Column 26
    mov dl, 26

    call set_cursor

    mov si, corner_text
    call print_string

    ret


; ============================================================
; CHECK STAR
; ============================================================

check_star:
    mov al, [player_x]

    cmp al, [star_x]
    jne .done


    mov al, [player_y]

    cmp al, [star_y]
    jne .done


    ; Increase score
    inc word [score]

    call collect_sound

    call move_star


.done:
    ret


; ============================================================
; MOVE STAR
;
; Simple deterministic locations.
; No random-number generator needed yet.
; ============================================================

move_star:
    inc byte [star_index]

    mov al, [star_index]

    cmp al, 6
    jb .valid


    mov byte [star_index], 0


.valid:
    xor bx, bx

    mov bl, [star_index]

    shl bx, 1


    mov si, star_positions

    add si, bx


    mov al, [si]
    mov [star_x], al


    mov al, [si + 1]
    mov [star_y], al

    ret


; ============================================================
; DRAW WORLD
; ============================================================

draw_world:
    call restore_segments

    mov ax, 0x0003
    int 0x10


    mov si, world_header
    call print_string


    ; --------------------------------------------------------
    ; Top border
    ; --------------------------------------------------------

    mov dh, PLAY_TOP
    mov dl, PLAY_LEFT

    call set_cursor


    mov cx, PLAY_RIGHT - PLAY_LEFT + 1


.top_loop:
    mov al, '#'
    call print_char

    loop .top_loop


    ; --------------------------------------------------------
    ; Side borders
    ; --------------------------------------------------------

    mov dh, PLAY_TOP + 1


.side_loop:
    cmp dh, PLAY_BOTTOM
    jae .bottom_border


    ; Left wall
    mov dl, PLAY_LEFT
    call set_cursor

    mov al, '#'
    call print_char


    ; Right wall
    mov dl, PLAY_RIGHT
    call set_cursor

    mov al, '#'
    call print_char


    inc dh

    jmp .side_loop


    ; --------------------------------------------------------
    ; Bottom border
    ; --------------------------------------------------------

.bottom_border:
    mov dh, PLAY_BOTTOM
    mov dl, PLAY_LEFT

    call set_cursor


    mov cx, PLAY_RIGHT - PLAY_LEFT + 1


.bottom_loop:
    mov al, '#'
    call print_char

    loop .bottom_loop


    ; --------------------------------------------------------
    ; Draw star
    ; --------------------------------------------------------

    mov dh, [star_y]
    mov dl, [star_x]

    call set_cursor

    mov al, '*'
    call print_char


    ; --------------------------------------------------------
    ; Draw Verity
    ; --------------------------------------------------------

    mov dh, [player_y]
    mov dl, [player_x]

    call set_cursor

    mov al, 'O'
    call print_char


    ; --------------------------------------------------------
    ; Status line
    ; --------------------------------------------------------

    mov dh, 22
    mov dl, 2

    call set_cursor


    mov si, score_text
    call print_string


    mov ax, [score]
    call print_number


    mov si, bounce_text
    call print_string


    mov ax, [bounce_count]
    call print_number


    ; --------------------------------------------------------
    ; Controls
    ; --------------------------------------------------------

    mov dh, 24
    mov dl, 2

    call set_cursor

    mov si, controls_text
    call print_string

    ret


; ============================================================
; SET CURSOR
;
; DH = row
; DL = column
; ============================================================

set_cursor:
    push ax
    push bx

    mov ah, 0x02
    mov bh, 0

    int 0x10

    pop bx
    pop ax

    ret


; ============================================================
; PRINT NUMBER
;
; AX = unsigned integer
; ============================================================

print_number:
    push ax
    push bx
    push cx
    push dx


    cmp ax, 0
    jne .convert


    mov al, '0'
    call print_char

    jmp .done


.convert:
    xor cx, cx

    mov bx, 10


.divide:
    xor dx, dx

    div bx

    push dx

    inc cx

    test ax, ax
    jnz .divide


.print:
    pop dx

    mov al, dl
    add al, '0'

    call print_char

    loop .print


.done:
    pop dx
    pop cx
    pop bx
    pop ax

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
; PRINT STRING
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
; GAME START SOUND
; ============================================================

game_start_sound:
    mov ax, 880
    call play_tone

    mov ax, 1100
    call play_tone

    ret


; ============================================================
; BOUNCE SOUND
; ============================================================

bounce_sound:
    mov ax, 500
    call play_short_tone

    ret


; ============================================================
; COLLECT SOUND
; ============================================================

collect_sound:
    mov ax, 1200
    call play_short_tone

    mov ax, 1500
    call play_short_tone

    ret


; ============================================================
; CORNER SOUND
; ============================================================

corner_sound:
    mov ax, 900
    call play_short_tone

    mov ax, 1200
    call play_short_tone

    mov ax, 1600
    call play_short_tone

    ret


; ============================================================
; PLAY TONE
;
; AX = approximate frequency
; ============================================================

play_tone:
    push ax
    push bx
    push cx
    push dx


    mov bx, ax


    ; PIT divisor = 1193180 / frequency
    mov dx, 0x0012
    mov ax, 0x34DC

    div bx

    mov bx, ax


    mov al, 0xB6
    out 0x43, al


    mov ax, bx

    out 0x42, al

    mov al, ah
    out 0x42, al


    in al, 0x61

    or al, 3

    out 0x61, al


    mov cx, 3


.delay_outer:
    push cx

    mov cx, 0xFFFF


.delay_inner:
    loop .delay_inner


    pop cx

    loop .delay_outer


    in al, 0x61

    and al, 0xFC

    out 0x61, al


    pop dx
    pop cx
    pop bx
    pop ax

    ret


; ============================================================
; SHORT TONE
; ============================================================

play_short_tone:
    push ax
    push bx
    push cx
    push dx


    mov bx, ax


    mov dx, 0x0012
    mov ax, 0x34DC

    div bx

    mov bx, ax


    mov al, 0xB6
    out 0x43, al


    mov ax, bx

    out 0x42, al

    mov al, ah
    out 0x42, al


    in al, 0x61

    or al, 3

    out 0x61, al


    mov cx, 0x7FFF


.delay:
    loop .delay


    in al, 0x61

    and al, 0xFC

    out 0x61, al


    pop dx
    pop cx
    pop bx
    pop ax

    ret


; ============================================================
; DATA
; ============================================================

player_x:
    db 40

player_y:
    db 13


star_x:
    db 20

star_y:
    db 10

star_index:
    db 0


score:
    dw 0


bounce_count:
    dw 0


; ============================================================
; STAR POSITIONS
; ============================================================

star_positions:
    db 20, 10
    db 60, 16
    db 15, 18
    db 68, 7
    db 35, 8
    db 52, 19


; ============================================================
; MENU
; ============================================================

menu_text:
        db "+------------------------------------------------------------------------------+",13,10
        db "|                              VerityCraft 1.2                                 |",13,10
        db "+------------------------------------------------------------------------------+",13,10
        db "|                                                                              |",13,10
        db "|                                  (o_o)                                       |",13,10
        db "|                                   \_/                                        |",13,10
        db "|                                  VERITY                                      |",13,10
        db "|                                                                              |",13,10
        db "|                              [ENTER] PLAY                                    |",13,10
        db "|                                [H] HELP                                      |",13,10
        db "|                                [A] ABOUT                                     |",13,10
        db "|                                                                              |",13,10
        db "+------------------------------------------------------------------------------+",13,10
        db 0


; ============================================================
; HELP
; ============================================================

help_text:
    db "+------------------------------------------------------------------------------+",13,10
    db "|                          VERITYCRAFT 1.1 HELP                                |",13,10
    db "+------------------------------------------------------------------------------+",13,10
    db 13,10
    db "You control Verity, a smiling sphere.",13,10
    db 13,10
    db "Movement:",13,10
    db 13,10
    db "    W / UP ARROW       Move up",13,10
    db "    S / DOWN ARROW     Move down",13,10
    db "    A / LEFT ARROW     Move left",13,10
    db "    D / RIGHT ARROW    Move right",13,10
    db 13,10
    db "Collect * stars to increase your score.",13,10
    db 13,10
    db "Running into a wall increases your bounce count.",13,10
    db 13,10
    db "Try getting Verity into a corner like a DVD screensaver. :)",13,10
    db 13,10
    db "ESC returns to the VerityCraft menu.",13,10
    db 13,10
    db "Press ENTER or ESC to return.",13,10
    db 0


; ============================================================
; ABOUT
; ============================================================

about_text:
        db "+------------------------------------------------------------------------------+",13,10
        db "|                         ABOUT VERITYCRAFT                                    |",13,10
        db "+------------------------------------------------------------------------------+",13,10
        db 13,10
        db "VerityCraft 1.2",13,10
        db "Built for VerityOS 0.3",13,10
        db 13,10
        db "Control Verity, a smiling sphere.",13,10
        db "Written in 16-bit x86 Assembly.",13,10
        db 13,10
        db "Press ENTER or ESC to return.",13,10
        db 0


; ============================================================
; WORLD UI
; ============================================================

world_header:
    db " VerityCraft 1.2        Collect the * stars!        VerityOS 0.3",13,10
    db " WASD / Arrows = Move                              ESC = Menu",13,10
    db 0


score_text:
    db "Score: ",0


bounce_text:
    db "     Bounces: ",0


controls_text:
    db "WASD/Arrows: Move    *: Collect    ESC: Menu",0


corner_text:
    db "*** PERFECT CORNER HIT! ***",0


; ============================================================
; EXACT GAME SIZE
;
; 8 sectors x 512 bytes = 4096 bytes
;
; DO NOT casually increase this number.
; Current disk layout expects VerityCraft to occupy
; sectors 18 through 25.
; ============================================================

times 4096 - ($ - $$) db 0
