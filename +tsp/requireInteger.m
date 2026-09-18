function value = requireInteger(value, name, minimum)
%REQUIREINTEGER Validate first, then normalize counts to exact double arithmetic.
if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ~isfinite(value)
    error('tsp:Integer', '%s must be a finite numeric scalar.', name);
end
% Check in the original integer class: converting uint64(flintmax)+1 first loses a bit.
if isinteger(value) && value > cast(flintmax, class(value))
    error('tsp:Integer', '%s exceeds the exact double integer range.', name);
end
value = double(value);
if value < minimum || value ~= floor(value) || value > flintmax
    error('tsp:Integer', '%s must be an integer >= %g within exact double range.', name, minimum);
end
end
