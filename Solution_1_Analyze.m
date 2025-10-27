% ════════════════════════════════════════════════════════════
% Solution: Question 1 - วิเคราะห์
% Process: Cooling Tower
% Controller: P | Method: Root Locus
% Student ID: [67015133]
% ════════════════════════════════════════════════════════════

clear; clc; close all;

% ═══ Plant Transfer Function ═══
G = tf(0.50, conv([6.11 1],[4.40 1]), 'InputDelay', 7.40);
fprintf('Plant: G(s) = 0.50*exp(-7.40*s)/((6.11*s+1)*(4.40*s+1))\n');
fprintf('Type: SOPDT\n\n');

% Parameters:
fprintf('  K = 0.50 degC per m3 per min\n');
fprintf('  tau1 = 6.11 min\n');
fprintf('  tau2 = 4.40 min\n');
fprintf('  theta = 7.40 min\n');
fprintf('\n');

% ═══ Controller Design ═══
% TODO: Design your P controller here

Kp = 0.5;  % TO BE TUNED
C = tf(Kp, 1);

% ═══ System Analysis ═══
L = C * G;
T = feedback(L, 1);

% Stability Margins
[Gm, Pm, Wcg, Wcp] = margin(L);
fprintf('═══ Stability Margins ═══\n');
fprintf('Gain Margin:  %.2f dB\n', 20*log10(Gm));
fprintf('Phase Margin: %.2f deg\n\n', Pm);

% Time-domain Performance
info = stepinfo(T);
fprintf('═══ Time-Domain Performance ═══\n');
fprintf('Rise Time:     %.3f\n', info.RiseTime);
fprintf('Settling Time: %.3f\n', info.SettlingTime);
fprintf('Overshoot:     %.2f%%\n\n', info.Overshoot);

% ═══ Plots ═══
figure('Position', [100 100 1400 900]);

% Root Locus
subplot(2,3,1)
try
    if G.InputDelay > 0 || G.OutputDelay > 0
        % Approximate delay with Pade
        G_approx = pade(G, 2);  % 2nd order Pade approximation
        rlocus(G_approx*C)
        title('Root Locus (with Pade approximation)')
    else
        rlocus(G*C)
        title('Root Locus')
    end
catch
    rlocus(G*C)
    title('Root Locus')
end
grid on

% Step Response
subplot(2,3,2)
step(T)
title('Closed-Loop Step Response')
grid on

% Pole-Zero Map
subplot(2,3,3)
try
    % Check if system has delay
    if T.InputDelay > 0 || T.OutputDelay > 0
        % Use Pade approximation for systems with delay
        T_approx = pade(T, 2);  % 2nd order Pade approximation
        pzmap(T_approx)
        title('Pole-Zero Map (Pade Approx.)')
    else
        pzmap(T)
        title('Pole-Zero Map')
    end
catch ME
    % If pzmap fails, show text message
    text(0.5, 0.5, {'Pole-Zero Map', 'Cannot display for', 'system with delay', '', 'Use: T_approx = pade(T,2)', 'Then: pzmap(T_approx)'}, ...
         'HorizontalAlignment', 'center', 'FontSize', 10)
    axis off
end
grid on

% Sensitivity Function
subplot(2,3,4)
S = feedback(1, L);  % Sensitivity
T_comp = feedback(L, 1);  % Complementary sensitivity
bodemag(S, T_comp)
legend('Sensitivity S', 'Complementary T', 'Location', 'best')
title('Sensitivity Analysis')
grid on

% Disturbance Rejection
subplot(2,3,5)
Gd = feedback(G, C);  % Disturbance to output
step(Gd)
title('Load Disturbance Response')
ylabel('Output deviation')
grid on

% Control Effort
subplot(2,3,6)
Gu = feedback(C, G);  % Reference to control signal
step(Gu)
title('Control Signal (u)')
ylabel('Controller output (%)')  
grid on

% ═══ Additional Analysis ═══
% If you need to see pole-zero map for system with delay:
% T_approx = pade(T, 3);  % Use 3rd order for better accuracy
% figure;
% pzmap(T_approx)
% grid on
% title('Pole-Zero Map with Pade Approximation')

% ═══ End of Solution ═══
fprintf('\n✓ Analysis complete!\n');
