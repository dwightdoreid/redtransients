function netsets = tse_apply_events(aug, events)
  % events: struct array with fields {t, type, data}
  % Produces piecewise-constant network models.

  % Sort events by time
  [~, idx] = sort([events.t]);
  events = events(idx);

  % Start from base augmented case
  mpc_curr = aug.mpc_aug;

  % Track active fault shunts so they can be cleared
  active_fault = struct();  % map-ish via fieldnames "bus_#"
  netsets = struct([]);
  seg = 0;

  for i = 1:length(events)
    ev = events(i);

    % Create a segment from previous event time to this event time
    if i == 1
      t_prev = 0;
    else
      t_prev = events(i-1).t;
    end

    seg += 1;
    netsets(seg).t_start = t_prev;
    netsets(seg).t_end   = ev.t;
    netsets(seg).mpc     = mpc_curr;

    % Apply the event to get next mpc_curr
    switch ev.type
      case "fault_bus"
        bus = ev.data.bus;
        Zf  = ev.data.Zf;
        Yf  = 1 / Zf;

        mpc_curr.bus(bus,5) += real(Yf) * mpc_curr.baseMVA;
        mpc_curr.bus(bus,6) += imag(Yf) * mpc_curr.baseMVA;

        key = sprintf("bus_%d", bus);
        active_fault.(key) = Yf;

      case "clear_fault_bus"
        bus = ev.data.bus;
        key = sprintf("bus_%d", bus);

        if isfield(active_fault, key)
          Yf = active_fault.(key);
          mpc_curr.bus(bus,5) -= real(Yf) * mpc_curr.baseMVA;
          mpc_curr.bus(bus,6) -= imag(Yf) * mpc_curr.baseMVA;
          active_fault = rmfield(active_fault, key);
        else
          warning("No active fault recorded at bus %d to clear.", bus);
        end

      case "trip_branch"
        fbus = ev.data.fbus;
        tbus = ev.data.tbus;

        br = find((mpc_curr.branch(:,1)==fbus & mpc_curr.branch(:,2)==tbus) | ...
                  (mpc_curr.branch(:,1)==tbus & mpc_curr.branch(:,2)==fbus), 1);
        if isempty(br)
          warning("Branch %d-%d not found to trip.", fbus, tbus);
        else
          mpc_curr.branch(br,11) = 0; % BR_STATUS
        end

      case "load_shed"
        bus = ev.data.bus;
        frac = ev.data.frac; % e.g. 0.3 means shed 30%
        mpc_curr.bus(bus,5) *= (1 - frac);
        mpc_curr.bus(bus,6) *= (1 - frac);

      case "trip_generator"
        g = ev.data.gen;              % 1..ng
        ibus = aug.gen_int_bus(g);
        tbus = aug.gen_term_bus(g);

        br = find((mpc_curr.branch(:,1)==ibus & mpc_curr.branch(:,2)==tbus) | ...
                  (mpc_curr.branch(:,1)==tbus & mpc_curr.branch(:,2)==ibus), 1);

        if isempty(br)
          warning("Gen %d branch %d-%d not found to trip.", g, ibus, tbus);
        else
          mpc_curr.branch(br,11) = 0; % BR_STATUS
        end

##        % data: internal_bus, terminal_bus
##        ibus = ev.data.internal_bus;
##        tbus = ev.data.terminal_bus;
##
##        br = find((mpc_curr.branch(:,1)==ibus & mpc_curr.branch(:,2)==tbus) | ...
##                  (mpc_curr.branch(:,1)==tbus & mpc_curr.branch(:,2)==ibus), 1);
##        if isempty(br)
##          warning("Gen branch %d-%d not found to trip.", ibus, tbus);
##        else
##          mpc_curr.branch(br,11) = 0;
##        end

      otherwise
        error("Unknown event type: %s", ev.type);
    end
  end

  % Add final segment to infinity (caller can clip to t_end)
  seg += 1;
  netsets(seg).t_start = events(end).t;
  netsets(seg).t_end   = inf;
  netsets(seg).mpc     = mpc_curr;
end

