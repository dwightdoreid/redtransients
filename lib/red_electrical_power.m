function [Pe, E, I] = electrical_power(Yred, E_mag, delta_rad)
  E = E_mag(:) .* exp(1j * delta_rad(:));
  I = Yred * E;
  Pe = real(E .* conj(I));
end

