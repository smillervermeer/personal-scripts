function SetDataType(DataType)

Block = gcs;

% Find blocks
Blocks = find_system(Block,'LookUnderMasks','all','FollowLinks','on',...
    'selected','on');

% Filter out parent block
Blocks = Blocks(~strcmp(Blocks, Block));

% Set each block's data type
for Index = 1:length(Blocks)
    try
        Parameters = fieldnames(get_param(Blocks{Index},'ObjectParameters'));
        if any(strcmp(Parameters, 'OutDataTypeStr'))
            set_param(Blocks{Index},'OutDataTypeStr',DataType);
        end
        if any(strcmp(Parameters, 'VariableDataType'))
            set_param(Blocks{Index},'VariableDataType',DataType);
        end
    catch
    end
    try
        if any(strcmp(Parameters, 'OutputDataType'))
            set_param(Blocks{Index},'OutputDataType',DataType);
        end
    catch
    end
end

end