function CopyPortNames()

String = '';

% Find inport blocks
Blocks = find_system(gcs, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'SearchDepth', '1', 'BlockType', 'Inport');

% Build a tab-delimited string
for Index = 1:length(Blocks)
    String = [String, get_param(Blocks{Index}, 'Name'), char(9)];
end

% Find outport blocks
Blocks = find_system(gcs, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'SearchDepth', '1', 'BlockType', 'Outport');

% Build a tab-delimited string
for Index = 1:length(Blocks)
    String = [String, get_param(Blocks{Index}, 'Name'), char(9)];
end

% Copy to clipboard
clipboard('Copy', String)

end
