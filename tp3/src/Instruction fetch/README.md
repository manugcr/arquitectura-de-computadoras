
# Implementación

<p align="center">
    <img src="../../img/image17.png" alt="Formato de instrucción Tipo J">
</p>

## Construcción de un camino de datos

La memoria de instrucciones
es solo de lectura, ya que el camino de datos nunca escribe instrucciones, y se trata como un elemento de
lógica combinacional. La salida en cualquier instante refleja el contenido de la localización especificada por
la dirección de entrada, y no se necesita ninguna señal de control de lectura (sólo se necesitará escribir en la
memoria de las instrucciones cuando se cargue el programa). El contador de programa es un registro de 32 bits que se modifica al final de cada ciclo de
reloj y, de esta manera, no necesita ninguna señal de control de escritura. El sumador es una ALU cableada
para que sume siempre dos entradas de 32 bits y dé el resultado en su salida.

<p align="center">
    <img src="../../img/image18.png" alt="Formato de instrucción Tipo J">
</p>

### Program Counter

Todas las
instrucciones comienzan utilizando el contador de programa (PC) para proporcionar la dirección de la
instrucción en la memoria de instrucciones. Los saltos condicionales requieren el uso de la salida de la
ALU para determinar la dirección de la siguiente instrucción, que proviene de la ALU (donde se suma el PC y
el desplazamiento) o desde un sumador que incrementa el valor actual del PC en 4. El valor
escrito en el PC puede provenir de cualquiera de los dos sumadores, el dato
escrito en el banco de registros puede provenir de la ALU o de la memoria de
datos, y la segunda entrada de la ALU proviene de un registro o del campo inmediato
de la instrucción. En la práctica, estas líneas de datos no pueden conectarse
directamente

<p align="center">
    <img src="img/image19.png" alt="Formato de instrucción Tipo J">
</p>

### Memoria de Instrucciones

La memoria de instrucciones
es solo de lectura, ya que el camino de datos nunca escribe instrucciones, y se trata como un elemento de
lógica combinacional. La salida en cualquier instante refleja el contenido de la localización especificada por
la dirección de entrada, y no se necesita ninguna señal de control de lectura (sólo se necesitará escribir en la
memoria de las instrucciones cuando se cargue el programa; esto no es difícil de añadir, por lo que se ignora
para simplificar). El contador de programa es un registro de 32 bits que se modifica al final de cada ciclo de
reloj y, de esta manera, no necesita ninguna señal de control de escritura. El sumador es una ALU cableada
para que sume siempre dos entradas de 32 bits y dé el resultado en su salida.

<p align="center">
    <img src="../../img/image20.png" alt="Formato de instrucción Tipo J">
</p>

El módulo implementa una memoria de instrucciones con capacidad para escribir, leer y gestionar su estado (vacía o llena).

Cuando **`i_reset`** o **`i_clear`** están activos, la memoria y el puntero se reinician, dejando la memoria en un estado limpio.

Si **`i_inst_write`** está activo, la instrucción proporcionada en **`i_instruction`** se escribe en la memoria en la posición indicada por **`pointer`**, y el puntero incrementa su valor en 4 bytes (una instrucción).

La instrucción almacenada en la posición especificada por **`i_pc`** se envía como salida a través de **`o_instruction`**.

- **`o_full_mem`**: Indica que la memoria está llena cuando el puntero alcanza la dirección máxima.
- **`o_empty_mem`**: Indica que la memoria está vacía cuando el puntero está en 0.

--- 
#### Ejemplo práctico

<p align="center">
    <img src="../../img/image21.png" alt="b">
</p>

Supongamos que estamos trabajando con una memoria de 10 palabras y queremos cargar y leer algunas instrucciones.

#### Paso 1: Escribir una instrucción

#### Condiciones iniciales:
- `i_reset = 1`: Se reinicia la memoria, por lo que `memory = 0` y `pointer = 0`.

#### Primera instrucción:
- `i_inst_write = 1`: Habilitamos la escritura.
- `i_instruction = 32'b10101010101010101010101010101010`: Queremos escribir esta instrucción.
- En el siguiente flanco positivo del reloj (`posedge i_clk`), la instrucción se almacena en los bits `[0:31]` de `memory`, y el `pointer` se incrementa a 4.


#### Paso 2: Escribir otra instrucción

#### Segunda instrucción:
- `i_instruction = 32'b11110000111100001111000011110000`: Queremos escribir esta instrucción.
- En el siguiente flanco del reloj, se escribe en los bits `[32:63]` de `memory`, y el `pointer` ahora es 8.


#### Paso 3: Leer una instrucción

- Supongamos que `i_pc = 1` (en bytes, equivale a la dirección 4).
- La instrucción leída será la que está almacenada en los bits `[32:63]`, es decir, `32'b11110000111100001111000011110000`.

#### Paso 4: Indicadores

- Si escribimos 10 palabras (320 bits), el `pointer` alcanzará 40 bytes (`MAX_POINTER_DIR`) y `o_full_mem` será `1`.
- Si el `pointer` está en `0`, `o_empty_mem` será `1`.

## Multiplexor

<div style="display: flex; align-items: center; gap: 10px;">
    <img src="../../img/image22.png" alt="b" style="width: 200px; height: auto;">
    <p>
        El valor escrito en el PC puede provenir de cualquiera de los dos sumadores, el dato
        escrito en el banco de registros puede provenir de la ALU o de la memoria de
        datos, y la segunda entrada de la ALU proviene de un registro o del campo inmediato
        de la instrucción. En la práctica, estas líneas de datos no pueden conectarse
        directamente; debe añadirse un elemento que seleccione entre los múltiples orígenes
        y dirija una de estas fuentes al destino. Esta selección se realiza comúnmente
        mediante un dispositivo denominado multiplexor.
    </p>
</div>

## Sumador

<div style="display: flex; align-items: center; gap: 10px;">
 <img src="../../img/image23.png" alt="b" style="width: 200px; height: auto;">
    <p>
        Se necesita un sumador encargado de incrementar el PC
        para que apunte a la dirección de la siguiente instrucción. Este sumador, que es
        combinacional, se puede construir a partir de la ALU.
    </p>
   
</div>
