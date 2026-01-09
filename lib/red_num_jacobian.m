function J = red_num_jacobian(F, z)
  n = length(z);
  J = zeros(n,n);
  eps0 = 1e-6;

  for i = 1:n
    zp = z; zm = z;
    h = eps0 * max(1.0, abs(z(i)));
    zp(i) += h;
    zm(i) -= h;
    J(:,i) = (F(zp) - F(zm)) / (2*h);
  endfor
endfunction

