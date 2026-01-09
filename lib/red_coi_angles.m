function [delta_coi, delta_rel] = red_coi_angles(delta_mat, H)
  % delta_mat: nt x ng (each column is delta_i(t) in rad)
  % H: ng x 1 inertia constants
  %
  % delta_coi: nt x 1
  % delta_rel: nt x ng  (delta_i - delta_coi)

  H = H(:);
  denom = sum(H);

  delta_coi = (delta_mat * H) / denom;      % nt x 1
  delta_rel = delta_mat - delta_coi;        % broadcasts nt x 1 across columns
endfunction

