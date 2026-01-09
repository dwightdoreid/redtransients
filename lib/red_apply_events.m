function [Ybus_new, fault_state] = red_apply_events(Ybus, fault_state, events, tnow)
  Ybus_new = Ybus;

  if isempty(events), return; endif

  for e = 1:length(events)
    if abs(tnow - events{e}.t) < 1e-12
      ev = events{e};

      switch ev.type
        case "fault_shunt"
          k = ev.data.bus;
          Ysh = ev.data.Ysh;
          % store so we can remove later
          fault_state.("bus") = k;
          fault_state.("Ysh") = Ysh;
          fault_state.("active") = true;

          Ybus_new(k,k) += Ysh;

        case "clear_fault"
          if isfield(fault_state, "active") && fault_state.active
            k = fault_state.bus;
            Ysh = fault_state.Ysh;
            Ybus_new(k,k) -= Ysh;
            fault_state.active = false;
          endif

        otherwise
          error("Unknown event type: %s", ev.type);
      endswitch
    endif
  endfor
endfunction

