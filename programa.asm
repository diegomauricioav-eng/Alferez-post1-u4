; programa.asm - Laboratorio Post1 Unidad 4
; Propósito: demostrar directivas de sección, datos y constantes en NASM

; Constantes (EQU)
CR          EQU 0Dh
LF          EQU 0Ah
TERMINADOR  EQU 24h    ; '$' terminador de cadena para DOS
ITERACIONES EQU 5      ; número de repeticiones del bucle

section .data
    bienvenida  db "Laboratorio NASM Unidad 4", CR, LF, TERMINADOR
    separador   db "----------------------------------------", CR, LF, TERMINADOR
    etiqueta_a  db "Variable A (word): ", TERMINADOR
    etiqueta_b  db "Variable B (dword): ", TERMINADOR
    fin_msg     db "Programa finalizado correctamente.", CR, LF, TERMINADOR

    ; Tipos de datos demostrados
    var_byte    db 42           ; 1 byte con valor 42
    var_word    dw 1234h        ; 2 bytes con valor 0x1234
    var_dword   dd 0DEADBEEFh   ; 4 bytes
    tabla_bytes db 10, 20, 30, 40, 50 ; 5 bytes consecutivos

section .bss
    buffer      resb 80         ; 80 bytes para entrada
    resultado   resw 1          ; 1 word para almacenamiento

section .text
    global main

main:
    ; Inicializar registro de segmento de datos
    mov ax, data
    mov ds, ax

    ; Imprimir mensaje de bienvenida y separador
    mov ah, 09h
    mov dx, bienvenida
    int 21h

    mov ah, 09h
    mov dx, separador
    int 21h

; Agregar después de "mov dx, separador / int 21h":

    ; === Función 09h: imprimir cadenas ===
    mov  ah, 09h
    mov  dx, etiqueta_a
    int  21h

    ; === Función 02h: imprimir un carácter ===
    ; Imprimir el valor de var_word como dos dígitos hexadecimales
    mov  al, [var_byte]      ; AL = 42 (0x2A)
    add  al, 30h             ; convertir a ASCII: 42 + 48 = 90 ("Z") — solo para demo
    mov  ah, 02h             ; función DOS: imprimir carácter en DL
    mov  dl, al
    int  21h

    ; Imprimir nueva línea
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    ; === Recorrer tabla de bytes e imprimir cada elemento ===
    lea  si, tabla_bytes     ; SI apunta al inicio de la tabla
    mov  cx, ITERACIONES     ; CX = 5 iteraciones

imprimir_tabla:
    mov  al, [si]            ; AL = byte actual de la tabla
    add  al, 30h             ; conversión simple a ASCII (válida para 0-9)
    mov  ah, 02h
    mov  dl, al
    int  21h

    mov  ah, 02h             ; imprimir espacio entre elementos
    mov  dl, 20h
    int  21h

    inc  si                  ; avanzar al siguiente byte
    loop imprimir_tabla      ; CX--; si CX != 0, repetir

    ; Imprimir nueva línea después de la tabla
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h


    ; Terminar el programa
    mov  ax, 4C00h           ; función DOS: terminar, código 0
    int  21h