% --- OPTIMIZACIÓN DE PUNTO DE MÁXIMA POTENCIA (MPPT) ---
% Proyecto de Métodos Numéricos

clear; clc; close all;

% 1. Ingreso de los datos experimentales obtenidos con Arduino
% (Aquí he colocado una muestra de la zona de máxima potencia "rodilla". 
% Puedes pegar aquí tus 150 datos completos separando por comas)
V_data = [0.801, 0.822, 0.836, 0.844, 0.850, 0.855, 0.867, 0.880];
P_data = [1.25,  1.30,  1.38,  1.38,  1.43,  1.39,  1.46,  1.39];

% 2. Regresión Polinómica de Tercer Grado (Ajuste de Curva)
% La función polyfit encuentra los coeficientes [a, b, c, d] del polinomio
grado = 3;
coef_P = polyfit(V_data, P_data, grado);

fprintf('--- 1. MODELO MATEMÁTICO (REGRESIÓN CÚBICA) ---\n');
fprintf('P(V) = %.4f V^3 + %.4f V^2 + %.4f V + %.4f\n\n', ...
    coef_P(1), coef_P(2), coef_P(3), coef_P(4));

% 3. Cálculo de la Primera Derivada (Función Objetivo para Newton-Raphson)
% La función polyder deriva matemáticamente el polinomio
coef_dP = polyder(coef_P);

fprintf('--- 2. FUNCIÓN OBJETIVO (DERIVADA dP/dV) ---\n');
fprintf('f(V) = %.4f V^2 + %.4f V + %.4f = 0\n\n', ...
    coef_dP(1), coef_dP(2), coef_dP(3));

% 4. Cálculo de la Raíz (Punto de Máxima Potencia)
% En MATLAB, 'roots' encuentra los ceros de la función derivada de forma directa
raices = roots(coef_dP);

% Filtramos la raíz que tiene sentido físico (el voltaje positivo en nuestro rango)
V_optimo = raices(raices > 0 & raices < 1);
P_max = polyval(coef_P, V_optimo);

fprintf('--- 3. RESULTADO DE LA OPTIMIZACIÓN ---\n');
fprintf('Voltaje Óptimo (Vmp): %.3f V\n', V_optimo);
fprintf('Potencia Máxima (Pmax): %.3f mW\n', P_max);

% 5. Generación de la Gráfica Justificativa
figure('Name', 'Caracterización y Optimización del Panel Solar', 'Position', [100, 100, 800, 500]);

% Crear un vector de voltaje continuo para dibujar la curva suave
V_plot = linspace(min(V_data)-0.02, max(V_data)+0.02, 200);
P_plot = polyval(coef_P, V_plot);

% Graficar datos, curva de regresión y punto máximo
plot(V_data, P_data, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Datos de Arduino'); hold on;
plot(V_plot, P_plot, 'b-', 'LineWidth', 2, 'DisplayName', 'Modelo Polinómico P(V)');
plot(V_optimo, P_max, 'r*', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Punto de Máxima Potencia');

% Formato de la gráfica
title('Búsqueda del Punto de Máxima Potencia mediante Métodos Numéricos');
xlabel('Voltaje (V)');
ylabel('Potencia (mW)');
legend('Location', 'southEast');
grid on;
hold off;