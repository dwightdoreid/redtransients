function red_plot_results_sp(sys, res)
  t = res.t;
  x = res.x;
  y = res.y;

  % ---- Data Processing ----
  ng = sys.ng;
  delta = x(1:ng,:).';
  omega = x(ng+1:2*ng,:).';
  pm = x(ng+3:3*ng,:).';

##  disp([ng size(delta) size(omega) size(pm) size(x)]);

  [w_coi, f_coi, df_coi] = red_coi_frequency(omega, sys.H, sys.f);

  delta_unw = unwrap(delta);
  [delta_coi, delta_rel] = red_coi_angles(delta_unw, sys.H);

  ref = 1;  % choose generator index
  delta_ref = delta_unw - delta_unw(:,ref);
  delta_ref_180 = red_wrap180(delta_ref * 180/pi);

  df_mach = sys.f * (omega - 1.0);
  [Vm, Va_deg, Vc] = red_bus_voltage_mag_angle(y, sys.nb);

  % --- Line flows ---
  flows = red_calc_line_flows(sys, y);

  % Example: plot active power on a chosen branch index


  % ---- Consolidated Plotting ----
  figure('Name', 'System Simulation Results', 'NumberTitle', 'off');

  % 1. Generator Speeds
  subplot(3, 2, 1);
  plot(t, omega); grid on;
  xlabel('Time (s)'); ylabel('\omega (pu)');
  title('Speeds');
  red_auto_legend('G',ng);

  % 2. Bus Voltage Magnitudes
  subplot(3, 2, 2);
  plot(t, Vm.'); grid on;
  xlabel('Time (s)'); ylabel('|V| (pu)');
  title('Bus Voltage Magnitudes');
  red_auto_legend('V',sys.nb);

  % 3. Mechanical Power
  subplot(3, 2, 3);
  plot(t, pm); grid on;
  xlabel('Time (s)'); ylabel('Pm (pu)');
  title('Gen Mechanical Power');
  red_auto_legend('G',ng);

  % 4. COI Frequency
  subplot(3, 2, 4);
  plot(t, f_coi); grid on;
  xlabel('Time (s)'); ylabel('f_{COI} (Hz)');
  title('COI Frequency');

  % 5. Rotor Angles
  subplot(3, 2, 5);
  plot(t, delta_ref_180); grid on;
  xlabel('Time (s)');
  ylabel(sprintf('\\delta_i - \\delta_{G%d} (deg)', ref));
  title('Rotor Angles (Ref Machine)');
  red_auto_legend('G',ng);

  % 6. Line Flows
  br = 1;  % pick a branch row index (see sys.branch)
  subplot(3, 2, 6);
  plot(t, flows.Pf(:,:)); grid on;
  title(sprintf('Line Flows', br, flows.fbus(br), flows.tbus(br)));
  xlabel('Time (s)'); ylabel('MW');
  red_auto_legend('L',rows(sys.branch));

  % Or plot MVA magnitude
##  figure; plot(t, abs(flows.Sf(br, :)), 'LineWidth', 1.5); grid on;
##  title(sprintf('Branch %d: |S_from| (bus %d -> %d)', br, flows.fbus(br), flows.tbus(br)));
##  xlabel('Time (s)'); ylabel('MVA');

  % Optional: Tighten the layout to prevent label overlap
  % If using a recent version of Octave/Matlab:
  % tight_layout();
endfunction
