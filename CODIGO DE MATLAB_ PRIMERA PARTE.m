% Código MATLAB - Punto 4.1: Formulación y Derivación Numérica
% Optimización de la Eficiencia del Panel Solar (MPPT)

% 1. Definición de los datos extraídos empíricamente del archivo PDF
% [Punto 1 (previo al pico), Punto 2 (en el pico)]
V = [0.833, 0.867]; % Voltaje en Voltios (V)
I = [1.61, 1.68];   % Corriente en miliamperios (mA)
P = [1.34, 1.46];   % Potencia en milivatios (mW)

% 2. Cálculo de las tasas de cambio (Deltas / Diferencias finitas)
delta_V = V(2) - V(1);
delta_I = I(2) - I(1);
delta_P = P(2) - P(1);

% 3. Método 1: Derivada numérica directa de la potencia (dP/dV)
dP_dV = delta_P / delta_V;

% 4. Método 2: Formulación Analítica desglosada f(V) = I + V * (dI/dV)
% Primero calculamos la tasa de cambio de la corriente respecto al voltaje
dI_dV = delta_I / delta_V;

% Para evaluar en el tramo, usamos el valor promedio (Punto medio)
V_prom = mean(V); 
I_prom = mean(I); 

% Evaluamos la función objetivo f(V)
f_V = I_prom + V_prom * dI_dV;

% 5. Impresión de Resultados en la Ventana de Comandos (Command Window)
fprintf('--- Resultados del Punto 4.1: Derivación Numérica ---\n');
fprintf('Valores de entrada:\n');
fprintf('V1 = %.3f V, I1 = %.2f mA, P1 = %.2f mW\n', V(1), I(1), P(1));
fprintf('V2 = %.3f V, I2 = %.2f mA, P2 = %.2f mW\n\n', V(2), I(2), P(2));

fprintf('Deltas calculados:\n');
fprintf('Delta V: %.3f V\n', delta_V);
fprintf('Delta I: %.3f mA\n', delta_I);
fprintf('Delta P: %.3f mW\n\n', delta_P);

fprintf('--- Cálculo de Derivadas ---\n');
fprintf('1. Derivada Directa (dP/dV) = %.3f mW/V\n', dP_dV);
fprintf('2. Derivada de la Corriente (dI/dV) = %.3f (mA/V)\n', dI_dV);
fprintf('3. Evaluacion de f(V) = I + V*(dI/dV) = %.3f mW/V\n\n', f_V);

% Análisis lógico para el MPPT
if f_V > 0.05
    disp('Conclusión Matemática: f(V) > 0.');
    disp('El algoritmo detecta que la curva está subiendo. El Vmpp es mayor al actual.');
elseif f_V < -0.05
    disp('Conclusión Matemática: f(V) < 0.');
    disp('El algoritmo detecta que la curva está bajando. El Vmpp es menor al actual.');
else
    disp('Conclusión Matemática: f(V) aprox 0.');
    disp('¡Punto de Máxima Potencia (MPPT) alcanzado!');
end
