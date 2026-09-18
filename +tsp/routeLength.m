function value = routeLength(route, D)
%ROUTELENGTH Sum all visited edges, including route(end) -> route(1).
D = tsp.validateDistanceMatrix(D);
route = tsp.validateRoute(route, size(D, 1));
value = tsp.costUnchecked(route, D);
end
