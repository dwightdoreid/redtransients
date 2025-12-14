function [ddelta, domega, dPm] = tse_rhs_classical_gov(params, tk, delta, omega, Pm, H, D, E_mag, R, Tg)
  Yred = tse_select_Yred(params, tk);
  Pe = electrical_power(Yred, E_mag, delta);

  ddelta = omega - 1;
  domega = (Pm - Pe - D .* (omega - 1)) ./ (2 .* H);

  % Scheduled baseline mechanical power
  Pm0 = tse_select_Pm0(params, tk);

  % Droop reference
  Pm_ref = Pm0 + (1 ./ R) .* (1 - omega);

  % Turbine/governor lag
  dPm = (Pm_ref - Pm) ./ Tg;
end



##function [ddelta, domega, dPm] = tse_rhs_classical_gov(params, tk, delta, omega, Pm, Pm0, H, D, E_mag, R, Tg)
##  Yred = tse_select_Yred(params, tk);
##  Pe = electrical_power(Yred, E_mag, delta);
##
##  ddelta = omega - 1;
##  domega = (Pm - Pe - D .* (omega - 1)) ./ (2 .* H);
##
##  % Droop reference
##  Pm_ref = Pm0 + (1 ./ R) .* (1 - omega);
##
##  % Turbine/governor lag
##  dPm = (Pm_ref - Pm) ./ Tg;
##end
