function value = costUnchecked(route, D)
%COSTUNCHECKED Internal hot path: caller has validated D and the permutation.
next = [route(2:end), route(1)];
value = sum(D(sub2ind(size(D), route, next)));
if ~isfinite(value)
    error('tsp:LengthOverflow', 'The route length exceeds finite double precision.');
end
end
