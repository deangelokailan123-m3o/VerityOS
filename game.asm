bits 16
org 0x0000

WORLD_W equ 20
WORLD_H equ 9

start:
    ; Set segment registers to the game's segment
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Default menu selection
    mov byte [menu_choice], 0

menu_loop:
    call draw_menu
    call menu_input
    jmp menu_loop


; ============================================================
; MENU INPUT
; ============================================================

menu_input:
    xor ah, ah
    int 0x16

    ; ENTER
    cmp al, 13
    je menu_select

    ; Arrow keys are extended keys
    cmp al, 0
    jne .done

    ; Up Arrow
    cmp ah, 0x48
    je menu_up

    ; Down Arrow
    cmp ah, 0x50
    je menu_down

.done:
    ret


menu_up:
    cmp byte [menu_choice], 0
    je .wrap

    dec byte [menu_choice]
    ret

.wrap:
    mov byte [menu_choice], 2
    ret


menu_down:
    cmp byte [menu_choice], 2
    je .wrap

    inc byte [menu_choice]
    ret

.wrap:
    mov byte [menu_choice], 0
    ret


menu_select:
    mov al, [menu_choice]

    cmp al, 0
    je start_game

    cmp al, 1
    je show_about

    cmp al, 2
    je quit

    ret


; ============================================================
; DRAW MENU
; ============================================================

draw_menu:
    ; Clear screen
    mov ax, 0x0003
    int 0x10

    mov si, menu_title
    call print_string

    ; Start Game
    mov al, [menu_choice]
    cmp al, 0
    jne .start_normal

    mov si, selected_marker
    call print_string
    jmp .start_text

.start_normal:
    mov si, normal_marker
    call print_string

.start_text:
    mov si, start_text
    call print_string


    ; About
    mov al, [menu_choice]
    cmp al, 1
    jne .about_normal

    mov si, selected_marker
    call print_string
    jmp .about_text

.about_normal:
    mov si, normal_marker
    call print_string

.about_text:
    mov si, about_text
    call print_string


    ; Exit
    mov al, [menu_choice]
    cmp al, 2
    jne .exit_normal

    mov si, selected_marker
    call print_string
    jmp .exit_text

.exit_normal:
    mov si, normal_marker
    call print_string

.exit_text:
    mov si, exit_text
    call print_string

    mov si, menu_help
    call print_string

    ret


; ============================================================
; ABOUT SCREEN
; ============================================================

show_about:
    mov ax, 0x0003
    int 0x10

    mov si, about_screen
    call print_string

.wait_for_key:
    xor ah, ah
    int 0x16

    cmp al, 13
    je menu_loop

    cmp al, 27
    je menu_loop

    jmp .wait_for_key


; ============================================================
; START GAME
; ============================================================

start_game:
    mov byte [player_x], 8
    mov byte [player_y], 4

game_loop:
    call draw_game
    call game_input
    jmp game_loop


; ============================================================
; GAME INPUT
; WASD + Arrow Keys
; ============================================================

game_input:
    xor ah, ah
    int 0x16

    ; ESC returns to menu
    cmp al, 27
    je menu_loop

    ; WASD
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

    ; Extended key?
    cmp al, 0
    jne .done

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

.done:
    ret


; ============================================================
; MOVEMENT
; ============================================================

move_up:
    cmp byte [player_y], 1
    jbe .done

    dec byte [player_y]

.done:
    ret


move_down:
    cmp byte [player_y], WORLD_H - 2
    jae .done

    inc byte [player_y]

.done:
    ret


move_left:
    cmp byte [player_x], 1
    jbe .done

    dec byte [player_x]

.done:
    ret


move_right:
    cmp byte [player_x], WORLD_W - 2
    jae .done

    inc byte [player_x]

.done:
    ret


; ============================================================
; DRAW GAME WORLD
; ============================================================

draw_game:
    ; Clear screen
    mov ax, 0x0003
    int 0x10

    mov si, game_title
    call print_string

    xor dh, dh

.row_loop:
    xor dl, dl

.column_loop:

    ; Top border
    cmp dh, 0
    je .draw_wall

    ; Bottom border
    cmp dh, WORLD_H - 1
    je .draw_wall

    ; Left border
    cmp dl, 0
    je .draw_wall

    ; Right border
    cmp dl, WORLD_W - 1
    je .draw_wall

    ; Player position?
    mov al, [player_x]
    cmp dl, al
    jne .draw_space

    mov al, [player_y]
    cmp dh, al
    jne .draw_space

    ; Verity
    mov al, 'O'
    call print_char
    jmp .next_column


.draw_wall:
    mov al, '#'
    call print_char
    jmp .next_column


.draw_space:
    mov al, ' '
    call print_char


.next_column:
    inc dl

    cmp dl, WORLD_W
    jb .column_loop

    ; New line
    mov al, 13
    call print_char

    mov al, 10
    call print_char

    inc dh

    cmp dh, WORLD_H
    jb .row_loop

    mov si, game_controls
    call print_string

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
; DS:SI = null-terminated string
; ============================================================

print_string:
.next:
    lodsb

    test al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0
    mov bl, 7
    int 0x10

    jmp .next

.done:
    ret


; ============================================================
; EXIT VERITYCRAFT
; ============================================================

quit:
    mov ax, 0x0003
    int 0x10

    mov si, goodbye
    call print_string

halt:
    cli
    hlt
    jmp halt


; ============================================================
; DATA
; ============================================================

menu_choice db 0

player_x db 8
player_y db 4


menu_title:
    db "==============================", 13, 10
    db "        VERITYCRAFT 1.0", 13, 10
    db "==============================", 13, 10
    db 13, 10
    db 0


selected_marker:
    db "> ", 0

normal_marker:
    db "  ", 0


start_text:
    db "Start Game", 13, 10, 0

about_text:
    db "About", 13, 10, 0

exit_text:
    db "Exit", 13, 10, 0


menu_help:
    db 13, 10
    db "Use Up/Down Arrows and ENTER", 13, 10
    db 0


about_screen:
    db "==============================", 13, 10
    db "        ABOUT VERITYCRAFT", 13, 10
    db "==============================", 13, 10
    db 13, 10
    db "VerityCraft 1.0", 13, 10
    db "Running on VerityOS 0.1", 13, 10
    db 13, 10
    db "Verity is a smiling sphere.", 13, 10
    db 13, 10
    db "Move using WASD or Arrow Keys.", 13, 10
    db 13, 10
    db "Press ENTER or ESC to return.", 13, 10
    db 0


game_title:
    db "==============================", 13, 10
    db "        VERITYCRAFT 1.0", 13, 10
    db "==============================", 13, 10
    db 0


game_controls:
    db 13, 10
    db "Move: WASD / Arrow Keys", 13, 10
    db "ESC: Main Menu", 13, 10
    db 0


goodbye:
    db "Thanks for playing VerityCraft!", 13, 10
    db 0


; ============================================================
; PAD TO 8 SECTORS = 4096 BYTES
; ============================================================

times 4096 - ($ - $$) db 0
