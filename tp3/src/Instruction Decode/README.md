# Implementación

<p align="center">
    <img src="../../img/image17.png" alt="Formato de instrucción Tipo J">
</p>


# Etapa de Decodificación (ID) en MIPS

En los procesadores MIPS, la etapa de decodificación (ID) se encarga de interpretar la instrucción obtenida en la etapa de *fetch* (IF). Durante esta etapa, se generan las señales de control necesarias y se preparan los operandos para su ejecución. A continuación, se describen las operaciones clave:

<p align="center">
    <img src="../../img/image26.png" alt="Formato de instrucción Tipo J">
</p>

## 1. Lectura de registros
- Los campos de la instrucción se utilizan para identificar qué registros deben ser leídos.
- El banco de registros lee los valores de los registros fuente especificados en la instrucción.

### Funcionamiento


El módulo `registers` implementa un banco de registros configurable, permitiendo realizar operaciones de lectura, escritura y reinicio (reset/flush). A continuación, se describe cómo funciona:


#### Escritura en Registros
- La escritura está controlada por la señal `i_write_enable`.
- Para escribir un valor en un registro:
  - Indicas la dirección del registro con `i_addr_wr`.
  - Especificas el dato a escribir con `i_bus_wr`.
- Ejemplo:
  - Si `i_addr_wr = 3` e `i_bus_wr = 16'hA5A5`, se almacenará el valor `A5A5` en el registro **3**.
- ****NOTA:** El registro 0 no puede ser modificado; siempre permanecerá en 0.**



####  Lectura de Registros
- Puedes leer dos registros simultáneamente:
  - Indica las direcciones de los registros que deseas leer con `i_addr_A` y `i_addr_B`.
  - Los valores de los registros seleccionados estarán disponibles en las salidas `o_bus_A` y `o_bus_B`.
- Ejemplo:
  - Si `i_addr_A = 3`, `o_bus_A` mostrará el valor almacenado en el registro **3**.
  - Si `i_addr_B = 5`, `o_bus_B` mostrará el valor almacenado en el registro **5**.



#### Limpieza de Registros (Flush)
- Activando la señal `i_flush`, todos los registros (excepto el registro 0) se limpian automáticamente y se colocan en **0**.
- Esta operación es útil para reiniciar el estado del banco de registros sin realizar un reinicio completo (`i_reset`).



#### Depuración (Debugging)
- El bus de salida `o_bus_debug` permite inspeccionar el contenido de **todos los registros** en cualquier momento.
- Es útil para pruebas y simulaciones, ya que proporciona una vista completa del estado interno del banco.



#### Secuencia Típica de Operación
1. **Inicio:** Activa la señal `i_reset` para inicializar los registros.
2. **Escritura:**
   - Activa `i_write_enable`.
   - Especifica la dirección (`i_addr_wr`) y el dato (`i_bus_wr`) para escribir en un registro.
3. **Lectura:**
   - Especifica las direcciones de los registros a leer con `i_addr_A` y `i_addr_B`.
   - Observa los valores en `o_bus_A` y `o_bus_B`.
4. **Limpieza:** Activa `i_flush` para limpiar todos los registros (excepto el registro 0).
5. **Depuración:** Inspecciona el estado completo del banco de registros a través de `o_bus_debug`.



#### Ejemplo de Operaciones

1. **Escribir un valor:**
   - Dirección: `i_addr_wr = 3`
   - Valor: `i_bus_wr = 16'hA5A5`
   - Resultado: El registro 3 contendrá el valor `A5A5`.

2. **Leer registros:**
   - Dirección de lectura: `i_addr_A = 3`, `i_addr_B = 5`
   - Salidas: `o_bus_A` mostrará el valor del registro 3, y `o_bus_B` el del registro 5.

3. **Aplicar un flush:**
   - Activar `i_flush`.
   - Resultado: Todos los registros, excepto el registro 0, se limpian a **0**.




## 2. Extensión de signo
- Si la instrucción utiliza un operando inmediato (como en las instrucciones de tipo I), el valor inmediato se extiende a 32 bits.
- La extensión mantiene el signo del operando para operaciones aritméticas correctas.


### Funcionamiento

El módulo `sign_extension` realiza la extensión de un valor de entrada, que puede ser **extensión de signo** o **extensión con ceros**, dependiendo de una señal de control. A continuación, se detalla cómo funciona:



### Funcionalidad Principal
- **Extensión de Signo**:  
  - Si la señal de control `i_is_signed` es **1**, el módulo realiza una extensión de signo. Esto significa que el bit más significativo (MSB) del valor original se replica en los bits adicionales del valor extendido.  
  - Esto es útil para preservar el valor correcto en representaciones de números negativos en complemento a dos.

- **Extensión con Ceros**:  
  - Si `i_is_signed` es **0**, el módulo realiza una extensión con ceros. En este caso, los bits adicionales del valor extendido se rellenan con **0**.



### Entradas y Salidas
#### Entradas:
1. **`i_value`**:  
   - Valor original que se desea extender.
   - Tamaño configurable mediante el parámetro `DATA_ORIGINAL_SIZE`.
2. **`i_is_signed`**:  
   - Señal de control:
     - **1**: Realiza extensión de signo.
     - **0**: Realiza extensión con ceros.

#### Salida:
1. **`o_extended_value`**:  
   - Valor extendido resultante.
   - Tamaño configurable mediante el parámetro `DATA_EXTENDED_SIZE`.

### Lógica del Módulo
- La extensión se realiza utilizando un operador ternario:
  - Si `i_is_signed` es **1**:
    - Los bits adicionales se rellenan replicando el MSB de `i_value` (extensión de signo).
  - Si `i_is_signed` es **0**:
    - Los bits adicionales se rellenan con ceros (extensión con ceros).


### Parámetros Configurables
1. **`DATA_ORIGINAL_SIZE`**:  
   - Define el tamaño del valor de entrada (`i_value`).
   - Por defecto: **16 bits**.
2. **`DATA_EXTENDED_SIZE`**:  
   - Define el tamaño del valor extendido (`o_extended_value`).
   - Por defecto: **32 bits**.



### Ejemplo de Operación
#### Caso 1: Extensión de Signo (`i_is_signed = 1`)
- **Valor original (`i_value`)**: `8'b10011001` (negativo en complemento a dos).
- **Extensión de signo**:  
  - El MSB (`1`) se replica en los bits adicionales.
  - Salida (`o_extended_value`): `32'b111111111111111110011001`.

#### Caso 2: Extensión con Ceros (`i_is_signed = 0`)
- **Valor original (`i_value`)**: `8'b10011001`.
- **Extensión con ceros**:  
  - Los bits adicionales se rellenan con `0`.
  - Salida (`o_extended_value`): `32'b000000000000000010011001`.


### Flujo de Operación
1. **Proporcionar Entradas**:
   - Configura `i_value` con el valor a extender.
   - Ajusta `i_is_signed` según el tipo de extensión deseada:
     - **1** para extensión de signo.
     - **0** para extensión con ceros.

2. **Observar la Salida**:
   - El resultado extendido estará disponible en `o_extended_value`.

3. **Modificar Parámetros (Opcional)**:
   - Ajusta `DATA_ORIGINAL_SIZE` y `DATA_EXTENDED_SIZE` según los requisitos del sistema.



## 3. Shift a la izquierda por 2
- Para instrucciones de salto (como `beq` o `bne`), el offset se desplaza 2 bits a la izquierda.
- Este desplazamiento asegura que la dirección esté alineada a palabras (múltiplos de 4 bytes).



### Funcionamiento

El módulo `shift_left` realiza un **desplazamiento lógico a la izquierda** de un valor de entrada. El número de posiciones a desplazar se configura mediante un parámetro, y por defecto se establece en 2 posiciones. A continuación, se explica cómo funciona:


- **Desplazamiento Lógico a la Izquierda**:  
  El módulo toma un valor de entrada (`i_value`) y lo desplaza hacia la izquierda un número fijo de posiciones (`POS_TO_SHIFT`). El desplazamiento lógico significa que los bits a la izquierda se mueven hacia posiciones de mayor valor, mientras que los bits de menor peso se llenan con **ceros**.



####  Entradas y Salidas

1. **`i_value`**:  
   - Valor de entrada a ser desplazado.
   - Tiene un tamaño configurable mediante el parámetro `DATA_LEN`.
   
1. **`o_shifted`**:  
   - Valor desplazado a la izquierda.
   - El tamaño del valor desplazado es el mismo que el de `i_value` (configurado con `DATA_LEN`).



####  Lógica del Módulo
- El módulo utiliza la operación de desplazamiento a la izquierda (`<<`) para desplazar el valor de entrada (`i_value`) el número de posiciones configurado en `POS_TO_SHIFT`.
  - Si `POS_TO_SHIFT = 2`, por ejemplo, el valor de entrada se desplazará 2 posiciones a la izquierda, y los bits más pequeños se llenarán con **ceros**.



####  Parámetros Configurables
1. **`DATA_LEN`**:  
   - Longitud del valor de entrada y salida (en bits).
   - Por defecto: **32 bits**.

2. **`POS_TO_SHIFT`**:  
   - Número de posiciones a desplazar el valor de entrada.
   - Por defecto: **2**.



####  Ejemplo de Operación
##### Caso 1: Desplazamiento de 2 posiciones (`POS_TO_SHIFT = 2`)
- **Valor original (`i_value`)**: `32'b00000000000000000000000000001101` (13 en decimal).
- **Resultado del desplazamiento**:  
  El valor de entrada se desplaza 2 posiciones a la izquierda:
  - Salida (`o_shifted`): `32'b00000000000000000000000000110100` (52 en decimal).

##### Caso 2: Desplazamiento de 1 posición (`POS_TO_SHIFT = 1`)
- **Valor original (`i_value`)**: `32'b00000000000000000000000000001101` (13 en decimal).
- **Resultado del desplazamiento**:  
  El valor de entrada se desplaza 1 posición a la izquierda:
  - Salida (`o_shifted`): `32'b00000000000000000000000000011010` (26 en decimal).



#### Flujo de Operación
1. **Proporcionar Entrada**:
   - Configura `i_value` con el valor que deseas desplazar.

2. **Ajustar Parámetros**:
   - Puedes configurar `DATA_LEN` y `POS_TO_SHIFT` según las necesidades de tu diseño:
     - **`DATA_LEN`** define el tamaño del valor de entrada y salida.
     - **`POS_TO_SHIFT`** define cuántas posiciones se desplaza el valor.

3. **Observar la Salida**:
   - El valor desplazado estará disponible en `o_shifted`.














## 4. Cálculo de la dirección de salto (branch)
- En instrucciones condicionales, se calcula la dirección objetivo sumando el valor desplazado del offset al contador de programa (PC).

## 5. Generación de señales de control
- El decodificador identifica el tipo de instrucción (R, I o J).
- Genera las señales necesarias para las etapas siguientes (EX, MEM y WB), como:
  - Tipo de operación aritmética.
  - Acceso a memoria (lectura o escritura).
  - Escritura en registros.

## 6. Comparación para instrucciones de rama
- En instrucciones como `beq` (branch if equal), los valores de los registros fuente se comparan.
- Si son iguales, se toma la rama (branch).







