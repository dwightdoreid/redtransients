function [x0, y0, sys] = red_init_states_from_pf_2axis_matched(sys)
  define_constants;

  nb = sys.nb;
  ng = sys.ng;

  % PF bus voltages
  Vm = sys.bus(:, VM);
  Va = sys.bus(:, VA) * pi/180;
  V  = Vm .* exp(1j*Va);

  % y0 in rectangular
  y0 = [real(V); imag(V)];

  % Generator PF powers (pu on system base)
  Pg = sys.gen(:, PG) / sys.baseMVA;
  Qg = sys.gen(:, QG) / sys.baseMVA;
  Sg = Pg + 1j*Qg;

  Ep  = zeros(ng,1);
  del = zeros(ng,1);

  for i = 1:ng
    k = sys.gen_bus(i);
    Vt = V(k);

    Ig = conj(Sg(i) / Vt);              % injected current into network

    E  = Vt + 1j*sys.Xdp(i)*Ig;         % E' behind jXdp
    Ep(i)  = abs(E);
    del(i) = angle(E);
  endfor

  % Store matched Ep back into sys (so dynamics uses the correct E')
  sys.Ep = Ep;

  % Speeds at equilibrium
  omg0 = ones(ng,1);

  % ...
  sys.Pm0 = Pg;          % store initial mechanical power
  Pm0 = sys.Pm0;
  Eq0 = Ep;

  x0 = [del; omg0; Pm0; Eq0];


##  x0 = [del; omg0];

  % Also set mechanical power = electrical power at PF (good equilibrium)
  sys.Pm = Pg;   % (pu on system base)
endfunction

