function CheckDataStores(StartIndex)
DataStores = find_system(bdroot, 'LookUnderMasks', 'on', ...
    'FollowLinks', true, 'MaskType', 'DataStoreCombined');
AlreadyChecked = {};

if nargin < 1
    StartIndex = 1;
end

Uniques = {};
Paths = {};

for Index = StartIndex:length(DataStores)
    Parent = get_param(DataStores{Index}, 'parent');
    if any(strcmp(get_param(Parent, 'MaskType'), {'SPNTx', 'SPNRx'}))
        DataStoreName = get_param(DataStores{Index}, 'DataStoreName');
        UniqueName = get_param(get_param(DataStores{Index}, 'parent'), 'UniqueName');
        EvaldName = eval(DataStoreName);
        Uniques = [Uniques, EvaldName];
        Paths = [Paths, DataStores{Index}];
    end
end


[~,UniqueIndices] = unique(Uniques);
Uniques(UniqueIndices) = [];
Paths(UniqueIndices) = [];

for Index = 1:length(Uniques)
    fprintf('# %s - %s\n', Uniques{Index}, ...
        strrep(Paths{Index}, '/DataStoreVariant/ReadOnly/Parameter', ''))
end

end