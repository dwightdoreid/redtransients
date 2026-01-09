function sys = build_sys_from_matpower(mpc)
  % Load MATPOWER case
##  mpc = loadcase('case9');
  define_constants;

  % Run power flow
  mpopt = mpoption('verbose', 1, 'out.all', 1);
  r = runpf(mpc, mpopt);
  if ~r.success
    error('Power flow failed for case');
  endif

  % Build Ybus from PF result (includes taps, shunts, etc.)
##  [Ybus, ~, ~] = makeYbus(r.baseMVA, r.bus, r.branch);

  [Ybus, Yf, Yt] = makeYbus(r.baseMVA, r.bus, r.branch);

  sys = struct();

  sys.Ybus_base = Ybus;
  sys.Ybus = Ybus;

  % Store branch flow helpers
  sys.Yf = Yf;      % nl x nb
  sys.Yt = Yt;      % nl x nb
  sys.branch = r.branch;   % already stored in your file, keep it
  sys.bus    = r.bus;
  sys.baseMVA = r.baseMVA;


##  sys = struct();
  sys.mpc = r;
##  sys.baseMVA = r.baseMVA;

  sys.bus = r.bus;
  sys.branch = r.branch;
  sys.gen = r.gen;

  sys.nb = size(r.bus, 1);
  sys.ng = size(r.gen, 1);

  % MATPOWER bus numbering is 1..nb for case9, but we’ll still map safely:
  sys.gen_bus = r.gen(:, GEN_BUS);

  % Store Ybus
  sys.Ybus_base = Ybus;
  sys.Ybus = Ybus;

  % --- Add constant-impedance load model as shunts (derived from PF) ---
  Vm = r.bus(:, VM);
  Va = r.bus(:, VA) * pi/180;
  V  = Vm .* exp(1j*Va);

  Pd = r.bus(:, PD) / r.baseMVA;   % pu
  Qd = r.bus(:, QD) / r.baseMVA;   % pu
  Sload = Pd + 1j*Qd;

  Yload = zeros(sys.nb,1);
  for k = 1:sys.nb
    if abs(Sload(k)) > 0
      Yload(k) = conj(Sload(k)) / (abs(V(k))^2);
    endif
  endfor

  sys.Yload = Yload;
  sys.Ybus_base = Ybus + diag(Yload);
  sys.Ybus = sys.Ybus_base;

  sys.mpc_base = r;
  sys.mpc_current = r;

  % If you added load shunts by modifying Ybus only, do it by modifying r.bus instead:
  % (recommended) write Yload into r.bus(:,GS/BS) and then makeYbus() uses it.

  sys.Ybus_base = sys.Ybus_base;  % already computed with load shunts
  sys.Ybus = sys.Ybus_base;

##  % Frequency
##  sys.f = 60;
##  sys.wb = 2*pi*sys.f;
##
##  % --- Classical model parameters (you can tune these) ---
##  % Transient reactances Xd' (pu)
##  sys.Xdp = [0.30; 0.25; 0.20];   % example values
##  % Internal emf magnitudes E' (pu) (initially ~1.05–1.15 typical)
##  sys.Ep  = [1.10; 1.08; 1.06];
##
##  % Inertia constants H (s)
##  sys.H = [3.5; 4.0; 3.0];
##  % Damping
##  sys.D = [1.0; 1.0; 1.0];
##
##    % --- Simple governor parameters ---
##  sys.R  = [0.05; 0.05; 0.05];   % droop (pu speed / pu power) ~ 5%
##  sys.Tg = [0.20; 0.25; 0.20];   % governor+turbine lag (s)
##
  % Optional limits
  sys.Pm_min = [0.0; 0.0; 0.0];
  sys.Pm_max = [2.0; 2.0; 2.0];


  % Mechanical power Pm (pu on system base)
  % Use PF Pg as a good starting point: Pg (MW)/baseMVA
  Pg_MW = r.gen(:, PG);
  sys.Pm = Pg_MW / r.baseMVA;
endfunction

