function restore = seedScope(seed)
%SEEDSCOPE A supplied seed is local to this call; [] consumes the caller's RNG.
restore = [];
if ~isempty(seed)
    previous = rng;
    restore = onCleanup(@() rng(previous));
    rng(double(seed), 'twister');
end
end
