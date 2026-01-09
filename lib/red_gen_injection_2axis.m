function [Ig, Pe, Vd, Vq] = red_gen_injection_2axis(delta, Vr, Vi, sys)
  ng = length(delta);

  Xd = sys.Xd;
  Xq = sys.Xq;
  Xdp = sys.Xdp;
  Xqp = sys.Xqp;
  Td0p = sys.Td0p;
  Tq0p = sys.Tq0p;
  Ra = sys.Ra;
  Rs = 0;

  Ig = zeros(ng,1);
  Pe = zeros(ng,1);

  for i = 1:ng
    k = sys.gen_bus(i);
    V = Vr(k) + 1j*Vi(k);

    E = sys.Ep(i) * (cos(delta(i)) + 1j*sin(delta(i)));

    Ig(i) = (E - V) / (1j*sys.Xdp(i));
    Pe(i) = real(V * conj(Ig(i)));

    %----------------------------------------------
    Vmag = abs(V);
    Vang = arg(V);
    Vq(i) = Vmag.*cos(delta(i) - Vang);
    Vd(i) = Vmag.*sin(delta(i) - Vang);

    Imag = abs(Ig(i));
    Iang = arg(Ig(i));
    Iq = Imag*cos(delta(i)+Iang);
    Id = Imag*sin(delta(i)+Iang);

    Eqp = Vq + (Iq*Rs) + Id*Xdp(i);
    Petst = Eqp*Iq+(sys.Xq(i) - sys.Xdp(i))*Iq*Id;
    Pe(i);
##
##    Vq = Xq(i)*Iq;
##    Vd = Eqp - (Xdp(i)*Id);
##    Pc = (Vq*Iq) + (Vd*Id)
##    Petst
    % Pe(i) = Eqp.*Iq.*(sys.Xq(i) - sys.Xdp(i)).*Iq.*Id;
    %----------------------------------------------
  endfor
endfunction

