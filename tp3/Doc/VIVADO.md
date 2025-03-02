
# Fundamentos Teóricos para el Uso de Vivado

## ¿Qué es RTL?

**RTL** significa **Register Transfer Level** (Nivel de Transferencia de Registro). El RTL describe el comportamiento del hardware **ciclo a ciclo**.

Es una forma de describir el hardware digital enfocándose en:
- Cómo los datos se mueven entre registros.
- Qué operaciones lógicas o aritméticas se hacen sobre esos datos.
- Todo controlado por señales de reloj y control.

---

### 🔹 ¿Dónde usamos RTL?
Cuando escribís código en lenguajes como:
- **Verilog**
- **VHDL**

Ahí estás creando una descripción RTL del hardware.

---

### 🔹 ¿Qué NO es RTL?
- No es código software.
- No es una descripción física (eso ocurre después de la síntesis e implementación).
- No es aún puertas lógicas ni cables reales.

###


# Flujo de trabajo en Vivado y explicación de botones

## 🔹 SIMULATION
### `Run Simulation`
Ejecuta la simulación del diseño (por ejemplo, usando un testbench).  
✅ **Cuándo usarlo:** Antes de todo, para validar la lógica funcional del RTL.

---

## 🔹 RTL ANALYSIS
### `Run Linter`
Revisa errores sintácticos y advertencias en tu código RTL.  
✅ **Cuándo usarlo:** Antes de la síntesis, para asegurar que no haya errores básicos.

### `Open Elaborated Design`
Genera una vista elaborada del RTL para revisar jerarquía y conexiones.  
✅ **Cuándo usarlo:** Antes de la síntesis, para inspeccionar la estructura del diseño.

#### Dentro de Elaborated Design:
- **Report Methodology** → Muestra advertencias y sugerencias de buenas prácticas.
- **Report DRC** → Verifica reglas básicas de diseño.
- **Schematic** → Visualización gráfica del diseño RTL.

---

## 🔹 SYNTHESIS
### `Run Synthesis`
Convierte el código RTL en un netlist lógico (puertas, registros, etc.).  
✅ **Cuándo usarlo:** Luego de validar el RTL (simulación + análisis).

### `Open Synthesized Design`
Permite revisar el diseño sintetizado, uso de recursos y tiempos preliminares.

---

## 🔹 IMPLEMENTATION
### `Run Implementation`
Realiza el mapeo, colocación y ruteo físico del diseño en la FPGA.  
✅ **Cuándo usarlo:** Después de la síntesis para verificar tiempos y distribución física.

### `Open Implemented Design`
Permite inspeccionar el diseño implementado, distribución física y análisis temporal.

---

## 🔹 PROGRAM AND DEBUG
### `Generate Bitstream`
Genera el archivo `.bit` necesario para programar la FPGA.  
✅ **Cuándo usarlo:** Después de una implementación exitosa.

### `Open Hardware Manager`
Conecta y programa la FPGA con el bitstream generado. Permite debug en hardware real.

---

## 🔄 Flujo típico recomendado:
1. `Run Linter`
2. `Run Simulation`
3. `Open Elaborated Design` (opcional)
4. `Run Synthesis`
5. `Open Synthesized Design` (opcional)
6. `Run Implementation`
7. `Open Implemented Design` (opcional)
8. `Generate Bitstream`
9. `Open Hardware Manager`
