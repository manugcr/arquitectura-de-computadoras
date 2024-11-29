# Implementación

<p align="center">
    <img src="../../img/image17.png" alt="Formato de instrucción Tipo J">
</p>


## Etapa de Decodificación (ID) en MIPS

En los procesadores MIPS, la etapa de decodificación (ID) se encarga de interpretar la instrucción obtenida en la etapa de *fetch* (IF). Durante esta etapa, se generan las señales de control necesarias y se preparan los operandos para su ejecución. A continuación, se describen las operaciones clave:

<p align="center">
    <img src="../../img/image26.png" alt="Formato de instrucción Tipo J">
</p>

### 1. Lectura de registros
- Los campos de la instrucción se utilizan para identificar qué registros deben ser leídos.
- El banco de registros lee los valores de los registros fuente especificados en la instrucción.

### 2. Extensión de signo
- Si la instrucción utiliza un operando inmediato (como en las instrucciones de tipo I), el valor inmediato se extiende a 32 bits.
- La extensión mantiene el signo del operando para operaciones aritméticas correctas.

### 3. Shift a la izquierda por 2
- Para instrucciones de salto (como `beq` o `bne`), el offset se desplaza 2 bits a la izquierda.
- Este desplazamiento asegura que la dirección esté alineada a palabras (múltiplos de 4 bytes).

### 4. Cálculo de la dirección de salto (branch)
- En instrucciones condicionales, se calcula la dirección objetivo sumando el valor desplazado del offset al contador de programa (PC).

### 5. Generación de señales de control
- El decodificador identifica el tipo de instrucción (R, I o J).
- Genera las señales necesarias para las etapas siguientes (EX, MEM y WB), como:
  - Tipo de operación aritmética.
  - Acceso a memoria (lectura o escritura).
  - Escritura en registros.

### 6. Comparación para instrucciones de rama
- En instrucciones como `beq` (branch if equal), los valores de los registros fuente se comparan.
- Si son iguales, se toma la rama (branch).







