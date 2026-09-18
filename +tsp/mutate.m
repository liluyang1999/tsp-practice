function population = mutate(population, probability)
%MUTATE Independent reversal mutation, preserving the permutation invariant.
population = tsp.validatePopulation(population);
probability = tsp.requireProbability(probability, 'MutationProbability');
for k = 1:size(population, 1)
    if rand < probability
        population(k, :) = tsp.reverseSegment(population(k, :));
    end
end
end
