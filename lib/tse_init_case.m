function init = tse_init_case(mpc, Xd_prime)
  % Run PF
  pf = runpf(mpc);

  % Buses
  gen_bus  = find(mpc.bus(:,2) == 2 | mpc.bus(:,2) == 3);
  load_bus = find(mpc.bus(:,3) > 0 | mpc.bus(:,4) > 0);

  % Generator power in pu
  S_gen_pu = complex(pf.gen(:,2), pf.gen(:,3)) / mpc.baseMVA;

  % Generator terminal voltages (complex)
  Vmag_g = pf.bus(gen_bus, 8);
  Vang_g = deg2rad(pf.bus(gen_bus, 9));
  Vt = Vmag_g .* exp(1j * Vang_g);

  % Currents (pu): I = conj(S/V)
  I_gen = conj(S_gen_pu ./ Vt);

  % Internal EMF: E' = V + jX'd I  (classical model)
  Xd_prime = Xd_prime(:);
  E = Vt + 1j * (Xd_prime .* I_gen);

  init = struct();
  init.pf = pf;
  init.gen_bus = gen_bus;
  init.load_bus = load_bus;

  init.E = E;
  init.E_mag = abs(E);
  init.delta0 = angle(E);
  init.omega0 = ones(length(init.E_mag), 1);

  % For load shunt conversion
  init.Vmag_load = pf.bus(load_bus, 8);
  init.Pload_MW  = pf.bus(load_bus, 3);
  init.Qload_MVAr= pf.bus(load_bus, 4);
end
