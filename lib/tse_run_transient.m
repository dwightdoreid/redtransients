function [res, rep, params] = tse_run_transient(mpc, Xd_prime, H, D, events, sim)
  % sim: struct with dt, t_end

  init = tse_init_case(mpc, Xd_prime);
  aug  = tse_build_augmented_case(mpc, init, Xd_prime);

##  netsets = tse_apply_events(aug, events);
##  yset = tse_build_Yred_set(aug, netsets);
  % -----------------------------
  % Split events: network vs control
  % -----------------------------
  net_types = {"fault_bus", "clear_fault_bus", "trip_branch", "close_branch", "load_shed", "trip_generator"};
  is_net = arrayfun(@(e) any(strcmp(e.type, net_types)), events);
  net_events = events(is_net);
  % Build piecewise-constant network segments from ONLY network events
  if isempty(net_events)
    netsets = struct("t_start", 0, "t_end", inf, "mpc", aug.mpc_aug);
  else
    netsets = tse_apply_events(aug, net_events);
  end

  yset = tse_build_Yred_set(aug, netsets);


  params = struct();
  params.dt = sim.dt;
  params.t_end = sim.t_end;

  params.H = H(:);
  params.D = D(:);
  params.E_mag = init.E_mag(:);
  params.delta0 = init.delta0(:);
  params.omega0 = init.omega0(:);

  params.yset = yset;

  % Initial mechanical power baseline
  Yred0 = tse_select_Yred(params, 0);
  Pe0 = electrical_power(Yred0, params.E_mag, params.delta0);
##  params.Pm0 = Pe0;

  % Baseline mechanical power at t=0 (before governor action)
  Pm0_init = Pe0;

  % Build piecewise schedule for Pm0(t) from events
  params.p0set = tse_apply_p0_events(Pm0_init, events, sim.t_end);

  % Initial mechanical power state (start at baseline)
  params.Pm_init = Pm0_init;

  % Governor settings (enable/droop/lag)
  params.gov = struct();
  params.gov.enable = true;
  params.gov.R  = 0.05 * ones(length(params.E_mag), 1);
  params.gov.Tg = 0.5  * ones(length(params.E_mag), 1);


  % Governor settings (enable / droop / lag)
##  params.gov = struct();
##  params.gov.enable = true;
##  params.gov.R  = 0.05 * ones(length(params.E_mag), 1);  % 5% droop
##  params.gov.Tg = 0.005  * ones(length(params.E_mag), 1);  % 0.5 s lag


##  params.yset = yset;
##
##  % Set Pm from initial prefault segment (t=0)
##  Yred0 = tse_select_Yred(params, 0);
##  Pe0 = electrical_power(Yred0, params.E_mag, params.delta0);
##  params.Pm = Pe0;

  rep = tse_validate_init(params);
  res = tse_run_classical_rk4(params);
end
