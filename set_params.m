function set_params(varargin)
Block = gcs;

% Find blocks
Blocks = find_system(Block, ...
    'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', ...
    'SearchDepth', '1', ...
    'Selected', 'on');
% Filter out parent block
Blocks = Blocks(~strcmp(Blocks, Block));

for i=1:length(Blocks)
    try
        set_param(Blocks{i}, varargin{:})
    catch
    end
end
end