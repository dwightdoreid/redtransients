function ang180 = red_wrap180(ang_deg)
  % Wrap angle(s) to [-180, 180)
  ang180 = mod(ang_deg + 180, 360) - 180;
endfunction

