function [bestIndiv, bestLength, info] = GA_TSP(cityCoordinates, MAXGEN, POPSIZE, crossoverProb, mutationProb, varargin)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
[bestIndiv, bestLength, info] = tsp.ga(cityCoordinates, MAXGEN, POPSIZE, crossoverProb, mutationProb, varargin{:});
end
