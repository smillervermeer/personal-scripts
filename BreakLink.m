function BreakLink()

% Find blocks
Blocks = find_system(gcs, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'selected', 'on');

% Set each block's link status
for Index = 1:length(Blocks)
try %#ok<TRYNC>
    set_param(Blocks{Index}, 'LinkStatus', 'Inactive');
end
end

end
