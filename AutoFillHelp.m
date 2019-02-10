function AutoFillHelp(Block)

if nargin < 1
    Block = gcb;
end
if ~ischar(Block)
    Block = getfullname(Block);
end

Model = bdroot(Block);

if ~bdIsLibrary(Model)
    error('Not a library!')
end

Block = [Model, '/', Model];

if getSimulinkBlockHandle(Block) == -1
    error('Block (%s) not found!', Block);
end

Options = Simulink.FindOptions( ...
    'FollowLinks', true, ...
    'SearchDepth', 1, ...
    'LookUnderMasks', 'all', ...
    'MatchFilter', @Simulink.match.activeVariants);

% Inputs
Help = sprintf('Inputs:\n');
Inports = Simulink.findBlocksOfType(Block, 'Inport', Options);
for Index = 1:length(Inports)
    Help = [Help, MakePortString(Inports(Index))]; %#ok<AGROW> 
end
if isempty(Inports)
    Help = [Help, sprintf('N/A\n')];
end
Help = [Help, newline];

% Mask parameters
Help = [Help, sprintf('Mask Parameters:\n')];
Mask = Simulink.Mask.get(Block);
for Index = 1:length(Mask.Parameters)
    Help = [Help, MakeParameterString(Mask.Parameters(Index))]; %#ok<AGROW> 
end
if isempty(Mask.Parameters)
    Help = [Help, sprintf('N/A\n')];
end
Help = [Help, newline];

% Outputs
Help = [Help, sprintf('Outputs:\n')];
Outports = Simulink.findBlocksOfType(Block, 'Outport', Options);
for Index = 1:length(Outports)
    Help = [Help, MakePortString(Outports(Index))]; %#ok<AGROW> 
end
if isempty(Outports)
    Help = [Help, sprintf('N/A\n')];
end

Help = strtrim(Help);

% Also correct some other things
Init = get_param(Block, 'MaskInitialization');
[BlockResize, Start, End] = regexp(Init, ...
    '^Vermeer_Base\.BlockResize\(.*$', 'match', 'start', 'end', 'once');
BlockResize = strrep(BlockResize, 'gcb,', 'gcbh,');
[SizeMatch, SizeStart, SizeEnd] = regexp(BlockResize, ...
    ',\s+'''',\s*'''',\s*\d+\)', 'match', 'start', 'end', 'once');
if ~isempty(SizeMatch)
    Width = 6 * str2double(regexp(SizeMatch, '\d+', 'match', 'once'));
    BlockResize = [BlockResize(1:SizeStart-1), sprintf(', %u)', Width), ...
        BlockResize(SizeEnd+1:end)];
end
if ~endsWith(BlockResize, ';')
    BlockResize = sprintf('%s;', BlockResize);
end
Init = [Init(1:Start-1), BlockResize, Init(End+1:end)];

DefaultDisplay = '% Comment to ensure drawing command is called';
Display = get_param(Block, 'MaskDisplay');
if isempty(DefaultDisplay) || ...
        all(cellfun(@(x) startsWith(x, '%'), strsplit(Display, newline)))
    Display = DefaultDisplay;
end

% Assign help
set_param(Block, 'MaskHelp', Help, 'MaskInitialization', Init, ...
    'MaskDisplay', Display);

    function String = MakePortString(Block)
        Name = get_param(Block, 'Name');
        DataType = get_param(Block, 'OutDataTypeStr');
        Dimensions = get_param(Block, 'PortDimensions');
        if str2double(Dimensions) == -1
            Dimensions = '';
        else
            Dimensions = sprintf('(%s)', Dimensions);
        end
        Unit = get_param(Block, 'Unit');
        if any(strcmp(Unit, {'', 'inherit'}))
            Unit = '';
        else
            Unit = sprintf(' (%s)', Unit);
        end
        String = sprintf('%s - %s%s%s: \n', ...
            Name, DataType, Dimensions, Unit);
    end

    function String = MakeParameterString(Parameter)
        Name = strip(strtrim(Parameter.Prompt), ':');
        DataType = 'numeric';
        Dimensions = '(1)';
        Unit = '';
        UnitExpression = regexp(Name, '\(\w+\)', 'match', 'once');
        if ~isempty(UnitExpression)
            Unit = sprintf(' %s', UnitExpression);
            Name = regexp(Name, '.*?(?=\s*\(\w+\))', 'match', 'once');
        end
        String = sprintf('%s - %s%s%s: \n', ...
            Name, DataType, Dimensions, Unit);
    end

end