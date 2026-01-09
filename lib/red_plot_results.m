function plot_results(sys, res)
  t = res.t;
  x = res.x;
  y = res.y;
  % ---- Plots ----
  ng = sys.ng;
  delta = x(1:ng,:).';
  omega = x(ng+1:2*ng,:).';
  pm = x(ng+4:3*ng,:).';

  % omega: nt x ng (pu)
  [w_coi, f_coi, df_coi] = coi_frequency(omega, sys.H, sys.f);

  % delta: nt x ng (rad)
  delta_unw = unwrap(delta);                 % helps avoid ugly jumps
  [delta_coi, delta_rel] = coi_angles(delta_unw, sys.H);

  delta_rel_deg = delta_rel * 180/pi;
  delta_rel_180 = wrap180(delta_rel_deg);    % [-180,180)

  ref = 1;  % choose generator index
  delta_unw = unwrap(delta);
  delta_ref = delta_unw - delta_unw(:,ref);

  delta_ref_deg = delta_ref * 180/pi;
  delta_ref_180 = wrap180(delta_ref_deg);

  df_mach = sys.f * (omega - 1.0);  % nt x ng

  [Vm, Va_deg, Vc] = bus_voltage_mag_angle(y, sys.nb);

  figure;
  plot(t, omega); grid on;
  xlabel('Time (s)'); ylabel('\omega (pu)');
  legend('G1','G2','G3');
  title('IEEE-9 Classical: Speeds');

  figure;
  plot(t, Vm.'); grid on;
  xlabel('Time (s)'); ylabel('|V| (pu)');
  title('All Bus Voltage Magnitudes');

  figure;
  plot(t, pm); grid on;
  xlabel('Time (s)');
  ylabel('Pm (pu)');
  title('Generator Mechanical Power');

  figure;
  plot(t, f_coi); grid on;
  xlabel('Time (s)'); ylabel('f_{COI} (Hz)');
  title('COI Frequency');

  figure;
  plot(t, delta_ref_180); grid on;
  xlabel('Time (s)');
  ylabel(sprintf('\\delta_i - \\delta_{G%d} (deg)', ref));
  title('Rotor Angle w.r.t. Reference Machine (wrapped) - PSSE common');
  legend('G1','G2','G3');
endfunction

