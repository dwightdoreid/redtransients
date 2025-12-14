function delta_coi = tse_coi(delta, H)
  delta_coi = sum(H .* delta) / sum(H);
end

