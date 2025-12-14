function aug = tse_build_augmented_case(mpc, init, Xd_prime, opts)
  if nargin < 4, opts = struct(); end
  if ~isfield(opts, 'zero_PQ_loads'), opts.zero_PQ_loads = true; end

  mpc_aug = mpc;
  n_bus = size(mpc.bus, 1);

  % 1) Add internal buses + transient branches
  Xd_prime = Xd_prime(:);
  keep_idx = [];
  cnt = 0;

  for bus = init.gen_bus.'
    cnt += 1;
    internal_bus = n_bus + cnt;

    % New bus row: TYPE=1 (PQ), Vm=1, Va=0; baseKV copied from terminal
    baseKV = init.pf.bus(bus, 10);
    mpc_aug.bus = [mpc_aug.bus;
                   internal_bus 1  0 0  0 0  1 1  0  baseKV  1  1.1  0.9];

    % New branch: internal -> terminal with X = Xd'
    mpc_aug.branch = [mpc_aug.branch;
                      internal_bus bus  0 Xd_prime(cnt) 0  250 250 250  0 0  1  -360 360];

    keep_idx(end+1) = internal_bus;
  end

##  aug = struct();
##  aug.mpc_aug = mpc_aug;
##  aug.keep_idx = keep_idx(:);
##  aug.elim_idx = (1:n_bus).';
##  aug.n_bus = n_bus;
##
##  % NEW: mapping generator index -> buses
##  aug.gen_term_bus = init.gen_bus(:);                % terminal bus for each gen (ng x 1)
##  aug.gen_int_bus  = (n_bus + (1:length(init.gen_bus))).';  % internal bus IDs (ng x 1)


  % 2) Convert PQ loads to constant impedance via GS/BS
  % Y = conj(S)/|V|^2 ; GS = Re(Y)*baseMVA ; BS = Im(Y)*baseMVA
  Sload_pu = (init.Pload_MW + 1j*init.Qload_MVAr) / mpc.baseMVA;
  Yload_pu = conj(Sload_pu) ./ (init.Vmag_load.^2);

  GS_add = real(Yload_pu) * mpc.baseMVA;
  BS_add = imag(Yload_pu) * mpc.baseMVA;

  for k = 1:length(init.load_bus)
    b = init.load_bus(k);
    mpc_aug.bus(b,5) += GS_add(k);
    mpc_aug.bus(b,6) += BS_add(k);

    if opts.zero_PQ_loads
      mpc_aug.bus(b,3) = 0;  % Pd
      mpc_aug.bus(b,4) = 0;  % Qd
    end
  end

  aug = struct();
  aug.mpc_aug = mpc_aug;
  aug.keep_idx = keep_idx(:);
  aug.elim_idx = (1:n_bus).';
  aug.n_bus = n_bus;
  aug.gen_term_bus = init.gen_bus(:);                % terminal bus for each gen (ng x 1)
  aug.gen_int_bus  = (n_bus + (1:length(init.gen_bus))).';  % internal bus IDs (ng x 1)
end
