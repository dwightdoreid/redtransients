function [mpc2, fault_info] = apply_line_fault_to_mpc(mpc, br_idx, pct_from, Zf_pu)
  % Splits branch br_idx at pct_from (%) from its FROM bus, creates a new bus,
  % adds a shunt fault at the new bus with impedance Zf_pu (pu).
  %
  % Returns modified mpc2 and fault_info (so we can clear later).

  % MATPOWER constants (avoid requiring define_constants)
  BUS_I = 1; BUS_TYPE = 2; PD = 3; QD = 4; GS = 5; BS = 6;
  VM = 8; VA = 9; BASE_KV = 10; VMAX = 12; VMIN = 13;

  F_BUS = 1; T_BUS = 2; BR_R = 3; BR_X = 4; BR_B = 5; RATE_A = 6;
  RATE_B = 7; RATE_C = 8; TAP = 9; SHIFT = 10; BR_STATUS = 11; ANGMIN = 12; ANGMAX = 13;

  alpha = pct_from / 100;
  if alpha <= 0 || alpha >= 1
    error('pct_from must be between 0 and 100 (exclusive). Got %.3f', pct_from);
  endif

  mpc2 = mpc;

  % Original branch
  br = mpc2.branch(br_idx, :);
  if br(BR_STATUS) == 0
    error('Branch %d is out of service', br_idx);
  endif

  fbus = br(F_BUS);
  tbus = br(T_BUS);

  % Create new fault bus index
  nb = size(mpc2.bus,1);
  kbus = nb + 1;

  % Copy voltage base settings from FROM bus for sanity
  bus_f = mpc2.bus(fbus, :);
  newbus = zeros(1, size(mpc2.bus,2));
  newbus(BUS_I) = kbus;
  newbus(BUS_TYPE) = 1;      % PQ bus
  newbus(PD) = 0; newbus(QD) = 0;

  % Initialize shunts as 0, we'll add fault shunt below
  newbus(GS) = 0;
  newbus(BS) = 0;

  newbus(VM) = bus_f(VM);
  newbus(VA) = bus_f(VA);
  newbus(BASE_KV) = bus_f(BASE_KV);
  newbus(VMAX) = bus_f(VMAX);
  newbus(VMIN) = bus_f(VMIN);

  mpc2.bus = [mpc2.bus; newbus];

  % Split line parameters proportionally
  r = br(BR_R); x = br(BR_X); b = br(BR_B);

  br1 = br; br2 = br;

  br1(F_BUS) = fbus; br1(T_BUS) = kbus;
  br2(F_BUS) = kbus; br2(T_BUS) = tbus;

  br1(BR_R) = alpha * r;   br1(BR_X) = alpha * x;   br1(BR_B) = alpha * b;
  br2(BR_R) = (1-alpha) * r; br2(BR_X) = (1-alpha) * x; br2(BR_B) = (1-alpha) * b;

  % Remove original branch and append the two new branches
  mpc2.branch(br_idx, BR_STATUS) = 0;      % disable original
  mpc2.branch = [mpc2.branch; br1; br2];

  % Add fault shunt at new bus: Yf = 1/Zf (pu)
  Yf = 1 / Zf_pu;
  mpc2.bus(kbus, GS) = real(Yf) * mpc2.baseMVA;
  mpc2.bus(kbus, BS) = imag(Yf) * mpc2.baseMVA;

  % Return info needed for clearing (optional; we’ll just restore base mpc anyway)
  fault_info = struct("type","line", "orig_branch", br_idx, "fault_bus", kbus, ...
                      "from", fbus, "to", tbus, "alpha", alpha, "Zf", Zf_pu);
endfunction

