function selected = selectParents(population, lengths)
%SELECTPARENTS Binary tournaments use cached lengths, with smaller being better.
population = tsp.validatePopulation(population);
count = size(population, 1);
if ~isnumeric(lengths) || ~isreal(lengths) || ~isvector(lengths) || numel(lengths) ~= count || ...
        any(~isfinite(lengths(:))) || any(lengths(:) < 0)
    error('tsp:Lengths', 'Provide one finite nonnegative length per individual.');
end
selected = population;
if count == 1
    return;
end
for k = 1:count
    pair = randperm(count, 2);
    [~, winner] = min(lengths(pair));
    selected(k, :) = population(pair(winner), :);
end
end
