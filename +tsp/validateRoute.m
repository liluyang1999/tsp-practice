function route = validateRoute(route, n)
%VALIDATEROUTE A closed tour stores each city once; closure is implicit.
if ~isnumeric(route) || ~isreal(route) || ~isvector(route) || numel(route) ~= n || ...
        any(~isfinite(route(:))) || ~isequal(sort(double(route(:)')), 1:n)
    error('tsp:Route', 'Route must be a permutation of city indices 1:N.');
end
route = double(route(:)');
end
