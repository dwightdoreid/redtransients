function [ddelta, domega] = tse_rhs_classical_constPm(params, tk, delta, omega, Pm, H, D, E_mag)
  Yred = tse_select_Yred(params, tk);
  Pe = electrical_power(Yred, E_mag, delta);

  ddelta = omega - 1;
  domega = (Pm - Pe - D .* (omega - 1)) ./ (2 .* H);
end
