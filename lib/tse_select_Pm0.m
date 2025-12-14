function Pm0 = tse_select_Pm0(params, tk)
  % params.p0set: array with fields t_start, t_end, Pm0
  for i = 1:length(params.p0set)
    if tk >= params.p0set(i).t_start && tk < params.p0set(i).t_end
      Pm0 = params.p0set(i).Pm0;
      return;
    end
  end
  Pm0 = params.p0set(end).Pm0;
end
