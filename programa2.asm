; programa2.asm - Laboratorio Post1 Unidad 4, Parte 2
; Integra macros, un bucle acumulador con LOOP, condicionales CMP/Jcc,
; una macro con %rep y una segunda procedura de comparacion con JLE.

%include "macros.asm"       ; incluye la biblioteca de macros textualmente

; ---------------------------------------------------------------
; Datos inicializados. Cada cadena termina en 24h ("$"),
; el terminador que exige la funcion 09h de INT 21h.
; ---------------------------------------------------------------
section .data
titulo          db "= Macros y Control de Flujo =", 0Dh, 0Ah, 24h
linea_a         db "[Linea A] Primera impresion", 0Dh, 0Ah, 24h
linea_b         db "[Linea B] Segunda impresion", 0Dh, 0Ah, 24h
msg_suma        db "La suma de 1 a 3 es: ", 24h
msg_mayor       db "El valor mayor es: ", 24h
msg_iguales     db "Los valores son iguales.", 0Dh, 0Ah, 24h
msg_fin         db "Fin del programa.", 0Dh, 0Ah, 24h
separador_corto db "---", 0Dh, 0Ah, 24h        ; usado por bloque_decorativo (%rep)
msg_menor_igual db "AX es menor o igual: ", 24h ; usado por comparar_menor_o_igual
msg_mayor2      db "AX es mayor: ", 24h         ; usado por comparar_menor_o_igual

; ---------------------------------------------------------------
; Datos no inicializados: un word reservado para cada valor.
; ---------------------------------------------------------------
section .bss
valor_a     resw 1
valor_b     resw 1

; ---------------------------------------------------------------
; Codigo ejecutable.
; ---------------------------------------------------------------
section .text
global main

main:
    mov ax, data            ; AX = segmento de la seccion .data
    mov ds, ax              ; DS apunta a los datos

    print_str titulo        ; 1. encabezado con la macro print_str

    repetir_str linea_a, 3  ; 2. imprime linea_a exactamente 3 veces

    mov cx, 3               ; 3. CX = N = 3 para la suma 1+2+3
    call sumar_serie        ; AX = 6
    print_str msg_suma      ; etiqueta del resultado (AX se conserva)
    print_digito            ; imprime el digito "6"
    nueva_linea

    mov ax, 9               ; 4. compara 9 contra 4
    mov bx, 4
    call comparar_e_imprimir ; el mayor es 9

    mov ax, 5               ; 5. compara 5 contra 5
    mov bx, 5
    call comparar_e_imprimir ; los valores son iguales

    bloque_decorativo 3     ; 7. tres copias de "---" desenrolladas con %rep

    mov ax, 3               ; 8. compara 3 contra 8 con la condicion JLE
    mov bx, 8
    call comparar_menor_o_igual ; imprime "AX es menor o igual: 3"

    print_str msg_fin       ; 9. mensaje final
    fin_dos                 ; termina el programa con la macro fin_dos

; ---------------------------------------------------------------
; Procedimiento sumar_serie: calcula 1+2+...+N con LOOP.
; Entrada: CX = N.  Salida: AX = suma total.
; CX se preserva con PUSH/POP porque LOOP lo decrementa.
; ---------------------------------------------------------------
sumar_serie:
    push cx                 ; guarda el valor original de CX
    xor ax, ax              ; AX = 0 (acumulador)
.paso:
    add ax, cx              ; AX = AX + CX (suma N, N-1, ..., 1)
    loop .paso              ; CX = CX - 1; si CX != 0, continua
    pop cx                  ; restaura CX
    ret

; ---------------------------------------------------------------
; Procedimiento comparar_e_imprimir: compara AX y BX e imprime
; el mayor, o un mensaje de igualdad.
; Preserva AX y BX con PUSH/POP.
; CMP actualiza los flags; JE evalua ZF y JG evalua ZF, SF y OF
; (comparacion con signo).
; ---------------------------------------------------------------
comparar_e_imprimir:
    push ax                 ; preserva AX
    push bx                 ; preserva BX
    cmp ax, bx              ; flags segun AX - BX, sin modificar operandos
    je .son_iguales         ; si AX = BX (ZF = 1)
    jg .ax_mayor            ; si AX > BX con signo

    print_str msg_mayor     ; caso BX mayor
    mov al, bl              ; AL = valor de BX
    print_digito
    nueva_linea
    jmp .fin_comp

.ax_mayor:                  ; caso AX mayor
    print_str msg_mayor
    print_digito            ; AL aun contiene el valor de AX
    nueva_linea
    jmp .fin_comp

.son_iguales:               ; caso AX igual a BX
    print_str msg_iguales

.fin_comp:
    pop bx                  ; restaura BX
    pop ax                  ; restaura AX
    ret

; ---------------------------------------------------------------
; Procedimiento comparar_menor_o_igual: compara AX y BX e indica si
; AX es menor o igual que BX, o si AX es mayor. Imprime el valor de AX.
; Reutiliza las macros print_str, print_digito y nueva_linea.
; A diferencia de comparar_e_imprimir (que decide con JE y JG), aqui
; la decision se toma con una sola instruccion: JLE, que salta si
; ZF = 1 o SF != OF (AX <= BX con signo).
; Preserva AX y BX con PUSH/POP.
; Las etiquetas con punto pertenecen a este procedimiento (quedan
; como comparar_menor_o_igual.menor_o_igual, etc.), por lo que no
; colisionan con las de comparar_e_imprimir.
; ---------------------------------------------------------------
comparar_menor_o_igual:
    push ax                 ; preserva AX
    push bx                 ; preserva BX
    cmp ax, bx              ; flags segun AX - BX, sin modificar operandos
    jle .menor_o_igual      ; si AX <= BX con signo, salta

    print_str msg_mayor2    ; caso AX mayor que BX
    print_digito            ; imprime AX (AL se conserva tras print_str)
    jmp .fin_cmp2

.menor_o_igual:             ; caso AX menor o igual que BX
    print_str msg_menor_igual
    print_digito            ; imprime AX

.fin_cmp2:
    nueva_linea
    pop bx                  ; restaura BX
    pop ax                  ; restaura AX
    ret