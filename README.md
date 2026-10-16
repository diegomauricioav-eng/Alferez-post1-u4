# Alferez-post1-u4

## Descripción

Laboratorio de la Unidad 4 (Arquitectura de Computadores): programa NASM con segmentos y salida por interrupciones DOS (Parte 1) y macros con control de flujo (Parte 2). En la Parte 1 se implementa un programa de 16 bits con las secciones `.data`, `.bss` y `.text`, constantes con `EQU`, inicialización del registro de segmento DS, salida con las funciones 09h y 02h de la interrupción 21h, un recorrido de tabla con `LOOP` y una línea decorativa generada con `TIMES`.

## Prerrequisitos

- DOSBox 0.74 o superior
- NASM 2.14 o superior (`nasm.exe` en la carpeta de trabajo)
- ALINK (`alink.exe` en la carpeta de trabajo)
- `RSX.EXE` y `CWSDPMI.EXE` en la carpeta de trabajo: ALINK necesita un host DPMI para ejecutarse; sin él muestra el error `No DPMI-host found!`
- Editor de texto plano con codificación ASCII, sin BOM

## Compilación y ejecución — Parte 1

Dentro de DOSBox, con la carpeta de trabajo montada como `C:`:

```
mount C C:\ruta\de\tu\carpeta
C:
cwsdpmi
nasm -f obj programa.asm -o programa.obj
alink programa.obj -oEXE -o programa.exe -entry main
programa.exe
```

El comando `cwsdpmi` se ejecuta una sola vez por sesión de DOSBox, antes de `alink`.

## Estructura del repositorio

```
Alferez-post1-u4/
  programa.asm      ; Parte 1
  README.md
  capturas/         ; evidencia de ensamblado y ejecución en DOSBox
```

## Salida esperada — Parte 1

```
Laboratorio NASM Unidad 4
----------------------------------------
Variable A (word): Z
: D N X b 
Programa finalizado correctamente.
========================================
```

Los caracteres de la tabla (`: D N X b`) resultan de sumar 30h a los valores 10, 20, 30, 40 y 50; no son dígitos porque los valores superan 9. La "Z" corresponde a 42 + 30h = 5Ah.

## Capturas — Parte 1

Ensamblado y enlazado exitosos, sin errores ni advertencias:

![Ensamblado y enlazado de programa.asm](capturas/parte1-01-compilacion.png)

Ejecución en DOSBox, con la línea de 40 signos "=" después del mensaje final:

![Ejecución de programa.exe en DOSBox](capturas/parte1-02-ejecucion.png)

## Decisiones técnicas — Parte 1

### Decisión 1: `EQU` frente a `%define` para la constante de ancho

Para el ancho de la línea decorativa se selecciona `EQU` (`ANCHO_LINEA EQU 40`) y no `%define`. `EQU` crea un símbolo numérico que el propio ensamblador resuelve y verifica: el valor se evalúa una sola vez y una redefinición del mismo símbolo produce un error en lugar de pasar inadvertida. `%define`, en cambio, es una sustitución de texto que realiza el preprocesador antes de que NASM ensamble una sola instrucción; no entiende de números, solo reemplaza el nombre por el texto tal cual, y admite redefiniciones sin aviso. La diferencia importa porque `ANCHO_LINEA` se usa como argumento de `TIMES` y podría usarse en una comparación aritmética: con `%define ANCHO_LINEA 40+2`, la expresión `ANCHO_LINEA*2` se expandiría a `40+2*2`, es decir 44 por la precedencia de operadores, mientras que con `ANCHO_LINEA EQU 40+2` el símbolo vale 42 y `ANCHO_LINEA*2` da 84. Así, `EQU` evita los errores de sustitución de texto ambigua o mal formada. `%define` sí sería la opción adecuada para un fragmento de texto o de código que no es un valor numérico puro, como un alias de registro (`%define CONTADOR cx`) o una instrucción repetida literalmente (`%define LLAMAR_DOS int 21h`), casos que `EQU`, pensado para valores numéricos, no puede representar.

### Decisión 2: `TIMES` en `.data` frente a `RESB` con relleno en tiempo de ejecución

Para la línea de 40 signos "=" se recomienda `TIMES ANCHO_LINEA DB '='` en `section .data`. Frente a escribir manualmente los 40 caracteres dentro del literal `DB`, `TIMES` permite cambiar el ancho modificando un único número, sin contar caracteres ni arriesgar una línea de 39 o 41 signos. Reservar el mismo espacio con `RESB 40` en `section .bss` y llenarlo con un bucle `LOOP` sería una alternativa válida en principio, porque la salida en pantalla sería idéntica, pero resulta innecesaria aquí: el contenido de la línea es fijo, se conoce al ensamblar y nunca cambia entre una ejecución y la siguiente, por lo que no hay razón para construirlo cada vez; además habría que escribir también en tiempo de ejecución los bytes CR, LF y "$" finales. En el arranque, `TIMES` cuesta cero instrucciones, pues los bytes ya están en la imagen del ejecutable y DOS los carga junto con el programa. `RESB` más bucle exige inicializar CX y el puntero de destino y ejecutar unas 40 iteraciones de al menos tres instrucciones (escribir el byte, avanzar el puntero y `LOOP`), más de cien instrucciones en cada arranque. El costo de `TIMES` es que el archivo `.exe` ocupa algunas decenas de bytes más en disco, un precio mínimo; `RESB` con relleno solo sería preferible para buffers grandes o contenido que dependa de datos en tiempo de ejecución.