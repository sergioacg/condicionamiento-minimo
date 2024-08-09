%% Control MIMO Columna de Wood and Berry
% Sergio Andres Castaño Giraldo
% https://controlautomaticoeducacion.com/
%% Cursos PREMIUM
% https://controlautomaticoeducacion.com/cursos-premium-cae/
%%
clc
close all
clear all

%% Parametros del Simulink
s1=100;       %SetPoint en el tope
s2=50;     %SetPoint en el fondo
q=0.1;      %Escalón en la perturbación
tsim=200;   %Tiempo de Simulación
ts1=5;      %Tiempo donde se aplica el Setpoint en el tope
ts2=80;     %Tiempo donde se aplica el Setpoint en el fondo
tq=140;     %Tiempo donde se aplica escalón de la perturbación

%% Función de transferencia del Modelo del Proceso W&B
G=[tf(12.8,[16.7 1]) tf(-18.9,[21 1]);tf(6.6,[10.9 1]) tf(-19.40,[14.4 1])];
Go = G;
G.iodelay=[1 3;7 3]; %Retardo


%% Funcion de Transferencia de la planta real
Gr = G*1.2; %Discrepancia en la ganancia de 20%
Gr.iodelay=[1.5 3.2;7.4 3.3]; %Retardo

%% Control PI por Asignación de Polos
%Polos asignados para garantizar la siguiente dinámica:
% Función de transferencia = Lazo directo
%Tiempo de estabilización = 25
%Fator de Amortiguamiento = 0.9
%Tipo de Controlador = PI
%Garantizar el 5% en el tempo de establecimiento
%graficar el lazo cerrado= 1
%alfa:1 (Filtro solo para el control PID)
%type:1 (Control rápido)
%mas información digitar: help AlocaPID

C(1,1)= AlocaPID(G(1,1),30,0.9,'PI',5,0,1,1);
C(2,2) = AlocaPID(G(2,2),30,0.9,'PI',5,0,1,1);


%% Escala la Planta
K = dcgain(G);
[L, R, S] = CondMin(K);
Ge = L * G * R;
Geo = Ge;
Geo.iodelay=0;
Ke = dcgain(Ge);

%% Control PI por Asignación de Polos Escalado
Ce(1,1) = AlocaPID(Ge(1,1),30,0.9,'PI',5,0,1,1);
Ce(2,2) = AlocaPID(Ge(2,2),30,0.9,'PI',5,0,1,1);

fprintf('Original condition number: %f\n', cond(K));
fprintf('Scaled condition number: %f\n', cond(Ke));

sim('Control_MIMO_LTI')


