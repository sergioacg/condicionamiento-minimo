%% Conditioning of a MIMO System
% SERGIO ANDRES CASTAÑO GIRALDO
% www.controlautomaticoeducacion.com
% https://www.youtube.com/c/SergioACastañoGiraldo
%% Cursos PREMIUM
% https://controlautomaticoeducacion.com/cursos-premium-cae/
% ======================================================

clc; clear all; close all;
s = tf('s');

% Define the transfer functions of the Wood and Berry binary distillation column with adjusted parameters
G11 = 12.8 * exp(-1*s) / (20 * s + 1);
G12 = -18.9 * exp(-3*s) / (25 * s + 1);
G21 = 6.6 * exp(-7*s) / (12 * s + 1);
G22 = -19.4 * exp(-3*s) / (16 * s + 1);

% 2x2 MIMO system
G = [G11, G12; G21, G22];

% Assign names to inputs and outputs
G.InputName = {'Reflux Rate', 'Steam Rate'};
G.OutputName = {'Distillate Purity', 'Bottoms Purity'};

% Visualize the step response of the original system
figure; 
step(G); 
title('Step Response of the Original System');
xlabel('Time (seconds)');
ylabel('Amplitude');
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
set(findall(gcf, 'Type', 'line'), 'LineWidth', 2);
grid on;

% Evaluate the static gain matrix
K = dcgain(G);
cond_G = cond(K);
fprintf('Original condition number: %f\n', cond_G);

% SVD of the original system
[UG, SG, VG] = svd(K);

%% Function to calculate the minimum conditioning
[L, R, S] = CondMin(K);

% Calculate the condition number of the rescaled matrix
G_rescaled = L * G * R;

Kr = dcgain(G_rescaled);

cond_Gr = cond(Kr);

fprintf('Rescaled condition number: %f\n', cond_Gr);

% Assign names to inputs and outputs
G_rescaled.InputName = {'Reflux Rate', 'Steam Rate'};
G_rescaled.OutputName = {'Distillate Purity', 'Bottoms Purity'};

% Visualize the step response of the rescaled system
figure; 
step(G_rescaled); 
title('Step Response of the Rescaled System');
xlabel('Time (seconds)');
ylabel('Amplitude');
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
set(findall(gcf, 'Type', 'line'), 'LineWidth', 2);
grid on;

% SVD of the rescaled system
[UGr, SGr, VGr] = svd(Kr);

% Directions of maximum and minimum gain of the original system
dir_max_gain_original = VG(:,1);
dir_min_gain_original = VG(:,end);

% Directions of maximum and minimum gain of the rescaled system
dir_max_gain_rescaled = VGr(:,1);
dir_min_gain_rescaled = VGr(:,end);

%% Dynamic simulations in the directions of maximum and minimum gain
% Simulation time
tf = 700;
t = linspace(0, tf, 1000)';

% Create unit step input signals in the directions of maximum and minimum gain
u1_original = (t > 0) * dir_max_gain_original';
u2_original = (t > 0) * dir_min_gain_original';

u1_rescaled = (t > 0) * dir_max_gain_rescaled';
u2_rescaled = (t > 0) * dir_min_gain_rescaled';

% System responses
y1_original = lsim(G, u1_original, t);
y2_original = lsim(G, u2_original, t);

y1_rescaled = lsim(G_rescaled, u1_rescaled, t);
y2_rescaled = lsim(G_rescaled, u2_rescaled, t);

% Plot responses
figure;
subplot(2,2,1); 
plot(t, y1_original, 'LineWidth', 2); 
title('Maximum Gain Original');
xlabel('Time (seconds)'); ylabel('Amplitude');
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
grid on;

subplot(2,2,2); 
plot(t, y2_original, 'LineWidth', 2); 
title('Minimum Gain Original');
xlabel('Time (seconds)'); ylabel('Amplitude');
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
grid on;

subplot(2,2,3); 
plot(t, y1_rescaled, 'LineWidth', 2); 
title('Maximum Gain Rescaled');
xlabel('Time (seconds)'); ylabel('Amplitude');
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
grid on;

subplot(2,2,4); 
plot(t, y2_rescaled, 'LineWidth', 2); 
title('Minimum Gain Rescaled');
xlabel('Time (seconds)'); ylabel('Amplitude');
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
grid on;

legend(G.OutputName, 'FontSize', 20, 'FontName', 'Times New Roman', 'Location', 'best');
