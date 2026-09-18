function offsprings = crossover(parents, crossoverProb)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
offsprings = tsp.crossover(parents, crossoverProb);
end
