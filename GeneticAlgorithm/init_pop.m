function population = init_pop(populationSize, individualLength)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
population = tsp.initPopulation(populationSize, individualLength);
end
