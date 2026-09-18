function selectedIndiv = tour_select(population, distMatrix)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
lengths = tsp.evaluatePopulation(population, distMatrix);
selectedIndiv = tsp.selectParents(population, lengths);
end
