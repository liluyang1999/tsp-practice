function fitValues = cal_fitness(population, distMatrix)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
% Monotone bounded fitness: zero-length tours remain finite. GA itself uses lengths.
lengths = tsp.evaluatePopulation(population, distMatrix);
fitValues = 1 ./ (1 + lengths);
end
