; macros.asm - biblioteca de macros utilitarias para DOS (INT 21h)
; El archivo se incluye en programa2.asm mediante la directiva %include.

; ---------------------------------------------------------------
; Macro fin_dos: termina el programa con codigo de salida 0.
; La funcion 4Ch de INT 21h devuelve el control al sistema.
; ---------------------------------------------------------------
%macro fin_dos 0
    mov ax, 4C00h           ; AH = 4Ch (terminar), AL = 00h (codigo de salida)
    int 21h                 ; llamada a DOS
%endmacro

; ---------------------------------------------------------------
; Macro nueva_linea: imprime un salto de linea (CR + LF).
; Usa la funcion 02h, que imprime el caracter cargado en DL.
; ---------------------------------------------------------------
%macro nueva_linea 0
    mov ah, 02h             ; funcion DOS: imprimir un caracter
    mov dl, 0Dh             ; DL = retorno de carro (CR)
    int 21h
    mov dl, 0Ah             ; DL = avance de linea (LF)
    int 21h
%endmacro

; ---------------------------------------------------------------
; Macro print_str: imprime una cadena terminada en "$".
; Parametro %1: etiqueta de la cadena.
; La funcion 09h deja AL = 24h al terminar, por lo que la macro
; guarda y restaura AX para no destruir el valor que el programa
; tenia en AL.
; ---------------------------------------------------------------
%macro print_str 1
    push ax                 ; preserva AX
    mov ah, 09h             ; funcion DOS: imprimir cadena
    mov dx, %1              ; DX = direccion de la cadena
    int 21h
    pop ax                  ; restaura AX
%endmacro

; ---------------------------------------------------------------
; Macro print_char: imprime un caracter unico.
; Parametro %1: valor ASCII del caracter (inmediato o registro de 8 bits).
; ---------------------------------------------------------------
%macro print_char 1
    mov ah, 02h             ; funcion DOS: imprimir caracter en DL
    mov dl, %1              ; DL = caracter a imprimir
    int 21h
%endmacro

; ---------------------------------------------------------------
; Macro leer_char: lee un caracter del teclado sin eco.
; El caracter leido queda en AL.
; ---------------------------------------------------------------
%macro leer_char 0
    mov ah, 07h             ; funcion DOS: entrada sin eco
    int 21h
%endmacro

; ---------------------------------------------------------------
; Macro repetir_str: imprime una cadena N veces.
; Parametro %1: etiqueta de la cadena a imprimir.
; Parametro %2: numero de repeticiones (inmediato numerico).
; La etiqueta local %%ciclo se genera unica en cada expansion,
; lo que permite invocar la macro varias veces sin colisiones.
; ---------------------------------------------------------------
%macro repetir_str 2
    push cx                 ; preserva CX, que LOOP modifica
    mov cx, %2              ; CX = contador de repeticiones
%%ciclo:                    ; etiqueta unica por expansion
    mov ah, 09h             ; funcion DOS: imprimir cadena
    mov dx, %1              ; DX = direccion de la cadena
    int 21h
    loop %%ciclo            ; CX = CX - 1; si CX != 0, repite
    pop cx                  ; restaura CX
%endmacro

; ---------------------------------------------------------------
; Macro print_digito: imprime el digito decimal (0-9) contenido en AL.
; Solo es correcta para valores entre 0 y 9.
; Preserva AX mediante la pila.
; ---------------------------------------------------------------
%macro print_digito 0
    push ax                 ; preserva AX
    and al, 0Fh             ; deja solo el nibble bajo (0-9)
    add al, 30h             ; convierte a ASCII: 0 -> "0", 9 -> "9"
    mov ah, 02h             ; funcion DOS: imprimir caracter en DL
    mov dl, al
    int 21h
    pop ax                  ; restaura AX
%endmacro

; ---------------------------------------------------------------
; Macro bloque_decorativo: imprime el separador corto N veces,
; desenrollado en tiempo de ensamblado con %rep.
; Parametro %1: numero de copias (constante conocida al ensamblar,
; no un valor leido en tiempo de ejecucion).
; %rep duplica el codigo encerrado antes de ensamblar, por lo que
; el codigo expandido no contiene CX ni LOOP. La macro no necesita
; etiquetas locales porque su cuerpo no contiene ningun salto.
; La cadena separador_corto debe existir en la seccion .data del
; programa que invoca la macro.
; ---------------------------------------------------------------
%macro bloque_decorativo 1
%rep %1
    print_str separador_corto   ; cada copia es codigo independiente
%endrep
%endmacro