# Trabajo práctico 1

## Cómo compilar el código  
Para compilar el código con la implementación de `my_qsort` en C, ejecutar `bash build_c`  
Para compilar con la implementación en ASM, ejecutar `bash build_asm`  

## Cómo correr los tests  
Ejecutar `./test/test`. Esto compila automaticamente y corre los tests que estén declarados

## Cómo agregar tests  
Agregar al archivo `./test/test` una función cuyo nombre empiece con `TEST_`.  
Para ejecutar el programa dentro de la función, llamar a la función `exec_program` y pasarle los argumentos necesarios.  
La función de test debe devolver "OK" si pasa o "FAILED" si falla.
