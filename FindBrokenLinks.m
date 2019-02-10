function FindBrokenLinks(Model)

if nargin < 1
    Model = bdroot(gcs);
end

BaseBlockNames = {'InputMapping', 'InputCalibration', 'Application', ...
    'OutputCalibration', 'OutputMapping', 'CAN', 'Qt'};
OkayToBeUnlinked = {'Inport', 'Outport', 'Goto', 'From', 'BusCreator', ...
    'BusSelector', 'DataStoreRead', 'DataStoreWrite', 'DataStoreMemory'};

% Disabled links
DisabledLinks = find_system(Model, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'LinkStatus', 'inactive');

% Unlinked
Unlinked = find_system(Model, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'LinkStatus', 'none');

% 
BlockTyes = cellfun(@(x) get_param(x, 'BlockType'), Unlinked, ...
    'UniformOutput', false);
Unlinked = Unlinked(~contains(BlockTyes, OkayToBeUnlinked));

% Subsystems that are children of one of the base layers are okay
BlockTyes = cellfun(@(x) get_param(x, 'BlockType'), Unlinked, ...
    'UniformOutput', false);
Name = cellfun(@(x) get_param(x, 'Name'), Unlinked, 'UniformOutput', false);
ParentName = cellfun(@(x) get_param(get_param(x, 'Parent'), 'Name'), ...
    Unlinked, 'UniformOutput', false);
Depth = cellfun(@(x) length(strsplit(x, '/')) - 1, Unlinked);
Unlinked = Unlinked(~(...
    (Depth <= 2) & ...
    (contains(ParentName, BaseBlockNames) | contains(Name, BaseBlockNames))& ...
    strcmp(BlockTyes, 'SubSystem')));

Blocks = Unlinked;
Unlinked = Blocks(1);
for Index = 2:length(Blocks)
    if ~contains(Blocks{Index}, Unlinked)
        Unlinked = [Unlinked; Blocks(Index)]; %#ok<AGROW>
    end
end

for Index = 1:length(Unlinked)
    fprintf(['# %2$ 3u. <a href="matlab: hilite_system(', ...
        '''%1$s'',''find'')">%1$s</a>\n'], Unlinked{Index}, Index);
end


end