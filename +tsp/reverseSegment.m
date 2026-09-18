function result = reverseSegment(route)
%REVERSESEGMENT Reverse a uniformly sampled pair of positions; N=1 is unchanged.
route = tsp.validateRoute(route, numel(route));
result = route;
if numel(route) < 2
    return;
end
points = sort(randperm(numel(route), 2));
result(points(1):points(2)) = route(points(2):-1:points(1));
end
