function br_idx = find_branch_idx(mpc, fbus, tbus, ckt)
  % Returns the first matching in-service branch index for fbus->tbus (either direction)
  % ckt optional: if present, selects the ckt-th match (1-based)

  if nargin < 4, ckt = 1; endif

  F_BUS = 1; T_BUS = 2; BR_STATUS = 11;

  matches = [];
  for k = 1:size(mpc.branch,1)
    if mpc.branch(k,BR_STATUS) == 0, continue; endif
    fb = mpc.branch(k,F_BUS);
    tb = mpc.branch(k,T_BUS);
    if (fb == fbus && tb == tbus) || (fb == tbus && tb == fbus)
      matches(end+1) = k; %#ok<AGROW>
    endif
  endfor

  if isempty(matches)
    error('No in-service branch found between buses %d and %d', fbus, tbus);
  endif
  if ckt > length(matches)
    error('Requested ckt=%d but only %d branch(es) found between %d-%d', ckt, length(matches), fbus, tbus);
  endif

  br_idx = matches(ckt);
endfunction

