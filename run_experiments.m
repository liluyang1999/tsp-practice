function [runs, summary] = run_experiments(outputDirectory, seeds, budget)
%RUN_EXPERIMENTS Equal objective-call budgets, explicit seeds, new output only.
% Example: run_experiments(fullfile(pwd,'results','class-01'), 1:10, 2000)
% Runtimes include distance construction and initialization. No toolbox tests.
if nargin < 1
    error('tsp:OutputDirectory', 'Provide a NEW output directory; existing paths are never overwritten.');
end
if nargin < 2
    seeds = 1:10;
end
if nargin < 3
    budget = 2000;
end
if isstring(outputDirectory) && isscalar(outputDirectory)
    outputDirectory = char(outputDirectory);
end
if ~ischar(outputDirectory) || ~isrow(outputDirectory) || isempty(strtrim(outputDirectory)) || ...
        exist(outputDirectory, 'file') ~= 0 || exist(outputDirectory, 'dir') ~= 0
    error('tsp:OutputDirectory', 'Output directory must be a new nonempty path.');
end
if ~isnumeric(seeds) || ~isreal(seeds) || ~isvector(seeds) || isempty(seeds)
    error('tsp:Seeds', 'Seeds must be a nonempty numeric vector.');
end
seeds = double(seeds(:)');
for seed = seeds
    tsp.options(struct('Seed', seed));
end
if numel(unique(seeds)) ~= numel(seeds)
    error('tsp:Seeds', 'Use distinct seeds for independent runs.');
end
budget = tsp.requireInteger(budget, 'Budget', 50);
[cities, metadata] = tsp.att48();
populationSize = 50;
maxGenerations = ceil((budget-populationSize)/populationSize);
maxOuter = 100;
maxInner = ceil((budget-1)/maxOuter);
count = numel(seeds)*2;
Algorithm = cell(count, 1); Seed = zeros(count, 1); Evaluations = zeros(count, 1);
BestLength = zeros(count, 1); GapPercent = zeros(count, 1); ElapsedSeconds = zeros(count, 1);
BestRoute = cell(count, 1); histories = cell(count, 1);
row = 0;
for seed = seeds
    options = struct('Seed', seed, 'DistanceType', 'ATT', 'MaxEvaluations', budget);
    for algorithm = {'GA', 'SA'}
        row = row+1;
        started = tic;
        if strcmp(algorithm{1}, 'GA')
            [route, value, info] = tsp.ga(cities, maxGenerations, populationSize, .9, .2, options);
        else
            [route, value, info] = tsp.sa(cities, 1000, .95, maxOuter, maxInner, options);
        end
        elapsed = toc(started);
        if info.Evaluations ~= budget
            error('tsp:Budget', 'Experiment did not consume its exact declared budget.');
        end
        Algorithm{row} = algorithm{1}; Seed(row) = seed; Evaluations(row) = info.Evaluations;
        BestLength(row) = value; GapPercent(row) = 100*(value/metadata.Optimum-1);
        ElapsedSeconds(row) = elapsed; BestRoute{row} = strtrim(sprintf('%d ', route));
        histories{row} = info;
    end
end
runs = table(Algorithm, Seed, Evaluations, BestLength, GapPercent, ElapsedSeconds, BestRoute);
Algorithm = {'GA'; 'SA'};
RunCount = repmat(numel(seeds), 2, 1); Minimum = zeros(2, 1); Mean = zeros(2, 1);
SampleStd = zeros(2, 1); MeanSeconds = zeros(2, 1);
for k = 1:2
    selected = strcmp(runs.Algorithm, Algorithm{k});
    values = runs.BestLength(selected);
    Minimum(k) = min(values); Mean(k) = mean(values); SampleStd(k) = std(values, 0);
    MeanSeconds(k) = mean(runs.ElapsedSeconds(selected));
end
summary = table(Algorithm, RunCount, Minimum, Mean, SampleStd, MeanSeconds);
parameters = struct('SchemaVersion', 1, 'MATLABVersion', version, 'Computer', computer, ...
    'DistanceType', 'ATT', 'Dataset', 'att48', 'SeedGenerator', 'twister', ...
    'Seeds', seeds, 'MaxEvaluations', budget, 'PopulationSize', populationSize, ...
    'MaxGenerations', maxGenerations, 'CrossoverProbability', .9, 'MutationProbability', .2, ...
    'InitialTemperature', 1000, 'CoolingRate', .95, 'MaxOuter', maxOuter, 'MaxInner', maxInner);
% Delay all output until every run succeeds; still fail instead of replacing any existing path.
if exist(outputDirectory, 'file') ~= 0 || exist(outputDirectory, 'dir') ~= 0
    error('tsp:OutputDirectory', 'Output path appeared during computation; refusing to overwrite it.');
end
[created, message, messageID] = mkdir(outputDirectory);
% MATLAB also returns status=1 when another caller has already created it.
if ~created || ~isempty(messageID)
    error('tsp:OutputDirectory', 'Cannot create a fresh output directory: %s', message);
end
writetable(runs, fullfile(outputDirectory, 'runs.csv'));
writetable(summary, fullfile(outputDirectory, 'summary.csv'));
save(fullfile(outputDirectory, 'experiment.mat'), 'runs', 'summary', 'histories', 'parameters', 'metadata', 'cities');
fprintf('Wrote %d runs to %s\n', height(runs), outputDirectory);
end
