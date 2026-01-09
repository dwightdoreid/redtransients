function fx = red_f_multi_2axis_gov(x, y, t, sys)
  ng = sys.ng;
  ix = sys.ix;

  Xd = sys.Xd;
  Xq = sys.Xq;
  Xdp = sys.Xdp;
  Xqp = sys.Xqp;
  Td0p = sys.Td0p;
  Tq0p = sys.Tq0p;
  Ra = sys.Ra;
  Ep = sys.Ep;

  delta = x(ix.delta);
  omega = x(ix.omega);
  Pm    = x(ix.Pm);
  Eqp   = x(ix.Eqp);

  Efd = 0.1*ones(ng,1);

  nb = sys.nb;
  Vr = y(1:nb);
  Vi = y(nb+1:2*nb);

  [Ig, Pe, Vd, Vq] = red_gen_injection_2axis(delta, Vr, Vi, sys); %#ok<ASGLU>
  V = Vr + j.*Vi;
  Vd = Vd';
  Vq = Vq';
  Ep;
  Xdp;
  Id = -(Vq - Ep)./Xdp;   %Id = (Vq - Ep)./Xdp, negate for gen power direction
  Iq = (Vd./Xdp);    %Iq = (Vd./Xdp), negate for gen power direction
  Pe = (Vq.*Iq) + (Vd.*Id);
  Pe;
  Eqp;
  Xd;
  Xdp;
  Id;
  Td0p;
  Efd;


  dEqp = (Efd - Eqp - (Xd - Xdp).*Id).*(1./sys.Td0p);

  % Swing
  ddelta = sys.wb * (omega - 1.0);
  domega = (1./(2*sys.H)) .* (Pm - Pe - sys.D .* (omega - 1.0));

  % Governor droop + first-order lag
  dw = (omega - 1.0);
  Pref = sys.Pm0 - (1./sys.R).*dw;

  % Optional saturation on Pref
  Pref = min(max(Pref, sys.Pm_min), sys.Pm_max);

  dPm = (1./sys.Tg) .* (Pref - Pm);

  fx = [ddelta; domega; dPm; dEqp];
endfunction

