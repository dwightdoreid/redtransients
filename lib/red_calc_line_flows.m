function flows = red_calc_line_flows(sys, y)
  % y = [Vr; Vi] (2*nb x 1) OR (2*nb x nt)
  nb = sys.nb;

  % Allow y to be either a single column or a matrix over time
  if columns(y) == 1
    nt = 1;
  else
    nt = columns(y);
  endif

  nl = size(sys.branch, 1);

  % MATPOWER branch columns (avoid define_constants dependency)
  F_BUS = 1; T_BUS = 2;

  fbus = sys.branch(:, F_BUS);
  tbus = sys.branch(:, T_BUS);

  Sf = zeros(nl, nt);
  St = zeros(nl, nt);

  for k = 1:nt
    Vr = y(1:nb, k);
    Vi = y(nb+1:2*nb, k);
    V  = Vr + 1j*Vi;

    If = sys.Yf * V;    % nl x 1
    It = sys.Yt * V;    % nl x 1

    Vf = V(fbus);
    Vt = V(tbus);

    % Complex power (pu on system base) if sys.Yf/Yt built with baseMVA
    % Multiply by baseMVA if you want MVA.
    Sf(:,k) = Vf .* conj(If) * sys.baseMVA;  % MVA from "from" end
    St(:,k) = Vt .* conj(It) * sys.baseMVA;  % MVA from "to" end
  endfor

  flows.Sf = Sf;                 % nl x nt complex MVA
  flows.St = St;                 % nl x nt complex MVA
  flows.Pf = real(Sf); flows.Qf = imag(Sf);
  flows.Pt = real(St); flows.Qt = imag(St);
  flows.fbus = fbus; flows.tbus = tbus;
endfunction

