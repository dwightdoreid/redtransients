function R = red_dae_residual_trap(z, xk, yk, fk, tk1, h, sys)
  nx = length(xk);
  x = z(1:nx);
  y = z(nx+1:end);

  #fk1 = f_multi_classical(x, y, tk1, sys);
  fk1 = red_f_multi_2axis_gov(x, y, tk1, sys);


  rx = x - xk - 0.5*h*(fk + fk1);
  ry = red_g_network_kcl(x, y, sys);

  R = [rx; ry];
endfunction

