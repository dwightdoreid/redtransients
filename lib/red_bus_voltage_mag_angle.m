function [Vm, Va_deg, Vc] = red_bus_voltage_mag_angle(y, nb)
  % y: (2*nb) x nt OR nt x (2*nb)
  % Returns:
  %   Vc: nb x nt complex voltages
  %   Vm: nb x nt magnitudes
  %   Va_deg: nb x nt angles in degrees

  % Ensure y is (2*nb) x nt
  if rows(y) ~= 2*nb
    y = y.';   % assume nt x (2*nb) -> transpose
  endif

  Vr = y(1:nb, :);
  Vi = y(nb+1:2*nb, :);

  Vc = Vr + 1j*Vi;
  Vm = abs(Vc);
  Va_deg = angle(Vc) * 180/pi;
endfunction

