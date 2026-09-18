function run_tests()
%RUN_TESTS Base-MATLAB contract tests. No Optimization/Statistics toolbox required.
% This suite must be run in MATLAB; static inspection is not a passing result.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
previousRng = rng;
restoreRng = onCleanup(@() rng(previousRng)); %#ok<NASGU>
tests = {@testClosingEdge, @testDistances, @testValidation, @testOperators, ...
    @testGA, @testSA, @testReproducibility, @testLegacyEntrypoints, @testExperimentOutput, @testNumericClasses};
for k = 1:numel(tests)
    feval(tests{k});
    fprintf('PASS %s\n', func2str(tests{k}));
end
fprintf('TSP_TESTS_OK %d groups\n', numel(tests));
end

function testClosingEdge()
D = [0 3 5; 3 0 4; 5 4 0];
route = [2 1 3];
assert(tsp.routeLength(route, D) == 12); % The historical implementation returned 13.
assert(tsp.routeLength([1 3 2], D) == 12);
assert(tsp.routeLength(fliplr(route), D) == 12);
assert(tsp.routeLength(route', D) == 12);
assert(tsp.routeLength(1, 0) == 0);
assert(tsp.routeLength([2 1], [0 7; 7 0]) == 14);
% Exhaustive oracle for a four-city square: optimum is its perimeter.
D = tsp.distanceMatrix([0 1 1 0; 0 0 1 1], 'EUCLIDEAN');
routes = perms(1:4);
lengths = tsp.evaluatePopulation(routes, D);
assert(abs(min(lengths) - 4) < 1e-12);
end

function testDistances()
coords = [0 3 1; 0 4 3];
D = tsp.distanceMatrix(coords, 'ATT');
assert(isequal(D, [0 2 1; 2 0 1; 1 1 0]));
assert(isequal(tsp.distanceMatrix([0 3; 0 4], 'EUC_2D'), [0 5; 5 0]));
assert(isequal(tsp.distanceMatrix([2 2; 3 3]), zeros(2)));
[cities, metadata] = tsp.att48();
assert(isequal(size(cities), [2 48]));
assert(isequal(cities(:, 1), [6734;1453]));
assert(isequal(cities(:, 48), [3023;1942]));
assert(metadata.Optimum == 10628 && strcmp(metadata.DistanceType, 'ATT'));
D = tsp.distanceMatrix(cities);
assert(D(1, 2) == 1495 && isequal(D, D') && all(diag(D) == 0));
assert(all(D(:) == round(D(:))));
end

function testValidation()
mustFail(@() tsp.distanceMatrix([]));
mustFail(@() tsp.distanceMatrix([0 NaN; 0 1]));
mustFail(@() tsp.distanceMatrix([0 1; 0 1], 'unknown'));
mustFail(@() tsp.routeLength([1 1], [0 1; 1 0]));
mustFail(@() tsp.routeLength([1 2], [0 -1; -1 0]));
mustFail(@() tsp.routeLength([1 2], [0 1; 2 0]));
mustFail(@() tsp.ga([0;0], -1, 1, .8, .1));
mustFail(@() tsp.ga([0;0], 1, 0, .8, .1));
mustFail(@() tsp.ga([0;0], 1, 2, .8, .1, struct('MaxEvaluations', 1)));
mustFail(@() tsp.sa([0;0], 0, .9, 1, 1));
mustFail(@() tsp.sa([0;0], 10, 1, 1, 1));
mustFail(@() tsp.ga([0;0], 0, 1, .8, .1, struct('Unknown', 1)));
mustFail(@() tsp.ga([0;0], 0, 1, .8, .1, struct('Seed', '')));
end

function testOperators()
rng(123, 'twister');
for n = [1 2 7]
    pop = tsp.initPopulation(5, n);
    for k = 1:30
        pop = tsp.mutate(tsp.crossover(pop, 1), 1);
        assert(isequal(sort(pop, 2), repmat(1:n, 5, 1)));
        assert(isequal(sort(tsp.reverseSegment(pop(1, :))), 1:n));
    end
end
assert(isequal(tsp.selectParents(1, 0), 1));
end

function testGA()
coords = [0 1 1 0; 0 0 1 1];
opts = struct('Seed', 12, 'DistanceType', 'EUCLIDEAN');
rng(12, 'twister');
pop = tsp.initPopulation(7, 4);
expected = min(tsp.evaluatePopulation(pop, tsp.distanceMatrix(coords, 'EUCLIDEAN')));
[route, value, info] = tsp.ga(coords, 0, 7, .8, .2, opts);
assert(value == expected && info.Evaluations == 7 && info.Iterations == 0);
assert(value == tsp.routeLength(route, tsp.distanceMatrix(coords, 'EUCLIDEAN')));
opts.MaxEvaluations = 23;
[route, value, info] = tsp.ga(coords, 20, 7, .8, .2, opts);
assert(info.Evaluations == 23 && all(diff(info.BestHistory) <= 0));
assert(info.EvaluationHistory(end) == 23);
assert(value >= 4 - 1e-12 && value == tsp.routeLength(route, tsp.distanceMatrix(coords, 'EUCLIDEAN')));
[route, value] = tsp.ga([0;0], 3, 1, 1, 1, struct('Seed', 1));
assert(isequal(route, 1) && value == 0);
[~, ~, info] = tsp.ga(coords, 2, 7, .8, .2, struct('Seed', 1));
assert(info.Iterations == 2 && info.Evaluations == 21); % No extra generation.
end

function testSA()
coords = [0 1 1 0; 0 0 1 1];
opts = struct('Seed', 12, 'DistanceType', 'EUCLIDEAN', 'MaxEvaluations', 23);
[route, value, info] = tsp.sa(coords, 10, .9, 20, 7, opts);
assert(info.Evaluations == 23 && all(diff(info.BestHistory) <= 0));
assert(value >= 4 - 1e-12 && value == tsp.routeLength(route, tsp.distanceMatrix(coords, 'EUCLIDEAN')));
[~, ~, info] = tsp.sa(coords, 10, .9, 0, 7, opts);
assert(info.Evaluations == 1 && info.Iterations == 0);
[route, value] = tsp.sa([0;0], realmin, .1, 10, 1, struct('Seed', 1));
assert(isequal(route, 1) && value == 0);
end

function testReproducibility()
coords = [0 1 1 0; 0 0 1 1];
opts = struct('Seed', 42);
before = rng;
[a, av, ai] = tsp.ga(coords, 5, 5, .8, .1, opts);
assert(isequal(before, rng));
[b, bv, bi] = tsp.ga(coords, 5, 5, .8, .1, opts);
assert(isequal(a, b) && av == bv && isequal(ai, bi));
[a, av, ai] = tsp.sa(coords, 10, .9, 5, 5, opts);
assert(isequal(before, rng));
[b, bv, bi] = tsp.sa(coords, 10, .9, 5, 5, opts);
assert(isequal(a, b) && av == bv && isequal(ai, bi));
hugeSquare = [0 7e307 7e307 0; 0 0 7e307 7e307];
mustFail(@() tsp.ga(hugeSquare, 1, 2, .8, .1, struct('Seed', 1, 'DistanceType', 'EUCLIDEAN')));
assert(isequal(before, rng)); % An error after seeding must also restore RNG.
end

function testLegacyEntrypoints()
root = fileparts(fileparts(mfilename('fullpath')));
for directory = {'GeneticAlgorithm', 'SimulatedAnnealing'}
    beforePath = path;
    restore = onCleanup(@() path(beforePath));
    addpath(fullfile(root, directory{1}), '-begin');
    enteredPath = path;
    clear route_length dist_mat loadatt48
    assert(route_length([2 1 3], [0 3 5; 3 0 4; 5 4 0]) == 12);
    assert(isequal(size(loadatt48()), [2 48]));
    assert(isequal(enteredPath, path)); % Compatibility wrappers restore path order.
    if strcmp(directory{1}, 'GeneticAlgorithm')
        [~, value] = GA_TSP([0;0], 1, 1, 1, 1, struct('Seed', 1));
    else
        [~, value] = SA_TSP([0;0], 1, .9, 1, 1, struct('Seed', 1));
    end
    assert(value == 0);
    clear restore
end
end

function testExperimentOutput()
directory = tempname;
cleanup = onCleanup(@() cleanExperiment(directory)); %#ok<NASGU>
[runs, summary] = run_experiments(directory, 11, 53);
assert(height(runs) == 2 && height(summary) == 2);
assert(all(runs.Evaluations == 53));
assert(exist(fullfile(directory, 'runs.csv'), 'file') == 2);
assert(exist(fullfile(directory, 'summary.csv'), 'file') == 2);
saved = load(fullfile(directory, 'experiment.mat'), 'parameters', 'runs');
assert(saved.parameters.MaxEvaluations == 53 && isequal(saved.runs, runs));
mustFail(@() run_experiments(directory, 11, 53));
stillSaved = load(fullfile(directory, 'experiment.mat'), 'runs');
assert(isequal(stillSaved.runs, runs));
end

function testNumericClasses()
% Integer-typed counts must not saturate or round the solver's arithmetic.
coords = [0 1 1 0; 0 0 1 1];
opts = struct('Seed', 13, 'MaxEvaluations', 300);
[a, av, ai] = tsp.ga(coords, 50, 7, 1, 0, opts);
typed = struct('Seed', uint32(13), 'MaxEvaluations', uint16(300));
[b, bv, bi] = tsp.ga(coords, uint8(50), uint8(7), uint8(1), uint8(0), typed);
assert(isequal(a, b) && av == bv && isequal(ai, bi));
assert(bi.Evaluations == 300);
[a, av, ai] = tsp.sa(coords, 10, .8, 20, 20, opts);
[b, bv, bi] = tsp.sa(coords, uint8(10), .8, uint8(20), uint8(20), typed);
assert(isequal(a, b) && av == bv && isequal(ai, bi));
mustFail(@() tsp.requireInteger(uint64(flintmax) + uint64(1), 'count', 0));
mustFail(@() tsp.selectParents(repmat(1:3, 4, 1), ones(2)));
end

function cleanExperiment(directory)
% Only these files are created by this test; never recursively remove unknown content.
for name = {'runs.csv', 'summary.csv', 'experiment.mat'}
    file = fullfile(directory, name{1});
    if exist(file, 'file') == 2
        delete(file);
    end
end
if exist(directory, 'dir') == 7
    entries = dir(directory);
    if all(ismember({entries.name}, {'.', '..'}))
        rmdir(directory);
    end
end
end

function mustFail(action)
failed = false;
try
    action();
catch exception
    failed = strncmp(exception.identifier, 'tsp:', 4);
end
assert(failed, 'Expected a tsp: validation error.');
end
