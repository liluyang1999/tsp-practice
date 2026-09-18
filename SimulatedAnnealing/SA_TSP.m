function [bestSolution, bestLength, info] = SA_TSP(cityCoordinates, T, coolingRate, maxOutIter, maxInIter, varargin)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
[bestSolution, bestLength, info] = tsp.sa(cityCoordinates, T, coolingRate, maxOutIter, maxInIter, varargin{:});
end
