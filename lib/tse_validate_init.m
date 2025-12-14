function report = tse_validate_init(params)
  % Checks consistency at t=0 using the network segment active at tk=0:
  % - Computes Pe0 from (Yred(t=0), E', delta0)
  % - Compares to Pm if provided
  % - Checks acceleration ~ 0

  H = params.H(:);
  D = params.D(:);
  E_mag  = params.E_mag(:);
  delta0 = params.delta0(:);
  omega0 = params.omega0(:);

  % Use current network model at t=0
  Yred0 = tse_select_Yred(params, 0);

  Pe0 = electrical_power(Yred0, E_mag, delta0);

  if isfield(params, 'Pm') && ~isempty(params.Pm)
    Pm = params.Pm(:);
  else
    Pm = Pe0;
  end

  domega0 = (Pm - Pe0 - D .* (omega0 - 1)) ./ (2 .* H);

  report = struct();
  report.Pe0 = Pe0;
  report.Pm  = Pm;
  report.mismatch_P = Pm - Pe0;
  report.max_abs_mismatch_P = max(abs(report.mismatch_P));
  report.domega0 = domega0;
  report.max_abs_domega0 = max(abs(domega0));

  report.warn_P_mismatch = (report.max_abs_mismatch_P > 1e-4);
  report.warn_accel      = (report.max_abs_domega0 > 1e-4);
end


##function report = tse_validate_init(params)
##  H = params.H(:); D = params.D(:);
##  E_mag = params.E_mag(:);
##  delta0 = params.delta0(:);
##  omega0 = params.omega0(:);
##
##  Pe0 = electrical_power(params.Yred_pre, E_mag, delta0);
##
##  if isfield(params, 'Pm') && ~isempty(params.Pm)
##    Pm = params.Pm(:);
##  else
##    Pm = Pe0;
##  end
##
##  domega0 = (Pm - Pe0 - D .* (omega0 - 1)) ./ (2 .* H);
##
##  report = struct();
##  report.Pe0 = Pe0;
##  report.Pm = Pm;
##  report.mismatch_P = Pm - Pe0;
##  report.max_abs_mismatch_P = max(abs(report.mismatch_P));
##  report.domega0 = domega0;
##  report.max_abs_domega0 = max(abs(domega0));
##  report.warn_P_mismatch = (report.max_abs_mismatch_P > 1e-4);
##  report.warn_accel = (report.max_abs_domega0 > 1e-4);
##end

