function CopySPNNameToQtVariable()

% Find blocks
Blocks = find_system(gcs, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'SearchDepth', '1', 'selected', 'on');

QtVariableBlock = '';
SPNRxBlock = '';

for Index = 1:length(Blocks)
    MaskType = get_param(Blocks{Index}, 'MaskType');
    if isempty(SPNRxBlock) && isequal(MaskType, 'SPNRx')
        SPNRxBlock = Blocks{Index};
    end
    if isempty(QtVariableBlock) && isequal(MaskType, 'DisplayBusToQtVariable')
        QtVariableBlock = Blocks{Index};
    end
end

if isempty(QtVariableBlock) || isempty(SPNRxBlock)
    return
end

Name = get_param(SPNRxBlock, 'SPNDescription');
Name = strrep(Name, ' ', '');
set_param(QtVariableBlock, 'BaseName', Name);

DataType = get_param(SPNRxBlock, 'DataDataType');
set_param(QtVariableBlock, 'DataType', DataType);

end