function Yred = tse_select_Yred(params, tk)
  % params.yset is array with fields t_start, t_end, Yred
  for i = 1:length(params.yset)
    if tk >= params.yset(i).t_start && tk < params.yset(i).t_end
      Yred = params.yset(i).Yred;
      return;
    end
  end
  % fallback
  Yred = params.yset(end).Yred;
end

##
##function Yred = tse_select_Yred(params, tk)
##  if tk < params.t_fault
##    Yred = params.Yred_pre;
##  elseif tk < params.t_clear
##    Yred = params.Yred_fault;
##  else
##    Yred = params.Yred_post;
##  end
##end

