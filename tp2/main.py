import serial
import time

# Configuración del puerto serial
COM_PORT = 'COM12'  # Cambia esto según tu configuración
BAUD_RATE = 19200  # Velocidad de transmisión

# Inicializar el puerto serial
ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)

def bin_to_int(bin_str):
    """Convierte una cadena binaria a un entero."""
    return int(bin_str, 2)

def int_to_bin(value, bits):
    """Convierte un entero a una cadena binaria con un número específico de bits."""
    return format(value, f'0{bits}b')

try:
    # Espera un momento para asegurarte de que el puerto esté listo
    time.sleep(2)

    # Solicitar al usuario los primeros 8 bits en formato binario
    data_8_bits_1 = input("Ingresa el primer valor de 8 bits en binario (ej. 10101010): ")
    data_8_bits_1_int = bin_to_int(data_8_bits_1)
    ser.write(data_8_bits_1_int.to_bytes(1, byteorder='big'))  # Enviar como un byte
    print(f"Enviado 8 bits 1: {data_8_bits_1}")

    # Solicitar al usuario otros 8 bits en formato binario
    data_8_bits_2 = input("Ingresa el segundo valor de 8 bits en binario (ej. 11001100): ")
    data_8_bits_2_int = bin_to_int(data_8_bits_2)
    ser.write(data_8_bits_2_int.to_bytes(1, byteorder='big'))  # Enviar como un byte
    print(f"Enviado 8 bits 2: {data_8_bits_2}")

    # Solicitar al usuario los 6 bits en formato binario
    data_6_bits = input("Ingresa un valor de 6 bits en binario (ej. 111100): ")
    data_6_bits_int = bin_to_int(data_6_bits)
    ser.write(data_6_bits_int.to_bytes(1, byteorder='big'))  # Enviar como un byte (solo los 6 bits)
    print(f"Enviado 6 bits: {data_6_bits}")

    # Espera un momento antes de recibir datos
    time.sleep(1)

    # Recibir 8 bits
    received_data = ser.read(1)  # Leer un byte
    if received_data:
        received_value = int.from_bytes(received_data, byteorder='big')
        received_value_bin = int_to_bin(received_value, 8)
        print(f"Recibido 8 bits: {received_value_bin}")

except Exception as e:
    print(f"Ocurrió un error: {e}")

finally:
    # Cerrar el puerto serial
    ser.close()
