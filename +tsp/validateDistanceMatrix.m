function D = validateDistanceMatrix(D)
%VALIDATEDISTANCEMATRIX Contract shared by public objective/helper functions.
if ~isnumeric(D) || ~isreal(D) || ndims(D) ~= 2 || isempty(D) || ...
        size(D, 1) ~= size(D, 2) || any(~isfinite(D(:))) || any(D(:) < 0) || ...
        any(diag(D) ~= 0) || ~isequal(D, D')
    error('tsp:DistanceMatrix', 'Expected a finite, nonnegative, symmetric square matrix with zero diagonal.');
end
D = double(D);
end
