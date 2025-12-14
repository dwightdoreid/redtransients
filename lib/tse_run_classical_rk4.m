function results = tse_run_classical_rk4(params)
  dt = params.dt; t_end = params.t_end;

  H = params.H(:); D = params.D(:);
  E_mag = params.E_mag(:);

  delta = params.delta0(:);
  omega = params.omega0(:);

  ng = length(E_mag);

  % --- Governor params ---
  use_gov = isfield(params, "gov") && params.gov.enable;
  if use_gov
    R  = params.gov.R(:);          % ngx1
    Tg = params.gov.Tg(:);         % ngx1
  end

  % Initial mechanical power state Pm(0)
  if isfield(params, "Pm_init") && ~isempty(params.Pm_init)
    Pm = params.Pm_init(:);
  else
    % Default: start at scheduled baseline at t=0 (steady state)
    Pm = tse_select_Pm0(params, 0);
  end


  nsteps = floor(t_end/dt) + 1;
  t = (0:(nsteps-1))' * dt;

  delta_hist = zeros(nsteps, ng);
  omega_hist = zeros(nsteps, ng);
  Pe_hist    = zeros(nsteps, ng);
  Pm_hist    = zeros(nsteps, ng);
  coi_hist   = zeros(nsteps, 1);
  sep_hist   = zeros(nsteps, 1);

  for k = 1:nsteps
    tk = t(k);

    Yredk = tse_select_Yred(params, tk);
    Pe_k  = electrical_power(Yredk, E_mag, delta);

    delta_hist(k,:) = delta.';
    omega_hist(k,:) = omega.';
    Pe_hist(k,:)    = Pe_k.';
    Pm_hist(k,:)    = Pm.';

    dcoi = tse_coi(delta, H);
    coi_hist(k) = dcoi;
    rel = delta - dcoi;
    sep_hist(k) = max(rel) - min(rel);

    if k == nsteps, break; end

    % RK4 on [delta, omega, Pm] if governor enabled; else [delta, omega]
    if use_gov
##      [k1_d, k1_w, k1_pm] = tse_rhs_classical_gov(params, tk,       delta,              omega,              Pm,              Pm0, H, D, E_mag, R, Tg);
##      [k2_d, k2_w, k2_pm] = tse_rhs_classical_gov(params, tk+dt/2,  delta + dt/2*k1_d,  omega + dt/2*k1_w,  Pm + dt/2*k1_pm, Pm0, H, D, E_mag, R, Tg);
##      [k3_d, k3_w, k3_pm] = tse_rhs_classical_gov(params, tk+dt/2,  delta + dt/2*k2_d,  omega + dt/2*k2_w,  Pm + dt/2*k2_pm, Pm0, H, D, E_mag, R, Tg);
##      [k4_d, k4_w, k4_pm] = tse_rhs_classical_gov(params, tk+dt,    delta + dt*k3_d,    omega + dt*k3_w,    Pm + dt*k3_pm,    Pm0, H, D, E_mag, R, Tg);

      [k1_d, k1_w, k1_pm] = tse_rhs_classical_gov(params, tk,       delta,              omega,              Pm,              H, D, E_mag, R, Tg);
      [k2_d, k2_w, k2_pm] = tse_rhs_classical_gov(params, tk+dt/2,  delta + dt/2*k1_d,  omega + dt/2*k1_w,  Pm + dt/2*k1_pm, H, D, E_mag, R, Tg);
      [k3_d, k3_w, k3_pm] = tse_rhs_classical_gov(params, tk+dt/2,  delta + dt/2*k2_d,  omega + dt/2*k2_w,  Pm + dt/2*k2_pm, H, D, E_mag, R, Tg);
      [k4_d, k4_w, k4_pm] = tse_rhs_classical_gov(params, tk+dt,    delta + dt*k3_d,    omega + dt*k3_w,    Pm + dt*k3_pm,   H, D, E_mag, R, Tg);

      delta = delta + (dt/6) * (k1_d + 2*k2_d + 2*k3_d + k4_d);
      omega = omega + (dt/6) * (k1_w + 2*k2_w + 2*k3_w + k4_w);
      Pm    = Pm    + (dt/6) * (k1_pm+ 2*k2_pm+ 2*k3_pm+ k4_pm);

    else
      % Old behavior (constant Pm)
      Pm_const = Pm; %#ok
      [k1_d, k1_w] = tse_rhs_classical_constPm(params, tk,       delta,              omega,              Pm_const, H, D, E_mag);
      [k2_d, k2_w] = tse_rhs_classical_constPm(params, tk+dt/2,  delta + dt/2*k1_d,  omega + dt/2*k1_w,  Pm_const, H, D, E_mag);
      [k3_d, k3_w] = tse_rhs_classical_constPm(params, tk+dt/2,  delta + dt/2*k2_d,  omega + dt/2*k2_w,  Pm_const, H, D, E_mag);
      [k4_d, k4_w] = tse_rhs_classical_constPm(params, tk+dt,    delta + dt*k3_d,    omega + dt*k3_w,    Pm_const, H, D, E_mag);

      delta = delta + (dt/6) * (k1_d + 2*k2_d + 2*k3_d + k4_d);
      omega = omega + (dt/6) * (k1_w + 2*k2_w + 2*k3_w + k4_w);
    end

    delta = mod(delta + pi, 2*pi) - pi;
  end

  results = struct();
  results.t = t;
  results.delta = delta_hist;
  results.omega = omega_hist;
  results.Pe = Pe_hist;
  results.Pm = Pm_hist;
  results.delta_coi = coi_hist;
  results.sep = sep_hist;
  results.unstable = any(sep_hist > pi);
end
