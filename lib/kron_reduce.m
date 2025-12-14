function Yred = kron_reduce(Y_aug, keep_idx, elim_idx)
  Ygg = Y_aug(keep_idx, keep_idx);
  Ygn = Y_aug(keep_idx, elim_idx);
  Yng = Y_aug(elim_idx, keep_idx);
  Ynn = Y_aug(elim_idx, elim_idx);

  X = Ynn \ Yng;
  Yred = Ygg - Ygn * X;
end

