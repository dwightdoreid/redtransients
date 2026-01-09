function g = red_g_network_kcl(x, y, sys)
  nb = sys.nb;
  ng = sys.ng;

  Vr = y(1:nb);
  Vi = y(nb+1:2*nb);
  V  = Vr + 1j*Vi;

  Inet = sys.Ybus * V;

  Iinj = zeros(nb,1);

  delta = x(1:ng);
  %[Ig, ~] = red_gen_injection_classical(delta, Vr, Vi, sys);
  [Ig, ~] = red_gen_injection_2axis(delta, Vr, Vi, sys);


  for i = 1:ng
    k = sys.gen_bus(i);
    Iinj(k) += Ig(i);
  endfor

  r = Inet - Iinj;
  g = [real(r); imag(r)];
endfunction

