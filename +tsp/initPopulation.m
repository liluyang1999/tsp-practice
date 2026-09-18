function population = initPopulation(populationSize, cityCount)
%INITPOPULATION Independent random permutations; duplicate individuals are legal.
populationSize = tsp.requireInteger(populationSize, 'PopulationSize', 1);
cityCount = tsp.requireInteger(cityCount, 'CityCount', 1);
population = zeros(populationSize, cityCount);
for k = 1:populationSize
    population(k, :) = randperm(cityCount);
end
end
