function population = validatePopulation(population)
%VALIDATEPOPULATION Rows are permutations of 1:N; at least one row/city.
if ~isnumeric(population) || ~isreal(population) || ndims(population) ~= 2 || isempty(population)
    error('tsp:Population', 'Population must be a nonempty numeric matrix of permutations.');
end
population = double(population);
expected = repmat(1:size(population, 2), size(population, 1), 1);
if ~isequal(sort(population, 2), expected)
    error('tsp:Population', 'Every population row must be a permutation of 1:N.');
end
end
