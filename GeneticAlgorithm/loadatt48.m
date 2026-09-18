function [cities, metadata] = loadatt48()
% Compatibility entry point. See README.md and docs/03-migration.md.
root = fileparts(fileparts(mfilename('fullpath')));
previousPath = path;
restorePath = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
% Returns data; no clear all, file writes, or workspace changes.
[cities, metadata] = tsp.att48();
end
