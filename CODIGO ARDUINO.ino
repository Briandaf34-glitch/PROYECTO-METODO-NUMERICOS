#include <TFT_eSPI.h>       // Librería para la pantalla del ESP32 T-Display
#include <SPI.h>
#include <Wire.h>           // Librería para comunicación I2C
#include <Adafruit_INA219.h> // Librería para el sensor INA219

// Instancias de los objetos
TFT_eSPI tft = TFT_eSPI(); 
Adafruit_INA219 ina219;

void setup() {
  Serial.begin(115200);

  // Inicializar la pantalla
  tft.init();
  tft.setRotation(1); // Rotación horizontal
  tft.fillScreen(TFT_BLACK); // Fondo negro
  
  // Inicializar comunicación I2C en los pines 21(SDA) y 22(SCL)
  Wire.begin(21, 22);

  // Inicializar el sensor INA219
  if (!ina219.begin()) {
    Serial.println("Fallo al encontrar el chip INA219");
    tft.setTextColor(TFT_RED, TFT_BLACK);
    tft.drawString("Error INA219!", 10, 50, 4);
    while (1) { delay(10); } // Detener el programa si hay error
  }
  
  // Para limpiar la gráfica inicial del plotter
  Serial.println(""); 
  
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.drawString("Iniciando...", 20, 50, 4);
  
  // --- CALIBRACIÓN PARA MAYOR PRECISIÓN POR HARDWARE ---
  // Descomenta una de estas líneas si tus mediciones no superan esos límites:
  // ina219.setCalibration_32V_1A();    // Ideal si mides menos de 1A
  // ina219.setCalibration_16V_400mA(); // Máxima precisión si mides menos de 16V y 400mA
  
  delay(2000);
  tft.fillScreen(TFT_BLACK); // Limpiar pantalla de inicio

  // --- Dibujar textos estáticos una sola vez (evita parpadeos) ---
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.drawString("Voltaje:", 10, 10, 4); 
  tft.drawString("V", 220, 10, 4);

  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.drawString("Corr:", 10, 50, 4); 
  tft.drawString("mA", 220, 50, 4);

  tft.setTextColor(TFT_YELLOW, TFT_BLACK);
  tft.drawString("Pot:", 10, 90, 4); 
  tft.drawString("mW", 220, 90, 4);
}

void loop() {
  // Variables para acumular las lecturas
  float shuntvoltage = 0;
  float busvoltage = 0;
  float current_mA = 0;
  float loadvoltage = 0;
  float power_mW = 0;

  // Promediar 10 lecturas para mayor precisión (Filtro por software)
  int num_lecturas = 10;
  for (int i = 0; i < num_lecturas; i++) {
    shuntvoltage += ina219.getShuntVoltage_mV();
    busvoltage += ina219.getBusVoltage_V();
    current_mA += ina219.getCurrent_mA();
    delay(10); // Pequeña pausa entre mediciones (10ms * 10 = 100ms total)
  }

  // Dividir para obtener el promedio real
  shuntvoltage /= num_lecturas;
  busvoltage /= num_lecturas;
  current_mA /= num_lecturas;
  
  // Convertir la corriente a valor absoluto (siempre positivo)
  current_mA = abs(current_mA);
  
  // El voltaje real de la carga es el voltaje del bus más la caída en la resistencia shunt
  loadvoltage = busvoltage + (shuntvoltage / 1000.0);

  // Calcular la potencia como Corriente x Voltaje (mA * V = mW)
  power_mW = loadvoltage * current_mA;

  // --- Actualizar valores dinámicos en la pantalla ---
  // Establecer un padding para borrar automáticamente los números anteriores
  tft.setTextPadding(100); 

  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.drawFloat(loadvoltage, 3, 110, 10, 4); // 3 decimales

  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.drawFloat(current_mA, 2, 110, 50, 4);  // 2 decimales

  tft.setTextColor(TFT_YELLOW, TFT_BLACK);
  tft.drawFloat(power_mW, 2, 110, 90, 4);    // 2 decimales

  // Restablecer el padding
  tft.setTextPadding(0);

  // --- Enviar datos al Serial Plotter (Con unidades en las etiquetas) ---
  Serial.print("Voltaje(V):");
  Serial.print(loadvoltage, 3);
  Serial.print(",");
  Serial.print("Corriente(mA):");
  Serial.print(current_mA, 2);
  Serial.print(",");
  Serial.print("Potencia(mW):");
  Serial.println(power_mW, 2); // El último lleva "println" para el salto de línea

  // Esperar 900ms (junto con los 100ms de las lecturas suma 1 segundo)
  delay(900);
}