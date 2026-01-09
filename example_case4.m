close all;
clear;
clear functions;
clc;
tic;

%-------------------------------------------------------------------------------
%Simulation settings
%-------------------------------------------------------------------------------
dt = 0.005;
t_end = 5.0;
%-------------------------------------------------------------------------------
%Load matpower case and create transient system
%-------------------------------------------------------------------------------
define_constants;
mpc = loadcase('case4gs');
sys = red_build_sys_from_matpower(mpc);
%-------------------------------------------------------------------------------
%Simulation events
%-------------------------------------------------------------------------------
sim_events = {};
sim_events{end+1} = struct("t", 1.0,  "type", "fault_shunt",...
               "data", struct("bus", 4, "Ysh", -1j*1e6));
sim_events{end+1} = struct("t", 1.06, "type", "clear_fault",...
               "data", struct("bus", 4));

##sim_events{end+1} = struct("t", 1.0,  "type", "fault_shunt",...
##               "data", struct("bus", 2, "Ysh", 1.2 - j*0.3));
##sim_events{end+1} = struct("t", 10.06, "type", "clear_fault",...
##               "data", struct("bus", 2));
%-------------------------------------------------------------------------------
%Add generator transient parameters and values
%-------------------------------------------------------------------------------
% Frequency
sys.f = 50;
sys.wb = 2*pi*sys.f;

% --- Classical model parameters (you can tune these) ---
% Transient reactances Xd' (pu)
sys.Xdp = [0.30; 0.25];   % example values
% Internal emf magnitudes E' (pu) (initially ~1.05–1.15 typical)
sys.Ep  = [1.10; 1.08];

% Inertia constants H (s)
sys.H = [3.5; 4.0];
% Damping
sys.D = [1.0; 1.0];

% --- Simple governor parameters ---
sys.R  = [0.05; 0.05];   % droop (pu speed / pu power) ~ 5%
sys.Tg = [0.20; 0.25];   % governor+turbine lag (s)

% Optional limits
sys.Pm_min = [0.0; 0.0];
sys.Pm_max = [4.0; 2.0];


% --- 2-Axis Model Parameters ---
sys.Xd   = [1.80; 1.90];
sys.Xq   = [1.70; 1.80];
sys.Xdp  = [0.30; 0.25];   # already used in classical
sys.Xqp  = [0.55; 0.50];
sys.Td0p = [8.0;  6.5];
sys.Tq0p = [0.4;  0.5];
sys.Ra   = zeros(sys.ng,1);
%-------------------------------------------------------------------------------
%Apply simulation settings
%-------------------------------------------------------------------------------
sim.ts = dt;
sim.t_end = t_end;
sys.sim = sim;
%-------------------------------------------------------------------------------
%Apply simulation events
%-------------------------------------------------------------------------------
sys.sim_events = sim_events;
%-------------------------------------------------------------------------------

res = red_run_transient(sys);
red_plot_results_sp(sys,res);

elapsed_time = toc; % Get elapsed seconds
printf("The process took %f seconds to complete.\n", elapsed_time);
