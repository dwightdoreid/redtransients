clear; clc;

mpc = loadcase('case9');

Xd_prime = [0.25 0.25 0.25].';
H = [3.5 4.0 3.0].';
D = zeros(3,1);

sim = struct();
sim.dt = 0.01;
sim.t_end = 10.0;

events = struct([]);

% Example: 3φ fault at bus 7 at t=1.0s, clear at 1.10s, then trip 7-8
events(1).t = 1.0;
events(1).type = "fault_bus";
events(1).data = struct("bus", 7, "Zf", 1j*1e-6);

events(2).t = 1.10;
events(2).type = "clear_fault_bus";
events(2).data = struct("bus", 7);

events(3).t = 2.0;
events(3).type = "set_Pm0";
events(3).data = struct("gen", 1, "value", 0.0);

events(4).t = 2.0;
events(4).type = "trip_generator";
events(4).data = struct("gen", 1);


[res, rep, params] = tse_run_transient(mpc, Xd_prime, H, D, events, sim);

disp(rep);
printf("Unstable flag: %d\n", res.unstable);

% Frequency plots (50 Hz)
f_nom = 50;
f_gen = f_nom * res.omega;
omega_coi = (res.omega * params.H) / sum(params.H);
f_coi = f_nom * omega_coi;

figure; plot(res.t, f_gen, 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Frequency (Hz)'); title('Generator Frequencies'); grid on; legend();

figure; plot(res.t, f_coi, 'k', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Frequency (Hz)'); title('COI Frequency'); grid on;

figure; plot(res.t, res.Pm); grid on; legend();
xlabel('Time (s)'); ylabel('Pm (pu)');
title('Mechanical power states (Pm)');
