function results = red_run_transient(sys)

  define_constants;

  ng = sys.ng;
  ix.delta = 1:ng;
  ix.omega = (ng+1):(2*ng);
  ix.Pm    = (2*ng+1):(3*ng);
  ix.Eqp    = (3*ng+1):(4*ng);
  sys.ix = ix;   % store in sys so functions can access


  % ---- Initialize x0, y0 from power flow ----
  [x0, y0, sys] = red_init_states_from_pf_2axis_matched(sys);

  fk0 = red_f_multi_2axis_gov(x0, y0, 0.0, sys);
  g0  = red_g_network_kcl(x0, y0, sys);

  fprintf('Init ||g|| = %.3e\n', norm(g0,2));
  fprintf('Init ||f|| = %.3e\n', norm(fk0,2));
  fprintf('Max |omega_dot| approx = %.3e\n', max(abs(fk0(sys.ng+1:2*sys.ng))));
  fprintf('Max |Pm_dot|    = %.3e\n', max(abs(fk0(sys.ix.Pm))));

  % ---- Simulation settings ----
  h = sys.sim.ts;
  t_end = sys.sim.t_end;
  t = (0:h:t_end).';
  nt = length(t);

  nx = length(x0);
  ny = length(y0);

  x = zeros(nx, nt);
  y = zeros(ny, nt);
  x(:,1) = x0;
  y(:,1) = y0;

  sim_events = sys.sim_events;

  % ---- Time stepping ----
  Ybus_current = sys.Ybus_base;
  fault_state = struct();  % holds active fault shunts etc.

  for k = 1:nt-1
    tk  = t(k);
    tk1 = t(k+1);

    % Apply any events happening at tk1 (or within this step)
    [Ybus_current, fault_state] = red_apply_events(Ybus_current, fault_state, sim_events, tk1);

    sys.Ybus = Ybus_current;

    fk = red_f_multi_2axis_gov(x(:,k), y(:,k), tk, sys);

    % Predictor
    z0 = [x(:,k) + h*fk; y(:,k)];

    % Newton trapezoid step (simultaneous x,y)
    z = red_dae_step_trap_newton(z0, x(:,k), y(:,k), fk, tk1, h, sys);

    x(:,k+1) = z(1:nx);
    y(:,k+1) = z(nx+1:end);

    ng = sys.ng;
    delta = x(1:ng,:).';
    omega = x(ng+1:2*ng,:).';
    pm = x(ng+3:3*ng,:).';
    [w_coi, f_coi, df_coi] = red_coi_frequency(omega, sys.H, sys.f);

    printf('\r Percentage: %d   ', ((tk+h)/t_end)*100);
  endfor
  printf('\n');

  results = struct();
  results.t = t;
  results.x = x;
  results.y = y;
endfunction
