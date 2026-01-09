function red_auto_legend(prefix, n)
  if (n<=5)
    legend(arrayfun(@(k) sprintf('%s%d', prefix, k), 1:n, 'UniformOutput', false), 'Location', 'bestoutside');
  else
##    legend(arrayfun(@(k) sprintf('%s%d', prefix, k), 1:n, 'UniformOutput', false), 'Location', 'bestoutside', 'Orientation', 'horizontal', "numcolumns", 3);
    legend off;
end

