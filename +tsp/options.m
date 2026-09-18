function result = options(given)
%OPTIONS Shared optional fields; unknown fields are errors to catch typos.
result = struct('Seed', [], 'DistanceType', 'ATT', 'MaxEvaluations', Inf);
if ~isstruct(given) || ~isscalar(given)
    error('tsp:Options', 'Options must be a scalar struct.');
end
names = fieldnames(given);
for k = 1:numel(names)
    if ~isfield(result, names{k})
        error('tsp:Options', 'Unknown option: %s.', names{k});
    end
    result.(names{k}) = given.(names{k});
end
if ~isnumeric(result.Seed) || ~isreal(result.Seed)
    error('tsp:Seed', 'Seed must be [] or a numeric integer.');
end
if ~isempty(result.Seed)
    result.Seed = tsp.requireInteger(result.Seed, 'Seed', 0);
    if result.Seed > 2^32-1
        error('tsp:Seed', 'Seed must be at most 2^32-1.');
    end
end
if ~(isnumeric(result.MaxEvaluations) && isreal(result.MaxEvaluations) && ...
        isscalar(result.MaxEvaluations) && result.MaxEvaluations == Inf)
    result.MaxEvaluations = tsp.requireInteger(result.MaxEvaluations, 'MaxEvaluations', 1);
else
    result.MaxEvaluations = Inf;
end
% Reuse distance-type validation without constructing an instance-sized matrix.
tsp.distanceMatrix([0; 0], result.DistanceType);
result.DistanceType = upper(char(result.DistanceType));
end
