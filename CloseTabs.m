function CloseTabs(Model)

if nargin < 1
    Model = bdroot(gcs);
end

open_system(Model, 'tab')

Blocks = find_system(Model, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'Open', 'on');

Blocks = Blocks(~strcmp(Blocks,Model));

close_system(Blocks)

end