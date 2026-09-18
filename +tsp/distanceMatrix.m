function D = distanceMatrix(coordinates, distanceType)
%DISTANCEMATRIX Symmetric distances for finite 2-by-N coordinates, N >= 1.
% ATT is TSPLIB pseudo-Euclidean distance; EUC_2D rounds Euclidean distances;
% EUCLIDEAN keeps their floating-point values.
if nargin < 2
    distanceType = 'ATT';
end
if ~isnumeric(coordinates) || ~isreal(coordinates) || ndims(coordinates) ~= 2 || ...
        size(coordinates, 1) ~= 2 || isempty(coordinates) || any(~isfinite(coordinates(:)))
    error('tsp:Coordinates', 'Coordinates must be a finite real numeric 2-by-N matrix, N >= 1.');
end
if isstring(distanceType) && isscalar(distanceType)
    distanceType = char(distanceType);
end
if ~ischar(distanceType) || ~isrow(distanceType)
    error('tsp:DistanceType', 'DistanceType must be ATT, EUC_2D or EUCLIDEAN.');
end
distanceType = upper(distanceType);
if ~ismember(distanceType, {'ATT', 'EUC_2D', 'EUCLIDEAN'})
    error('tsp:DistanceType', 'DistanceType must be ATT, EUC_2D or EUCLIDEAN.');
end
coordinates = double(coordinates);
n = size(coordinates, 2);
D = zeros(n);
for i = 1:n-1
    delta = coordinates(:, i+1:n) - coordinates(:, i);
    if strcmp(distanceType, 'ATT')
        r = sqrt(sum(delta.^2, 1) / 10);
        nearest = round(r);
        distances = nearest + (nearest < r);
    else
        distances = hypot(delta(1, :), delta(2, :));
        if strcmp(distanceType, 'EUC_2D')
            distances = round(distances);
        end
    end
    if any(~isfinite(distances))
        error('tsp:DistanceOverflow', 'Coordinates are too large for finite distances.');
    end
    D(i, i+1:n) = distances;
    D(i+1:n, i) = distances';
end
end
