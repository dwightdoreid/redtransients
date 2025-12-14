function p0set = tse_apply_p0_events(Pm0_init, events, t_end)
  % Build piecewise-constant Pm0(t) schedule
  %
  % Inputs:
  %   Pm0_init : ngx1 baseline mechanical power vector at t=0
  %   events   : struct array with fields {t, type, data}
  %              supported control event:
  %                type = "set_Pm0"
  %                data = struct("gen", i, "value", newValue)
  %              optionally:
  %                type = "scale_Pm0"
  %                data = struct("gen", i, "scale", alpha)
  %   t_end    : simulation end time (for final segment end)
  %
  % Output:
  %   p0set : struct array with {t_start, t_end, Pm0}

  if nargin < 3, t_end = inf; end

  % Filter only Pm0-related events
  is_p0 = arrayfun(@(e) strcmp(e.type, "set_Pm0") || strcmp(e.type, "scale_Pm0"), events);
  p0events = events(is_p0);

  % If none, make single segment
  if isempty(p0events)
    p0set = struct("t_start", 0, "t_end", t_end, "Pm0", Pm0_init(:));
    return;
  end

  % Sort by time
  [~, idx] = sort([p0events.t]);
  p0events = p0events(idx);

  Pm0 = Pm0_init(:);
  p0set = struct([]);
  seg = 0;

  % Build segments
  for i = 1:length(p0events)
    ev = p0events(i);

    if i == 1
      t_prev = 0;
    else
      t_prev = p0events(i-1).t;
    end

    seg += 1;
    p0set(seg).t_start = t_prev;
    p0set(seg).t_end   = ev.t;
    p0set(seg).Pm0     = Pm0;

    % Apply event
    switch ev.type
      case "set_Pm0"
        g = ev.data.gen;        % 1..ng
        v = ev.data.value;
        Pm0(g) = v;

      case "scale_Pm0"
        g = ev.data.gen;
        a = ev.data.scale;
        Pm0(g) = a * Pm0(g);

      otherwise
        error("Unknown Pm0 event type: %s", ev.type);
    end
  end

  % Final segment to t_end
  seg += 1;
  p0set(seg).t_start = p0events(end).t;
  p0set(seg).t_end   = t_end;
  p0set(seg).Pm0     = Pm0;
end

