function distMatrix = dist_mat(cityCoordinates, varargin)
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
distMatrix = tsp.distanceMatrix(cityCoordinates, varargin{:});
end
