

<p align="center">
  <a href="https://example.com/">
    <img src="img/image.png" alt="Logo">
  </a>

***TRABAJO PRACTICO 2***

**Titulo:** Maquinas de Estado Finitas - UART

**Asignatura:** Arquitectura de Computadoras

**Integrantes:**
   - Gil Cernich, Manuel 
   - Cabrera, Augusto Gabriel 

---------------
## Enunciado

Implementar una interfaz de comunicación UART para la unidad
aritmético-lógica (ALU) previamente desarrollada (Trabajo Práctico N°1). Esta comunicación serie permitirá proporcionar a la ALU
los operandos y el operador a través del puerto serie (RX), y transmitir el resultado por la misma vía (TX).

<p align="center">
  <a href="https://example.com/">
    <img src="img/image1.png" alt="bloq">
  </a>


## Marco Teorico

### UART (Transmisor-Receptor Asíncrono Universal)

Es un protocolo simple de dos cables utilizado para intercambiar datos en serie.

- **Asíncrono** significa que no hay un reloj compartido entre los dispositivos. Para que el UART funcione correctamente, es necesario que ambos lados de la conexión estén configurados con la misma velocidad de baudios o bits por segundo.
  
- **Bits de inicio y parada**: Se utilizan para indicar dónde comienzan y terminan los datos del usuario, permitiendo «tramar» los datos.

- **Bit de paridad**: Opcionalmente, se puede emplear un bit de paridad para detectar errores en un solo bit.

Aunque el **UART** sigue siendo ampliamente utilizado, en los últimos años ha sido reemplazado en algunas aplicaciones por tecnologías como **SPI**, **I2C**, **USB** y **Ethernet**.


#### Funcionamiento

<p align="center">
  <a href="https://example.com/">
    <img src="img/image2.png" alt="bloq">
  </a>


El protocolo UART funciona de la siguiente manera, tanto para transmitir como para recibir datos:

1. **Detección de transición**: Inicialmente, la línea se encuentra en 1, lo que indica que no hay comunicación. Cuando se desea transmitir, la línea baja a 0 para comenzar la transmisión.

2. **Muestreo de los datos entrantes**: Tras finalizar el tiempo del bit de inicio, se empieza a transmitir el byte completo, comenzando por el **bit de menor peso (LSB)**. Al final, se envía el bit de paridad, que permite verificar si la información transmitida y recibida es correcta.

3. **Muestreo del bit de parada**: Este bit es necesario para indicar que se ha completado la transmisión o recepción de los datos.

El truco de este protocolo es muestrear cada bit justo en la mitad de su período. Esto asegura que no haya ambigüedades en la información. En una **FPGA**, se debe tener cuidado al muestrear, asegurándose de hacerlo justo en el flanco de subida de la señal de muestreo.





### Generación de Ticks


**Baud Rate:** Es la velocidad de transmisión de datos, medida en símbolos por segundo. Por ejemplo, un Baud Rate de 19,200 significa que se transmiten 19,200 símbolos por segundo.


- Para un Baud Rate de 19,200 bps, se necesitan **16 muestras** _(TICKS)_ por cada bit transmitido. Esto se hace para asegurar que se captura la señal en diferentes momentos a lo largo de cada bit, lo que permite una mejor detección de los estados de la señal.

- La frecuencia de muestreo se calcula como:
  - Frecuencia de muestreo = Baud Rate × 16
  - Frecuencia de muestreo = 19,200 bps × 16 = 307,200 ticks por segundo

#### Relación con el Clock de la Placa

- Si el reloj de la placa es de **50 MHz**, significa que el reloj genera **50,000,000 ciclos** por segundo. Para determinar cuántos ciclos de reloj se necesitan para generar un tick, se puede hacer el siguiente cálculo:
  - Ciclos de reloj por tick = Frecuencia del reloj / Frecuencia de muestreo
  - Ciclos de reloj por tick = 50,000,000 Hz / 307,200 ticks por segundo ≈ 163 ciclos de reloj

#### Generador de Baud Rate

- El **Baud Rate Generator** es un contador que cuenta hasta **163** (el número de ciclos de reloj necesarios para generar un tick) y se reinicia. Cuando el contador alcanza este valor, genera un tick (señal de muestreo).

- Este contador puede ser implementado en Verilog o en hardware de otras formas. Cada vez que el contador se reinicia, indica que ha pasado el tiempo necesario para muestrear un bit de datos.

#### RESUMEN:

1. **Baud Rate** de 19,200 bps requiere 16 muestras por bit, lo que resulta en una frecuencia de muestreo de 307,200 ticks por segundo.
2. Con un reloj de 50 MHz, cada tick se genera cada 163 ciclos de reloj.
3. El Baud Rate Generator cuenta hasta 163 para generar los ticks necesarios para la transmisión UART.

Esto asegura que el sistema UART sea capaz de leer y transmitir datos de manera precisa y confiable.








## Implementación

La función principal del módulo de comunicación serie de la PC es TX individualmente los bits de cada byte, y el módulo UART desarrollado se encarga de recibirlos en una cola FIFO de RX , reensamblar los bits para formar nuevamente los bytes completos, y enviar esta información a la ALU. 

Una vez que la ALU realiza la operación, el resultado es enviado a la cola de TX y luego transmitido por el puerto serie a la PC que estará esperando estos datos.

<p align="center">
  <a href="https://example.com/">
    <img src="img/image3.png" alt="bloq">
  </a>


La máquina de estados está representada por un módulo de interfaz entre la ALU y el módulo UART propiamente dicho. El grafo en cuestion es:

<p align="center">
  <a href="https://example.com/">
    <img src="img/image4.png" alt="bloq">
  </a>

  Se podrían agregar los estados **_verify_** y **_error_** (en futuras versiones) para mejorar la gestión del sistema:

 **Estado de Error**:
En algunos sistemas, cuando se detectan errores de paridad o se excede el tiempo de espera (_timeout_) sin recibir datos, es posible definir un estado de error o _timeout_. Este estado se utiliza para gestionar la corrección del error o iniciar un nuevo intento de transmisión.

 **Estado de Verificación (Parity Bit)**:
Si se utiliza paridad, se transmite un bit adicional para verificar la corrección de los datos enviados. Este bit de paridad puede ser par o impar, dependiendo de la configuración establecida, y permite detectar errores en los datos recibidos.


## Código 

### Transmisor UART (`transmitter.v`)

Este transmisor UART envía un byte de datos serialmente, bit por bit, con una secuencia: **bit de inicio**, **bits de datos** y **bit de parada**. La máquina de estados sigue una secuencia de cuatro etapas principales:
1. **Waiting** (Esperando)
2. **Start** (Enviando el bit de inicio)
3. **Data** (Enviando los bits de datos, uno por uno)
4. **Stop** (Enviando el bit de parada)

#### Suposiciones:
- **Parámetros**: 
  - **DBIT = 8** (es decir, 8 bits de datos).
  - **TICKS_END = 16** (es decir, 16 ticks para completar la transmisión de cada bit).
- El dato que se quiere enviar es el byte: `10101100`.

### Ejemplo paso a paso:

#### 1. Estado: Waiting (Esperando)
- El sistema está en reposo, en el estado **Waiting**.
- **Variables iniciales**: 
  - `tx_signal = 1` (línea inactiva, es decir, alta).
  - `tick_counter = 0` (contador de ticks).
  - `bit_counter = 0` (contador de bits de datos).
  - `data_shift_reg = 0` (dato a transmitir).
- **Evento**: Se activa la señal **`tx_go = 1`**, lo que significa que el transmisor va a comenzar a enviar el byte de datos `10101100`.

---

#### 2. Estado: Start (Enviando bit de inicio)
- El sistema pasa al estado **Start** para enviar el **bit de inicio**.
- **Acciones**:
  - Se pone la línea **tx_signal = 0** (bit de inicio = 0).
  - Se inicia el contador de ticks: `tick_counter = 0`.
  - Carga el byte de datos en **`data_shift_reg = 10101100`**.
- **Tick 1 a Tick 16**:
  - Por cada tick de reloj (siempre que **`pulse_tick = 1`**), el **`tick_counter`** se incrementa de 0 a 15.
  - Cuando **`tick_counter = 15`**, ha pasado suficiente tiempo (16 ticks) para transmitir el bit de inicio.
  - **Transición**: El sistema pasa al estado **Data**.

---

#### 3. Estado: Data (Enviando bits de datos)
- Ahora el sistema se encuentra en el estado **Data**, transmitiendo los bits de datos uno a uno.
- **Acciones** (para cada bit):
  - Se envía el bit menos significativo del registro de datos **`data_shift_reg[0]`**.
  - **Bit 1 a enviar**: `data_shift_reg[0] = 0`.
  - **Se pone**: `tx_signal = 0` (el valor del bit menos significativo).
  - Inicia el conteo de ticks para ese bit.
- **Tick 1 a Tick 16**:
  - Por cada tick (siempre que **`pulse_tick = 1`**), el **`tick_counter`** se incrementa de 0 a 15.
  - Después de 16 ticks (cuando **`tick_counter = 15`**), se completa la transmisión del bit.
  - **Acciones adicionales**:
    - **Se desplaza** el registro de datos a la derecha: `data_shift_reg = data_shift_reg >> 1`.
    - **Incrementa el contador de bits**: `bit_counter = bit_counter + 1`.
- Este proceso se repite para cada uno de los 8 bits de datos, transmitiéndose de la siguiente manera:
  - Bit 1 (`data_shift_reg[0] = 0`) → **tx_signal = 0**
  - Bit 2 (`data_shift_reg[0] = 0`) → **tx_signal = 0**
  - Bit 3 (`data_shift_reg[0] = 1`) → **tx_signal = 1**
  - Bit 4 (`data_shift_reg[0] = 1`) → **tx_signal = 1**
  - Bit 5 (`data_shift_reg[0] = 0`) → **tx_signal = 0**
  - Bit 6 (`data_shift_reg[0] = 1`) → **tx_signal = 1**
  - Bit 7 (`data_shift_reg[0] = 0`) → **tx_signal = 0**
  - Bit 8 (`data_shift_reg[0] = 1`) → **tx_signal = 1**
- **Transición**: Cuando se han transmitido los 8 bits de datos (es decir, cuando **`bit_counter = DBIT - 1`**), el sistema pasa al estado **Stop**.

---

#### 4. Estado: Stop (Enviando bit de parada)
- Después de transmitir los 8 bits de datos, el sistema entra en el estado **Stop** para enviar el **bit de parada**.
- **Acciones**:
  - Se coloca la línea de transmisión **tx_signal = 1** (bit de parada = 1).
  - Inicia de nuevo el contador de ticks: **tick_counter = 0**.
- **Tick 1 a Tick 16**:
  - Por cada tick (siempre que **`pulse_tick = 1`**), el **`tick_counter`** se incrementa de 0 a 15.
  - Cuando **`tick_counter = 15`**, ha pasado suficiente tiempo (16 ticks) para transmitir el bit de parada.
  - **Transición**: El sistema vuelve al estado **Waiting** y levanta la señal **`tx_done_tick = 1`** para indicar que la transmisión ha finalizado.

---

#### Resumen visual del flujo de estados y ticks:
1. **Waiting**: Espera a que **`tx_go = 1`**.
2. **Start**: 
   - Envía **bit de inicio** (`tx_signal = 0`).
   - Espera 16 ticks.
3. **Data**: 
   - Envía **bit de datos** (`tx_signal = data_shift_reg[0]`).
   - Repite por 8 bits, esperando 16 ticks por cada bit.
4. **Stop**: 
   - Envía **bit de parada** (`tx_signal = 1`).
   - Espera 16 ticks.
5. **Waiting**: Termina la transmisión y espera la siguiente.

---

#### Secuencia del byte `10101100`:
- **Bit de inicio (start)**: 0.
- **Bits de datos (data)**: 0, 0, 1, 1, 0, 1, 0, 1.
- **Bit de parada (stop)**: 1.

Cada bit (incluido el de inicio y el de parada) toma 16 ticks en total para ser enviado.





### FIFO  (`fifo.v`)



#### Parámetros del Módulo
- **`B`**: Número de bits en una palabra que se almacenará en el FIFO (8 bits por defecto).
- **`W`**: Número de bits de dirección, que determina el tamaño del FIFO (el tamaño será \(2^W\) palabras, es decir, 16 palabras por defecto).

#### Entradas y Salidas
- **Entradas**:
  - **`clk`**: Señal de reloj que sincroniza el funcionamiento del FIFO.
  - **`reset`**: Señal para restablecer el FIFO a su estado inicial.
  - **`rd`**: Señal para indicar si se desea leer del FIFO.
  - **`wr`**: Señal para indicar si se desea escribir en el FIFO.
  - **`write_data`**: Datos que se desean escribir en el FIFO.

- **Salidas**:
  - **`empty`**: Indica si el FIFO está vacío.
  - **`full`**: Indica si el FIFO está lleno.
  - **`read_data`**: Datos leídos del FIFO.

#### Variables Internas
- **`array_reg`**: Arreglo que almacena los datos en el FIFO.
- **`w_ptr_reg`, `w_ptr_next`, `w_ptr_succ`**: Puntero de escritura actual, próximo y siguiente.
- **`r_ptr_reg`, `r_ptr_next`, `r_ptr_succ`**: Puntero de lectura actual, próximo y siguiente.
- **`full_reg`, `empty_reg`**: Indicadores de estado del FIFO (si está lleno o vacío).
- **`full_next`, `empty_next`**: Valores para los estados en el siguiente ciclo.
- **`wr_en`**: Señal de habilitación de escritura.

#### Comportamiento del FIFO
1. **Escritura en el FIFO**:
   - En cada flanco positivo del reloj (`posedge clk`), si `wr_en` es verdadero (lo que significa que la señal de escritura `wr` es alta y el FIFO no está lleno), se escriben los `write_data` en la posición actual del puntero de escritura (`w_ptr_reg`).
   
2. **Lectura del FIFO**:
   - La señal de salida `read_data` se asigna al valor de `array_reg` en la posición actual del puntero de lectura (`r_ptr_reg`).

3. **Control de Punteros y Estado**:
   - En el bloque `always @(posedge clk)`, se gestionan los punteros y los estados del FIFO. Si se activa la señal de `reset`, se inicializan los punteros y los estados del FIFO.
   - De lo contrario, los punteros y los estados se actualizan según la lógica de estado siguiente.

4. **Lógica de Siguiente Estado**:
   - En el bloque `always @*`, se determina el próximo estado de los punteros de lectura y escritura según las señales de control (`wr` y `rd`).
   - Dependiendo de las combinaciones de señales (NO_OP, READ, WRITE, READ_WRITE), se actualizan los punteros y los estados del FIFO.
   - La lógica asegura que no se sobrescriban datos en el FIFO si está lleno y que no se intente leer datos si está vacío.

#### Salidas del FIFO
- Las salidas `full` y `empty` se asignan a los registros de estado correspondientes (`full_reg` y `empty_reg`), que reflejan el estado actual del FIFO.



### Ejemplo de Ejecución del FIFO

Este documento ilustra cómo funciona un FIFO en términos de bits, mostrando las operaciones de escritura y lectura.


#### 1. Inicialización
- Estado inicial:
  - `empty = 1` (FIFO está vacío)
  - `full = 0` (FIFO no está lleno)

#### 2. Escritura de Datos
- **Escribir `0xAA` (10101010 en binario)**:
  - `wr = 1`, `write_data = 8'b10101010`
  - Puntero de escritura (`w_ptr`) avanza de `0` a `1`
  - Estado:
    - Datos en FIFO: `[10101010, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _]`
    - `empty = 0`, `full = 0`
  
- **Escribir `0xBB` (10111011 en binario)**:
  - `write_data = 8'b10111011`
  - `wr = 1` (continúa escribiendo)
  - Puntero de escritura (`w_ptr`) avanza de `1` a `2`
  - Estado:
    - Datos en FIFO: `[10101010, 10111011, _, _, _, _, _, _, _, _, _, _, _, _, _, _]`
    - `empty = 0`, `full = 0`

- **Escribir `0xCC` (11001100 en binario)**:
  - `write_data = 8'b11001100`
  - `wr = 1` (continúa escribiendo)
  - Puntero de escritura (`w_ptr`) avanza de `2` a `3`
  - Estado:
    - Datos en FIFO: `[10101010, 10111011, 11001100, _, _, _, _, _, _, _, _, _, _, _, _, _]`
    - `empty = 0`, `full = 0`

#### 3. Lectura de Datos
- **Leer un dato**:
  - `rd = 1` (activar lectura)
  - Puntero de lectura (`r_ptr`) avanza de `0` a `1`
  - Dato leído: `0xAA` (10101010)
  - Estado:
    - Datos en FIFO: `[_, 10111011, 11001100, _, _, _, _, _, _, _, _, _, _, _, _, _]`
    - `empty = 0`, `full = 0`

- **Leer el siguiente dato**:
  - `rd = 1` (activar lectura)
  - Puntero de lectura (`r_ptr`) avanza de `1` a `2`
  - Dato leído: `0xBB` (10111011)
  - Estado:
    - Datos en FIFO: `[_, _, 11001100, _, _, _, _, _, _, _, _, _, _, _, _, _]`
    - `empty = 0`, `full = 0`

- **Leer el siguiente dato**:
  - `rd = 1` (activar lectura)
  - Puntero de lectura (`r_ptr`) avanza de `2` a `3`
  - Dato leído: `0xCC` (11001100)
  - Estado:
    - Datos en FIFO: `[_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _]`
    - `empty = 1` (FIFO está vacío), `full = 0`

#### Resumen de la Ejecución
- **Escritura**:
  - `w_ptr` avanza al escribir datos: de `0` a `1` a `2` a `3`.
  - Se escribieron tres datos: `0xAA`, `0xBB`, `0xCC`.

- **Lectura**:
  - `r_ptr` avanza al leer datos: de `0` a `1` a `2` a `3`.
  - Se leyeron los mismos tres datos en el mismo orden que se escribieron.





### Baud Rate `baud_rate.v`


1. **Parámetros:**
   - `N=8`: Esto significa que el contador se representa con 8 bits. Con 8 bits, puedes contar hasta 2^8 - 1 = 255, que es suficiente para contar hasta 163.
   - `M=163`: Este es el valor máximo que el contador alcanzará antes de reiniciarse. En este caso, el contador se reiniciará después de contar 163 ciclos de reloj.

2. **Entradas y Salidas:**
   - `clk`: La señal de reloj que controla el funcionamiento del contador.
   - `reset`: Una señal que reinicia el contador a 0.
   - `tick`: Indica cuándo se ha generado un tick. Esta señal se activa (1) cuando el contador alcanza 163.
   - `q`: Muestra el valor actual del contador.

3. **Registro y Lógica del Contador:**
   - `r_reg`: Un registro que almacena el valor actual del contador.
   - `r_next`: Una señal que representa el siguiente estado del contador.
   - En la lógica del registro, el contador se incrementa en cada flanco ascendente del reloj (`posedge clk`).
   - Si la señal de reset está activa, se reinicia el contador a 0.
   - Si el contador alcanza 162 (es decir, `M-1`), se reinicia a 0; de lo contrario, se incrementa en 1.

4. **Generación del Tick:**
   - La señal `tick` se activa cuando el contador alcanza 163, indicando que ha pasado el tiempo necesario para muestrear un bit de datos.

#### Cálculos para la Generación de Ticks

1. **Frecuencia de Baud Rate:**
   - **Baud Rate:** 19,200 bps (bits por segundo).
   - **Muestras por bit:** 16.
   - **Frecuencia de muestreo:** 
     - Frecuencia de muestreo = Baud Rate × Muestras por bit = 19,200 bps × 16 = 307,200 ticks por segundo.

2. **Frecuencia del Reloj:**
   - **Frecuencia del reloj de la placa:** 50 MHz, que equivale a 50,000,000 ciclos por segundo.

3. **Ciclos de reloj por tick:**
   - Para determinar cuántos ciclos de reloj se necesitan para generar un tick, utilizamos la siguiente fórmula:
     - Ciclos de reloj por tick = Frecuencia del reloj / Frecuencia de muestreo = 50,000,000 Hz / 307,200 ticks/segundo ≈ 163 ciclos de reloj.

#### Resumen
- Este contador está diseñado para contar hasta 163 ciclos de reloj y luego reiniciarse, generando una señal de tick cada vez que se alcanza este valor.
- La relación entre la frecuencia del reloj de la placa y la frecuencia de muestreo garantiza que los datos se muestreen correctamente para el Baud Rate deseado, asegurando la precisión y confiabilidad en la transmisión de datos en el sistema UART.
