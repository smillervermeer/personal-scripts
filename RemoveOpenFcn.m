function RemoveOpenFcn()

% Find blocks
Blocks = find_system(gcs, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'selected', 'on');

% Clear out the OpenFcn parameter
for Index = 1:length(Blocks)
    set_param(Blocks{Index}, 'OpenFcn', '');
end

end
