function yset = tse_build_Yred_set(aug, netsets)
  yset = struct([]);
  for i = 1:length(netsets)
    [Yaug, ~, ~] = makeYbus(netsets(i).mpc);
    Yred = kron_reduce(Yaug, aug.keep_idx, aug.elim_idx);

    yset(i).t_start = netsets(i).t_start;
    yset(i).t_end   = netsets(i).t_end;
    yset(i).Yred    = Yred;
  end
end

