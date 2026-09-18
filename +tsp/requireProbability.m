function value = requireProbability(value, name)
if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ~isfinite(value) || value < 0 || value > 1
    error('tsp:Probability', '%s must be a finite scalar between 0 and 1.', name);
end
value = double(value);
end
