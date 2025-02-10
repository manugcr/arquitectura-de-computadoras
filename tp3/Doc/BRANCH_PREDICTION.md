

### 📌 Tipos de Predicción de Saltos

🔹 **Estática**:  
Siempre se predice si el salto será efectuado o no. Si la predicción es incorrecta, la instrucción siguiente se aborta (se reemplaza por un `NOP`).  

🔹 **Dinámica**:  
Se basa en la historia previa del salto. Los predictores dinámicos en *hardware* ajustan sus predicciones dependiendo del comportamiento de cada salto y pueden cambiarlas a lo largo de la ejecución del programa.

<p align="center"> <img src="../img/image63.png" alt=""> </p>



### ⚙️ Predicción Dinámica de Saltos

Con *pipelines* más profundos (mayor número de etapas), la penalización en ciclos de reloj por fallos en la predicción de saltos aumenta.  
Esto hace que la **predicción estática** ya no sea suficiente para mantener un buen rendimiento en el *pipeline*.  

Para mejorar la eficiencia, se utiliza la **predicción dinámica de saltos**, que predice el comportamiento de los saltos en tiempo de ejecución basándose en la información generada durante la ejecución del programa.

Una estrategia común consiste en observar si el salto fue tomado la última vez que se ejecutó la instrucción:
- Si fue tomado, la siguiente instrucción se busca en la misma dirección de la vez anterior.
- Para implementar esta estrategia, se emplean estructuras como:
  - **Búfer de predicción de saltos**
  - **Tabla de historia de saltos**  

Estas estructuras son memorias pequeñas indexadas con la parte menos significativa de la dirección de la instrucción de salto.  
Cada entrada contiene un **bit de predicción** que indica si el salto ha sido recientemente tomado o no.  

Aunque no se puede garantizar que la predicción sea correcta, esta se realiza como una **apuesta basada en la historia previa del salto**.

<p align="center"> <img src="../img/image64.png" alt=""> </p>


---

## Predictor de un Bit

Utiliza un bit de predicción para cada instrucción de salto. El bit de predicción refleja el comportamiento de la última ejecución de la instrucción de salto, indicando si en la ejecución anterior el salto fue tomado o no.  
Recuerda solamente el último estado.

### Predicción
- El salto permanece como **Taken** si en la última ejecución fue tomado.  
- El salto se predice como **Not Taken** si en la última ejecución no fue tomado.  

### Funcionamiento

#### Máquina de dos estados:
- **Not Taken (1)**
- **Taken (0)**

<p align="center"> <img src="../img/image65.png" alt=""> </p>

### Limitación
- Solo se registra el comportamiento **de la última ejecución del salto**.  
- Dos malas predicciones en los cambios de estado:
  - **T**: El salto ha sido tomado.  
  - **NT**: El salto no ha sido tomado.  

Este predictor funciona bien para **bucles con muchas iteraciones**, ya que la predicción será acertada para todas las instrucciones, excepto para la última.  

Sin embargo, hay casos en los que no funciona tan bien, como:
- Un **bucle dentro de otro** 🔃, donde la cantidad de predicciones erróneas se multiplica.  
- Casos donde no funciona en lo absoluto, por ejemplo, un bucle en el que la variable de la condición de salto **alterna entre dos valores en cada iteración**.



El predictor de 1 bit es **eficiente** cuando se tiene un único bucle.  

**Ejemplo**:  
Si hay un bucle con **1000 iteraciones**, el predictor acertará en **999 ocasiones** y fallará en solo **2**, lo que lo hace altamente efectivo en este escenario.

Sin embargo, este predictor es **extremadamente ineficiente** cuando se tienen **bucles anidados** (un bucle dentro de otro).  

Esto se debe a que el comportamiento de los saltos en los bucles internos puede ser **errático o alternar en cada iteración**, lo que genera una mayor cantidad de **predicciones incorrectas**.  

En estos casos, el predictor de 1 bit no es capaz de manejar correctamente los cambios de comportamiento entre los diferentes niveles de bucles.



#### 📌 EJEMPLO 1: Bucle Simple (Alta Precisión del Predictor de 1 Bit)
En este caso, el bucle tiene **1000 iteraciones**, lo que significa que el salto se tomará **999 veces** y solo la última vez no se tomará.

```c
for (int i = 0; i < 1000; i++) {
    // Cuerpo del bucle
}
```

**Explicación**
- El salto **i < 1000** es **tomado (T)** en **999** iteraciones.
- En la última iteración, el salto **no es tomado (NT)** y el bucle termina.
- **El predictor de 1 bit acertará 999 veces y fallará solo 2 veces**:  
  - Una vez cuando predice **T** en la última iteración y realmente es **NT**.
  - Otra cuando se reinicia el bucle y predice **NT**, pero realmente es **T**.

✅ **Resultado:** El predictor de 1 bit funciona muy bien aquí 🎉.

---

#### 📌 EJEMPLO 2:  Bucle Anidado (Baja Precisión del Predictor de 1 Bit)
Ahora consideremos un bucle **anidado**, donde el comportamiento del salto cambia más frecuentemente.

```c
for (int i = 0; i < 100; i++) {       // Bucle externo
    for (int j = 0; j < 10; j++) {    // Bucle interno
        // Cuerpo del bucle interno
    }
}
```

 **Explicación**
- El salto del **bucle interno** (`j < 10`) será **T (tomado) 9 veces** y **NT (no tomado) 1 vez** por cada iteración del bucle externo.
- El salto del **bucle externo** (`i < 100`) será **T (tomado) 99 veces** y **NT (no tomado) 1 vez**.

🔴 **Problema del Predictor de 1 Bit:**
- Cada vez que el bucle interno se reinicia (**j = 0**), el salto previo fue **NT**, por lo que el predictor asumirá que la próxima vez también será **NT** (incorrecto, ya que debería ser **T**).
- Esto causa **fallos frecuentes en la predicción** cada vez que el bucle interno se reinicia.
- Si hay más bucles anidados, la cantidad de predicciones erróneas **aumenta exponencialmente**.

❌ **Resultado:** El predictor de 1 bit **no puede manejar correctamente los cambios de estado en los bucles anidados**, lo que genera **más errores**.



## 🎯 Conclusión

| Caso                | Iteraciones | Predicciones Correctas | Predicciones Incorrectas |
|---------------------|-------------|------------------------|--------------------------|
| **Bucle Simple**     | 1000        | 999                    | 2                        |
| **Bucle Anidado**    | 1000        | Mucho menor            | Mucho mayor              |

El **predictor de 1 bit** es **eficiente** en un bucle simple con muchas iteraciones, pero **ineficiente** en bucles anidados porque no puede manejar bien los cambios de estado. En estos casos, se utilizan **predictores de 2 bits** o técnicas más avanzadas. 🚀





## Predictor de Dos Bits (Bimodal)

Este predictor utiliza **dos bits** de predicción por cada instrucción de salto, reflejando el comportamiento de las **últimas dos ejecuciones** de ese salto.



### Predicción:
- Un salto que se **toma repetidamente** se predice como **Taken**.
- Un salto que **no se toma repetidamente** se predice como **Not Taken**.
- Si un salto toma una dirección inusual una sola vez, el predictor mantiene la predicción usual.

---

### Funcionamiento:

<p align="center"> <img src="../img/image66.png" alt=""> </p>

- **Máquina de cuatro estados:**
  - **00:** Predicción **Not Taken** (probabilidad baja de ser tomado).
  - **01:** Predicción **Not Taken** (probabilidad alta de ser tomado).
  - **10:** Predicción **Taken** (probabilidad baja de no ser tomado).
  - **11:** Predicción **Taken** (probabilidad alta de ser tomado).
  
- **Registro de historia:** **Contador saturado de 2 bits.**
- **Predicción:** Se basa en el bit más significativo del registro de historia.



### Comportamiento:

#### Bucle Simple:
Inicialmente, el predictor necesita ajustarse, lo que genera **predicciones erróneas**.  
Sin embargo, una vez que el patrón de ejecución se establece, el predictor aprende a predecir correctamente el salto como **Taken** en las siguientes iteraciones, **aumentando el porcentaje de aciertos**.

#### Bucle Dentro de Otro Bucle:
Se producen aproximadamente **un 50 % menos de predicciones erróneas** en comparación con el **predictor de 1 bit**.

#### Características:
- **Eficiencia Mejorada:** Este predictor es más efectivo al correlacionar mejor debido a la mayor memoria.
- **Costo:** Requiere **dos bits** de almacenamiento por cada instrucción de salto, lo que aumenta el costo en comparación con el predictor de 1 bit. Sin embargo, esto se compensa con un mejor rendimiento en la predicción.


### Consideraciones:
Aunque el costo de implementar un predictor de 2 bits es más alto, su capacidad de aprender patrones de predicción lo hace más adecuado para bucles complejos y saltos repetitivos. Es más efectivo que el predictor de 1 bit en escenarios con patrones predecibles, y ofrece una mejor **tasa de aciertos** en general.


## Buffer de Destino de Saltos BTB (Branch Target Buffer)

<p align="center"> 
  <img src="../img/image67.png" alt=""> 
</p>

Añade bits de predicción a las entradas de la BTAC. La BTAC con bits de predicción se denomina **BTB**, que es una estructura que almacena en cada entrada:
- Un *tag* con la instrucción de salto.
- La dirección de destino del último salto tomado (BTA = Branch Target Buffer).
- Los bits de predicción de ese salto.

### Actualización de la BTB
Los campos de la BTB se actualizan después de ejecutar el salto, según:
- Si el salto fue tomado o no ⇒ Actualizar bits de predicción.
- La dirección de destino del salto ⇒ Actualizar la BTA.

---

## Tabla de Historia de Saltos BHT (Branch Table History)

La **Tabla de Historia de Saltos** (BHT) mantiene un registro del historial de comportamiento de saltos en el programa. Cada entrada en la tabla corresponde a una dirección de instrucción y almacena información sobre si el salto en esa dirección ha sido tomado o no en ejecuciones anteriores.

Dependiendo de la implementación, la BHT puede utilizar diferentes esquemas de almacenamiento. Generalmente existen dos tablas:

1. **BTAC (Branch Target Address Cache)**: Almacena la dirección de destino de los últimos saltos tomados.

<p align="center"> 
  <img src="../img/image68.png" alt=""> 
</p>

2. **BHT (Branch History Table)**: Almacena los bits de predicción de todas las instrucciones de salto condicional. Para cada salto, la BHT guarda información sobre si fue tomado o no en ejecuciones anteriores.

### Ventajas y Desventajas

- **Ventaja**: Puede hacer predicciones para instrucciones que no están en la BTAC, ya que la BHT tiene una mayor capacidad de almacenamiento, almacenando información para todas las instrucciones de salto del programa, independientemente de si están presentes en la BTAC.
  
- **Desventaja**: Aumenta el hardware necesario (dos tablas asociativas).

### Acceso a la BHT
La BHT se accede utilizando los bits menos significativos de la dirección del salto. En lugar de utilizar etiquetas (*tags*) para identificar las entradas en la tabla, se utiliza una dirección parcial, lo que reduce el costo del hardware. Sin embargo, este enfoque puede tener un impacto en el rendimiento, ya que el comportamiento de las entradas puede degradarse debido a la falta de etiquetas distintivas.



