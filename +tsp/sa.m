function [bestRoute, bestLength, info] = sa(coordinates, initialTemperature, coolingRate, maxOuterIterations, maxInnerIterations, givenOptions)
%SA Reversal-neighbour simulated annealing with cached current cost.
if nargin < 6
    givenOptions = struct();
end
if ~isnumeric(initialTemperature) || ~isreal(initialTemperature) || ...
        ~isscalar(initialTemperature) || ~isfinite(initialTemperature) || initialTemperature <= 0
    error('tsp:Temperature', 'InitialTemperature must be positive and finite.');
end
initialTemperature = double(initialTemperature);
coolingRate = tsp.requireProbability(coolingRate, 'CoolingRate');
if coolingRate <= 0 || coolingRate >= 1
    error('tsp:CoolingRate', 'CoolingRate must be strictly between 0 and 1.');
end
maxOuterIterations = tsp.requireInteger(maxOuterIterations, 'MaxOuterIterations', 0);
maxInnerIterations = tsp.requireInteger(maxInnerIterations, 'MaxInnerIterations', 1);
options = tsp.options(givenOptions);
D = tsp.distanceMatrix(coordinates, options.DistanceType);
restore = tsp.seedScope(options.Seed); %#ok<NASGU>
current = randperm(size(D, 1));
currentLength = tsp.costUnchecked(current, D);
bestRoute = current;
bestLength = currentLength;
temperature = initialTemperature;
evaluations = 1;
iterations = 0;
bestHistory = bestLength;
evaluationHistory = evaluations;
for outer = 1:maxOuterIterations
    if evaluations >= options.MaxEvaluations
        break;
    end
    for inner = 1:maxInnerIterations
        if evaluations >= options.MaxEvaluations
            break;
        end
        candidate = tsp.reverseSegment(current);
        candidateLength = tsp.costUnchecked(candidate, D);
        evaluations = evaluations + 1;
        delta = candidateLength-currentLength;
        % Guard the zero-temperature limit; exp(-delta/T) may safely underflow to 0.
        if delta <= 0 || (temperature > 0 && rand < exp(-delta/temperature))
            current = candidate;
            currentLength = candidateLength;
        end
        if currentLength < bestLength
            bestRoute = current;
            bestLength = currentLength;
        end
    end
    iterations = outer;
    bestHistory(end+1, 1) = bestLength; %#ok<AGROW>
    evaluationHistory(end+1, 1) = evaluations; %#ok<AGROW>
    temperature = temperature * coolingRate;
end
info = struct('Algorithm', 'SA', 'Evaluations', evaluations, 'Iterations', iterations, ...
    'BestHistory', bestHistory, 'EvaluationHistory', evaluationHistory, ...
    'FinalTemperature', temperature, 'Options', options);
end
