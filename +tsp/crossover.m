function children = crossover(parents, probability)
%CROSSOVER Order crossover (OX); an unpaired final row is kept unchanged.
parents = tsp.validatePopulation(parents);
probability = tsp.requireProbability(probability, 'CrossoverProbability');
children = parents;
n = size(parents, 2);
if n < 2
    return;
end
for k = 1:2:size(parents, 1)-1
    if rand < probability
        points = sort(randperm(n, 2));
        children(k, :) = child(parents(k, :), parents(k+1, :), points);
        children(k+1, :) = child(parents(k+1, :), parents(k, :), points);
    end
end
end

function result = child(segmentParent, orderParent, points)
n = numel(segmentParent);
segment = points(1):points(2);
result = zeros(1, n);
result(segment) = segmentParent(segment);
positions = [points(2)+1:n, 1:points(1)-1];
scan = orderParent([points(2)+1:n, 1:points(2)]);
remaining = scan(~ismember(scan, result(segment)));
result(positions) = remaining;
end
