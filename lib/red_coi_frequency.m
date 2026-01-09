function [w_coi, f_coi, df_coi] = red_coi_frequency(omega_mat, H, fbase)
  % omega_mat: nt x ng (each column is a generator omega(t))
  % H: ng x 1 inertia constants
  % fbase: scalar Hz

  H = H(:);
  denom = sum(H);

  % weighted average across generators for each time row
  w_coi = (omega_mat * H) / denom;     % nt x 1

  f_coi  = fbase * w_coi;             % Hz
  df_coi = f_coi - fbase;             % Hz deviation
endfunction

