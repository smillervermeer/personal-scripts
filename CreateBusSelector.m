function CreateBusSelector(System, Bus, Position, Prefix)

Padding = 100;

if nargin < 4
    Prefix = '';
end
Prefix = [Prefix, Bus.Name];

%% Sanity check
if isempty(Bus.Elements)
    return;
end

%% Call recursively if nested buses exist
for Index = 1:length(Bus.Elements)
    BusName = extractBefore(Bus.Elements(Index).Element, '.');
    % Find elements in the nested bus and format a new sub-bus
    BusElements = Bus.Elements( ...
        arrayfun(@(x) startsWith(x.Element, [BusName, '.']), Bus.Elements));
    for BusElementIndex = 1:length(BusElements)
        BusElements(BusElementIndex).Element = ...
            strrep(BusElements(BusElementIndex).Element, [BusName, '.'], '');
    end
    % Move position over
    NextPosition = [Position(1) - Padding, ...
        Position(2) + ((Index - 1) * 45), ...
        Position(3) - Padding, ...
        Position(4) + ((Index - 1) * 45)];
    % Call recursively
    CreateBusSelector(System, ...
        struct('Name', BusName, 'Elements', BusElements), ...
        NextPosition, Prefix);
end

%% Make a BusCreator
BlockName = [System, '/', Prefix, 'BusCreator'];
BusElements = {Bus.Elements.Element};
for BusElementIndex = 1:length(BusElements)
    if contains(BusElements{BusElementIndex}, '.')
        BusElements{BusElementIndex} = ...
            extractBefore(BusElements{BusElementIndex}, '.');
    end
end
BusElements = unique(BusElements);
if getSimulinkBlockHandle(BlockName) == -1
    try %#ok<TRYNC>
        add_block('<Library>_Base_Library/BusCreator', BlockName, ...
            'Inputs', strjoin(BusElements, ','), ...
            'Position', Position);
    end
else
    set_param(BlockName, 'Inputs', strjoin(BusElements, ','));
end

%% Connect up lines
for Index = 1:length(Bus.Elements)
    Element = Bus.Elements(Index).Element;
    if contains(Element, '.')
        Element = extractBefore(Element, '.');
        DestBlock = [Prefix, 'BusCreator'];
        Elements = get_param([System, '/', DestBlock], 'Inputs');
        Elements = strsplit(Elements, ',');
        DestPort = find(strcmp(Elements, Element));
        try
            Line = add_line(System, [Prefix, Element, 'BusCreator/1'], ...
                [DestBlock, '/', num2str(DestPort)], 'autorouting', 'smart');
            set_param(Line, 'Name', Element);
        catch Ex
            if ~isequal(Ex.identifier, 'Simulink:Commands:AddLineDestAlreadyConnected')
                warning(Ex.message)
            end
        end
    else
        SrcName = get_param(Bus.Elements(Index).PortConnectivity.SrcBlock, 'Name');
        Src = [SrcName, '/', ...
            num2str(Bus.Elements(Index).PortConnectivity.SrcPort + 1)];
        DestBlock = [Prefix, 'BusCreator'];
        Elements = get_param([System, '/', DestBlock], 'Inputs');
        Elements = strsplit(Elements, ',');
        DestPort = find(strcmp(Elements, Element));

        % Check if a connection is already made
        PortConnectivity = get_param([System, '/', DestBlock], 'PortConnectivity');
        PortConnectivity = PortConnectivity(~cellfun(@isempty, {PortConnectivity.SrcBlock}));
        if PortConnectivity(DestPort).SrcBlock == -1
            %         try
            if isequal(get_param([System, '/', SrcName], 'BlockType'), 'BusSelector')
                SrcElements = get_param([System, '/', SrcName], 'OutputSignals');
                SrcElements = strsplit(SrcElements, ',');
                SrcElements = cellfun(@ExtractElement, SrcElements, 'UniformOutput', false);
                if ~any(strcmp(SrcElements, Element))
                    % Need to insert SignalConversion
                    SignalConversionPosition = [Position(1) - 100, Position(2), ...
                        Position(3), Position(4)];
                    SignalConversion = add_block( ...
                        '<Library>_Base_Library/SignalConversion', ...
                        [System, '/SignalConversion'], 'MakeNameUnique', 'on', ...
                        'Position', SignalConversionPosition);
                    add_line(System, Src, ...
                        [get_param(SignalConversion, 'Name'), '/1'], ...
                        'autorouting', 'smart');
                    Line = add_line(System, ...
                        [get_param(SignalConversion, 'Name'), '/1'], ...
                        [Prefix, 'BusCreator/', num2str(DestPort)], ...
                        'autorouting', 'smart');
                    set_param(Line, 'Name', Element);
                else
                    Line = add_line(System, Src, ...
                        [Prefix, 'BusCreator/', num2str(DestPort)], ...
                        'autorouting', 'smart');
                end
            else
                Line = add_line(System, Src, ...
                    [Prefix, 'BusCreator/', num2str(DestPort)], ...
                    'autorouting', 'smart');
                set_param(Line, 'Name', Element);
            end
            %         catch Ex
            %             if ~isequal(Ex.identifier, 'Simulink:Commands:AddLineDestAlreadyConnected')
            %                 warning(Ex.message)
            %             end
            %         end
        end
    end
    % Clean up lines; blocks will get cleaned up in the calling script
    if getSimulinkBlockHandle(Bus.Elements(Index).Block) ~= -1
        Src = [get_param(Bus.Elements(Index).PortConnectivity.SrcBlock, 'Name'), ...
            '/', num2str(Bus.Elements(Index).PortConnectivity.SrcPort + 1)];
        try
            delete_line(System, Src, ...
                [get_param(Bus.Elements(Index).Block, 'name'), '/1'])
        catch Ex
            if ~isequal(Ex.identifier, 'Simulink:Commands:InvLineSpecifier')
                warning(Ex.message)
            end
        end
    end
end
    function StringOut = ExtractElement(StringIn)
        if contains(StringIn, '.')
            StringOut = extractAfter(StringIn, '.');
        else
            StringOut = StringIn;
        end
    end
end
