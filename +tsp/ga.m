function [bestRoute, bestLength, info] = ga(coordinates, maxGenerations, populationSize, crossoverProbability, mutationProbability, givenOptions)
%GA Elitist genetic algorithm with cached costs and an objective-call budget.
if nargin < 6
    givenOptions = struct();
end
maxGenerations = tsp.requireInteger(maxGenerations, 'MaxGenerations', 0);
populationSize = tsp.requireInteger(populationSize, 'PopulationSize', 1);
crossoverProbability = tsp.requireProbability(crossoverProbability, 'CrossoverProbability');
mutationProbability = tsp.requireProbability(mutationProbability, 'MutationProbability');
options = tsp.options(givenOptions);
if options.MaxEvaluations < populationSize
    error('tsp:Budget', 'MaxEvaluations must cover the initial population.');
end
D = tsp.distanceMatrix(coordinates, options.DistanceType);
restore = tsp.seedScope(options.Seed); %#ok<NASGU>
population = tsp.initPopulation(populationSize, size(D, 1));
lengths = tsp.evaluatePopulation(population, D);
[bestLength, bestIndex] = min(lengths);
bestRoute = population(bestIndex, :);
evaluations = populationSize;
iterations = 0;
generationLimit = min(maxGenerations, ceil((options.MaxEvaluations-populationSize)/populationSize));
bestHistory = zeros(generationLimit+1, 1);
evaluationHistory = zeros(generationLimit+1, 1);
bestHistory(1) = bestLength;
evaluationHistory(1) = evaluations;
for generation = 1:generationLimit
    parents = tsp.selectParents(population, lengths);
    children = tsp.mutate(tsp.crossover(parents, crossoverProbability), mutationProbability);
    count = min(populationSize, options.MaxEvaluations-evaluations);
    children = children(1:count, :);
    childLengths = tsp.evaluatePopulation(children, D);
    evaluations = evaluations + count;
    candidates = [population; children];
    [sortedLengths, order] = sort([lengths; childLengths], 'ascend');
    population = candidates(order(1:populationSize), :);
    lengths = sortedLengths(1:populationSize);
    bestRoute = population(1, :);
    bestLength = lengths(1);
    iterations = generation;
    bestHistory(generation+1) = bestLength;
    evaluationHistory(generation+1) = evaluations;
end
info = struct('Algorithm', 'GA', 'Evaluations', evaluations, 'Iterations', iterations, ...
    'BestHistory', bestHistory, 'EvaluationHistory', evaluationHistory, 'Options', options);
end
