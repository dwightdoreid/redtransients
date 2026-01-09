function z = red_dae_step_trap_newton(z0, xk, yk, fk, tk1, h, sys)
  z = z0;
  maxit = 15;
  tolR = 1e-8;
  tolDz = 1e-9;

  for it = 1:maxit
    R = red_dae_residual_trap(z, xk, yk, fk, tk1, h, sys);

    if norm(R,2) < tolR
      return;
    endif

    % Numerical Jacobian
    F = @(zz) red_dae_residual_trap(zz, xk, yk, fk, tk1, h, sys);
    J = red_num_jacobian(F, z);

    dz = -J \ R;
    z  = z + dz;

    if norm(dz,2) < tolDz
      return;
    endif
  endfor

  error('Newton failed at t = %.6f (||R||=%.3e)', tk1, norm(R,2));
endfunction

