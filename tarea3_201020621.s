//diferencia de arreglos el burbuja recorre i y j arrastra el numero mas grande al final
//por selección recorremos la lista completa y empieza por el pequeño hasta terminar con el grande
.data
.align 3
mensaje1:     .ascii "Tarea 3\n"
len1 = . - mensaje1

mensaje2:     .ascii "Yesus Rudy Espinoza Pivaral 201020621 \n"
len2 = . - mensaje2

mensaje3:     .ascii "Auxiliar: Diego Josue Guevarra\n"
len3 = . - mensaje3

.align 3
// Arreglo de prueba de 10 elementos de 64 bits (8 bytes cada uno)
arreglo:    .quad   65, 27, 89, 13, 99, 33, 77, 44, 66, 12

// Mensajes para impresión por consola mediante sys_write
msg_antes_ordenar:  .ascii  "\nArreglo antes de ordenar: "
len_antes_ordenar = . - msg_antes_ordenar

msg_despues_burbuja:.ascii  "\nOrdenamiento Burbuja: "
len_despues_burbuja = . - msg_despues_burbuja

msg_despues_sel:    .ascii  "\nOrdenamiento por Seleccion: "
len_despues_sel = . - msg_despues_sel

msg_explicacion:    .ascii  "\nparece lo mismo para no lo es el burbuja empieza por el grande y de selección por el pequeño "
len_explicacion = . - msg_explicacion


msg_espacio:.ascii  " "
msg_coma:   .ascii  ", "
msg_newline:.ascii  "\n"

.section .bss
.align 3
// Búfer en RAM para procesar temporalmente los dígitos de los números a ASCII
arreglo_ascii: .space 24

.section .text
.global _start

//esto es como el main
_start:
    // Imprimir mensaje 1 (solo dice tarea3)
    mov     x0, #1
    ldr     x1, =mensaje1
    mov     x2, #len1
    mov     x8, #64         
    svc     #0
    
    // Imprimir mensaje 2 (Nombre y Carnet)
    mov     x0, #1
    ldr     x1, =mensaje2
    mov     x2, #len2
    mov     x8, #64         
    svc     #0

    // Imprimir mensaje 3 (Nombre del Auxiliar)
    mov     x0, #1
    ldr     x1, =mensaje3
    mov     x2, #len3
    mov     x8, #64         
    svc     #0

    // Escribimos mensaje "arreglo antes de ordenar"
    mov     x0, #1                  
    ldr     x1, =msg_antes_ordenar          // Dirección del prefijo
    mov     x2, #len_antes_ordenar          // Tamaño de la cadena
    mov     x8, #64                 // escribir
    svc     #0                  

    // Usamos la instrucción ldr para obtener la dirección del arreglo de 10 elementos
    ldr     x0, =arreglo            // Parámetro 1: Dirección base del arreglo
    mov     x1, #10                 // Parámetro 2: Cantidad de enteros (10)
    bl      imprimir_vector_arreglo // Salto y enlace a la función de impresión

    // llamamos a la funcion Ordenamiento_Burbuja
    ldr     x0, =arreglo            // Dirección del arreglo a ordenar
    mov     x1, #10                 // Tamaño N del arreglo en este caso es 10
    bl      Ordenamiento_Burbuja    // Ejecuta el algoritmo de Ordenamiento_Burbuja

    // Muestro el arreglo después de ordenarse por Burbuja
    mov     x0, #1                  
    ldr     x1, =msg_despues_burbuja
    mov     x2, #len_despues_burbuja
    mov     x8, #64                 
    svc     #0                      

    ldr     x0, =arreglo            // Dirección base de los datos ordenados
    mov     x1, #10                 
    bl      imprimir_vector_arreglo // Imprime la lista ordenada por Burbuja

 

    //meensaje explicativo
    mov     x0, #1                  
    ldr     x1, =msg_explicacion          // Dirección del prefijo
    mov     x2, #len_explicacion          // Tamaño de la cadena
    mov     x8, #64                 // escribir
    svc     #0        


      // Ejecutamos el ordenamiento por selección
    ldr     x0, =arreglo            
    mov     x1, #10                 
    bl      Ordenamiento_por_Seleccion  //llamamos a la función

    // Muestro el arreglo después de ordenarse por Selección
    mov     x0, #1                  
    ldr     x1, =msg_despues_sel        
    mov     x2, #len_despues_sel        
    mov     x8, #64                 
    svc     #0                      

    ldr     x0, =arreglo            
    mov     x1, #10                 
    bl      imprimir_vector_arreglo // Imprime la lista ordenada final por Selección

    // Salto de línea final estético
    mov     x0, #1
    ldr     x1, =msg_newline
    mov     x2, #1
    mov     x8, #64
    svc     #0

    // Cierre limpio del flujo de ejecución de Linux ARM64 puro
    mov     x0, #0                   // Código de retorno exitoso
    mov     x8, #93                 // Syscall 93 = sys_exit
    svc     #0                      

//función ordenamiento burbuja
Ordenamiento_Burbuja:
    // Resguardo obligatorio del contexto en el Stack Frame (Capítulo 3)
    stp     x29, x30, [sp, #-48]!   // Reserva espacio y guarda Frame Pointer y Link Register
    mov     x29, sp                 // Define el nuevo marco de pila actual
    stp     x19, x20, [sp, #16]     // Salvaguarda X19 y X20 (Callee-saved)
    stp     x21, x22, [sp, #32]     // Salvaguarda X21 y X22 (Callee-saved)

    mov     x19, x0                 // X19 = Dirección del arreglo en memoria
    mov     x20, x1                 // X20 = Cantidad total de elementos (N)

    // Ciclo externo (i = 0 hasta N - 1)
    mov     x21, #0                 // X21 = Contador externo 'i' asignado en 0
.L_burburja_externo:
    sub     x2, x20, #1             // X2 = N - 1
    cmp     x21, x2                 // Evalúa si 'i' alcanzó el límite de pasadas
    b.ge    .L_BurbujaFinal           // Si i >= N - 1, con esto ya se ordena el arreglo

    // Ciclo interno (j = 0 hasta N - i - 1)
    mov     x22, #0                 // X22 = Contador interno 'j' asignado en 0
.L_burbuja_interno:
    sub     x2, x20, x21            // X2 = N - i
    sub     x2, x2, #1              // X2 = N - i - 1
    cmp     x22, x2                 // Evalúa si 'j' llegó al final de la pasada actual
    b.ge    .L_burbuja_externo_inc     // Si j >= N - i - 1, salta a incrementar 'i'

    // Cálculo indexado para enteros de 64 bits (8 bytes por celda de memoria)
    lsl     x3, x22, #3             // X3 = j * 8 bytes (Desplazamiento relativo)
    add     x4, x19, x3             // X4 = Dirección física exacta de arr[j]
    ldr     x5, [x4]                // X5 = Carga el valor actual de arr[j]
    ldr     x6, [x4, #8]            // X6 = Carga el valor adyacente de arr[j+1]

    // Comparación condicional para evaluar intercambio in-place
    cmp     x5, x6                  // Compara aritméticamente arr[j] con arr[j+1]
    b.le    .L_burbuja_interno_inc     // Si arr[j] <= arr[j+1], el orden es correcto; no intercambia

    // Intercambio de valores directamente en las celdas contiguas de la RAM
    str     x6, [x4]                // Escribe el valor menor en la posición inicial arr[j]
    str     x5, [x4, #8]            // Escribe el valor mayor en la posición adelante arr[j+1]

.L_burbuja_interno_inc:
    add     x22, x22, #1            // j++ (Avanza al siguiente par de elementos)
    b       .L_burbuja_interno        // Reitera el ciclo interno

.L_burbuja_externo_inc:
    add     x21, x21, #1            // i++ (Avanza a la siguiente pasada general)
    b       .L_burburja_externo       // Reitera el ciclo externo

.L_BurbujaFinal:
    // Recuperación de registros desde el Stack Frame antes de retornar
    ldp     x19, x20, [sp, #16]     // Restaura valores originales de X19 y X20
    ldp     x21, x22, [sp, #32]     // Restaura valores originales de X21 y X22
    ldp     x29, x30, [sp], #48     // Libera el marco de pila y recupera FP y LR
    ret                             // Retorna formalmente al flujo principal

// =============================================================================
// FUNCIÓN MODULAR: SELECTION SORT (ORDENAMIENTO POR SELECCIÓN)
// =============================================================================
Ordenamiento_por_Seleccion:
    // Resguardo obligatorio del contexto extendido en el Stack (Capítulo 3 y 4)
    stp     x29, x30, [sp, #-64]!   // Guarda FP y LR y desplaza el puntero sp
    mov     x29, sp                 // Establece el inicio del nuevo marco
    stp     x19, x20, [sp, #16]     // Resguarda variables de base
    stp     x21, x22, [sp, #32]     // Resguarda contadores de ciclo
    stp     x23, x24, [sp, #48]     // Resguarda registros temporales de datos

    mov     x19, x0                 // X19 = Dirección base del arreglo
    mov     x20, x1                 // X20 = Tamaño total del arreglo (N)

    mov     x21, #0                 // X21 = Contador externo 'i' en 0
.L_sel_outer:
    sub     x2, x20, #1             // X2 = N - 1
    cmp     x21, x2                 // evaluaa si completó las pasadas necesarias
    b.ge    .L_sel_end              // Si i >= N - 1, termina el algoritmo

    mov     x22, x21                // X22 = min_idx inicializado con el valor de 'i'

    add     x23, x21, #1            // X23 = Contador interno 'j' = i + 1
.L_sel_inner:
    cmp     x23, x20                // Compara 'j' contra N
    b.ge    .L_sel_swap             // Si j >= N, se completó la pasada interna; va al swap

    // Carga de elementos usando direccionamiento indexado (Tabla 3.4)
    lsl     x2, x23, #3             // j * 8 bytes
    ldr     x24, [x19, x2]          // X24 = Valor de arr[j]

    lsl     x2, x22, #3             // min_idx * 8 bytes
    ldr     x5, [x19, x2]           // X5 = Valor de arr[min_idx]

    cmp     x24, x5                 // Compara aritméticamente arr[j] con arr[min_idx]
    b.ge    .L_sel_inner_inc        // Si arr[j] >= arr[min_idx], el mínimo se mantiene

mov     x22, x23                // Si es menor, actualiza el índice mínimo min_idx = j
.L_sel_inner_inc:
add     x23, x23, #1            // j++
b       .L_sel_inner            // Reitera el ciclo interno

.L_sel_swap:
cmp     x22, x21                // Verifica si el índice mínimo cambió de lugar
b.eq    .L_sel_outer_inc        // Si min_idx == i, no hay nada que intercambiar

// Intercambio físico de celdas contiguas de 64 bits en la RAM
lsl     x2, x21, #3             // i * 8
add     x3, x19, x2             // Dirección física de arr[i]
ldr     x4, [x3]                // Guarda valor viejo de arr[i]

lsl     x2, x22, #3             // min_idx * 8
add     x5, x19, x2             // Dirección física de arr[min_idx]
ldr     x6, [x5]                // Guarda valor mínimo de arr[min_idx]

str     x6, [x3]                // Coloca el mínimo en la posición arr[i]
str     x4, [x5]                // Mueve el valor viejo a la posición arr[min_idx]

.L_sel_outer_inc:
add     x21, x21, #1            // i++
b       .L_sel_outer            // Reitera el ciclo externo

.L_sel_end:
// Recuperación limpia del contexto desde el Stack Frame
ldp     x19, x20, [sp, #16]
ldp     x21, x22, [sp, #32]
ldp     x23, x24, [sp, #48]
ldp     x29, x30, [sp], #64     // Libera espacio y restaura FP y LR
ret                             

//funciones necesarias para imprimir los enteros en pantalla 
imprimir_vector_arreglo:
stp     x29, x30, [sp, #-48]!   // Resguarda el marco de llamada
mov     x29, sp
stp     x19, x20, [sp, #16]     // Protege los punteros originales pasados
stp     x21, x22, [sp, #32]

mov     x19, x0                 // X19 = Almacena dirección de los datos
mov     x20, x1                 // X20 = Almacena tamaño del arreglo N
mov     x21, #0                 // X21 = Índice iterador de la impresión en 0

.L_print_loop:
cmp     x21, x20                // Compara el índice actual contra N
b.ge    .L_print_end            // Si imprimió los 10 elementos, finaliza la rutina

// Condicional para omitir la coma decorativa únicamente en el primer elemento
cmp     x21, #0
b.eq    .L_print_num            // Si es la posición 0, va directo a procesar el número
mov     x0, #1                  // Destino: Pantalla
ldr     x1, =msg_coma           // Dirección del texto ", "
mov     x2, #2                  // Longitud (2 bytes)
mov     x8, #64                 // Syscall sys_write
svc     #0                      // Imprime la coma

.L_print_num:
// Carga el entero de 64 bits para pasarlo como argumento
lsl     x2, x21, #3             // Índice actual * 8 bytes de tamaño
ldr     x0, [x19, x2]           // X0 = Carga el número puro de la memoria RAM
bl      int_to_ascii            // Salta a transformarlo y plasmarlo en pantalla

add     x21, x21, #1            // Incrementa el índice de impresión con alineación
b       .L_print_loop           // Sigue con el próximo ciclo de impresión

.L_print_end:
ldp     x19, x20, [sp, #16]
ldp     x21, x22, [sp, #32]
ldp     x29, x30, [sp], #48     // Libera el marco de pila
ret

//convertimos entero a texto de salida ascii, las recicle de la practica
int_to_ascii:
ldr     x1, =arreglo_ascii      // Obtiene la dirección base de nuestro espacio estático
add     x1, x1, #20             // Apunta al final de la memoria asignada
mov     x2, #10              
mov     x6, #0                  

.L_ascii_loop:
udiv    x3, x0, x2              // Divide el entero entre 10 para extraer cociente
msub    x4, x3, x2, x0          // Resta el producto para aislar el residuo del dígito
add     x4, x4, #48             // se suma 48 es por lo del ascii los numero van del 48 al 57

sub     x1, x1, #1              // Desplaza el puntero de memoria una posición atrás
strb    w4, [x1]                // Almacena un byte en la celda calculada
add     x6, x6, #1              // Registra un carácter extra en el contador

mov     x0, x3                  // Reasigna el cociente como el nuevo número a procesar
cbnz    x0, .L_ascii_loop       // Si el cociente es distinto de cero, reitera el procesamiento

// esta la nueva para llevar la el contador de la cantidad de caracteres
// Realiza la llamada al sistema operativo para vaciar las letras calculadas en pantalla
mov     x0, #1                  
mov     x2, x6                  // Cantidad exacta de caracteres generados en el bucle
mov     x8, #64                 // sys_write de Linux
svc     #0                      // a
ret