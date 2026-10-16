; programa.asm - Laboratorio Post1 Unidad 4 (Parte 1)
; Proposito: se demuestra el uso de las directivas de seccion, de datos y de
; constantes en NASM, junto con la salida por pantalla mediante INT 21h.
;
; Ensamblado y enlazado (desde DOSBox):
;   nasm -f obj programa.asm -o programa.obj
;   alink programa.obj -oEXE -o programa.exe -entry main

; ---------------------------------------------------------------------------
; Constantes (EQU): no reservan memoria, el ensamblador las resuelve al compilar
; ---------------------------------------------------------------------------
CR          EQU 0Dh         ; Carriage Return
LF          EQU 0Ah         ; Line Feed
TERMINADOR  EQU 24h         ; "$", terminador de cadena para la funcion 09h
ITERACIONES EQU 5           ; numero de elementos que recorre el bucle
ANCHO_LINEA EQU 40          ; ancho en caracteres de la linea decorativa

; ---------------------------------------------------------------------------
; Datos inicializados
; ---------------------------------------------------------------------------
section .data
    bienvenida  db "Laboratorio NASM Unidad 4", CR, LF, TERMINADOR
    separador   db "----------------------------------------", CR, LF, TERMINADOR

    ; Linea decorativa: TIMES repite el byte "=" ANCHO_LINEA veces en tiempo
    ; de ensamblado, de modo que los bytes quedan escritos en la imagen del
    ; ejecutable y no se genera ninguna instruccion para producirlos.
    linea_gruesa:
        times ANCHO_LINEA db '='
        db CR, LF, TERMINADOR

    etiqueta_a  db "Variable A (word): ", TERMINADOR
    etiqueta_b  db "Variable B (dword): ", TERMINADOR
    fin_msg     db "Programa finalizado correctamente.", CR, LF, TERMINADOR

    ; Tipos de datos demostrados
    var_byte    db 42                   ; 1 byte con el valor 42
    var_word    dw 1234h                ; 2 bytes con el valor 0x1234
    var_dword   dd 0DEADBEEFh           ; 4 bytes
    tabla_bytes db 10, 20, 30, 40, 50   ; 5 bytes consecutivos

; ---------------------------------------------------------------------------
; Datos no inicializados
; ---------------------------------------------------------------------------
section .bss
    buffer      resb 80         ; 80 bytes reservados para una entrada futura
    resultado   resw 1          ; 1 word reservado para almacenar un calculo

; ---------------------------------------------------------------------------
; Pila (se declara para que ALINK no emita advertencia de pila ausente)
; ---------------------------------------------------------------------------
segment stack stack
    resb 256

; ---------------------------------------------------------------------------
; Codigo ejecutable
; ---------------------------------------------------------------------------
section .text
    global main

main:
    ; Se inicializa DS con el segmento donde reside la seccion .data
    mov  ax, seg bienvenida
    mov  ds, ax

    ; Funcion 09h de INT 21h: se imprime el mensaje de bienvenida
    mov  ah, 09h                ; AH = 09h, imprimir cadena terminada en "$"
    mov  dx, bienvenida         ; DX = desplazamiento de la cadena en DS
    int  21h

    ; Se imprime el separador
    mov  dx, separador
    int  21h

    ; Se imprime la etiqueta de la variable A
    mov  dx, etiqueta_a
    int  21h

    ; Funcion 02h de INT 21h: se imprime un solo caracter cargado en DL
    mov  al, [var_byte]         ; AL = 42 (2Ah)
    add  al, 30h                ; AL = 42 + 48 = 90, codigo ASCII de "Z" (solo demostrativo)
    mov  ah, 02h                ; AH = 02h, imprimir caracter de DL
    mov  dl, al
    int  21h

    ; Se imprime un salto de linea (CR + LF)
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    ; Se recorre la tabla de bytes imprimiendo cada elemento
    lea  si, [tabla_bytes]      ; SI apunta al primer byte de la tabla
    mov  cx, ITERACIONES        ; CX = 5, cantidad de iteraciones de LOOP

imprimir_tabla:
    mov  al, [si]               ; AL = byte actual de la tabla
    add  al, 30h                ; conversion simple a ASCII (solo exacta para 0-9)
    mov  ah, 02h
    mov  dl, al
    int  21h

    mov  dl, 20h                ; se imprime un espacio entre elementos
    int  21h

    inc  si                     ; SI avanza al siguiente byte de la tabla
    loop imprimir_tabla         ; CX = CX - 1; si CX != 0 se repite el bucle

    ; Se imprime un salto de linea despues de la tabla
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    ; Se imprime el mensaje final
    mov  ah, 09h
    mov  dx, fin_msg
    int  21h

    ; Se imprime la linea decorativa generada con TIMES
    mov  dx, linea_gruesa
    int  21h

    ; Funcion 4Ch de INT 21h: se termina el programa con codigo de salida 0
    mov  ax, 4C00h
    int  21h