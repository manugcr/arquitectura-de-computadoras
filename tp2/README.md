

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













## Implementación

La función principal del módulo de comunicación serie de la PC es TX individualmente los bits de cada byte, y el módulo UART desarrollado se encarga de recibirlos en una cola FIFO de RX , reensamblar los bits para formar nuevamente los bytes completos, y enviar esta información a la ALU. 

Una vez que la ALU realiza la operación, el resultado es enviado a la cola de TX y luego transmitido por el puerto serie a la PC que estará esperando estos datos.

<p align="center">
  <a href="https://example.com/">
    <img src="img/image3.png" alt="bloq">
  </a>


La máquina de estados está representada por un módulo de interfaz entre la ALU y el módulo UART propiamente dicho.
