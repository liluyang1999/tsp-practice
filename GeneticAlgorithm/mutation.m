function offsprings = mutation(offsprings, mutationProb)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
offsprings = tsp.mutate(offsprings, mutationProb);
end
