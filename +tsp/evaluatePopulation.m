function lengths = evaluatePopulation(population, D)
%EVALUATEPOPULATION One objective evaluation per population row.
D = tsp.validateDistanceMatrix(D);
population = tsp.validatePopulation(population);
if size(population, 2) ~= size(D, 1)
    error('tsp:Population', 'Population width must match the distance matrix.');
end
lengths = zeros(size(population, 1), 1);
for k = 1:size(population, 1)
    lengths(k) = tsp.costUnchecked(population(k, :), D);
end
end
