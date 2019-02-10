function ElementsToPorts(System)

%% Setup
% Parameters
if nargin < 1
    System = gcs;
end
Padding = 300;
AutoArrange = false;

% Initializations
Left = Inf;
Top = Inf;
Right = -Inf;
Suffix = '_temp';

%% Find all BusElements in the passed system
BusElementBlocks = find_system(System, 'LookUnderMasks', 'on', ...
    'SearchDepth', 1, 'IsBusElementPort', 'on');

%% Find the names of all buses
Buses = [];
for Index = 1:length(BusElementBlocks)
    Block = BusElementBlocks{Index};
    BusName = get_param(Block, 'PortName');
    % Skip duplicates; only need one e ntry per top-level bus
    if isempty(Buses) || ~any(strcmp({Buses.Name}, BusName))
        Buses = [Buses, struct( ...
            'Name', BusName, ...
            'Type', isequal(get_param(Block, 'BlockType'), 'Inport'), ...
            'Elements', [])]; %#ok<AGROW>
    end
end
% Exit early if no buses found
if isempty(Buses)
    return
end

%% Find the elements in each bus
for Index = 1:length(BusElementBlocks)
    Block = BusElementBlocks{Index};
    BusIndex = find(strcmp({Buses.Name}, get_param(Block, 'PortName')));
    Buses(BusIndex).Elements = [Buses(BusIndex).Elements, struct( ...
        'Block', Block, ...
        'Element', get_param(Block, 'Element'), ...
        'PortConnectivity', get_param(Block, 'PortConnectivity') ...
        )]; %#ok<AGROW>
    % Also get position of each element to help guess at where best to
    % place the In/Out ports
    % (There doesn't appear to be a way to just get the coordinates of
    % Simulink's 'zoom to fit' option, otherwise that could be used.)
    Position = get_param(Block, 'Position');
    Left = min(Left, Position(1));
    Top = min(Top, Position(2));
    Right = max(Right, Position(3));
end
% Apply padding to found positions
Left = Left - Padding;
Right = Right + Padding;

%% Insert an Inport and BusSelector for each inbus
% [left top right bottom]
InBuses = Buses([Buses.Type]);
YPosn = Top;
for Index = 1:length(InBuses)
    Bus = InBuses(Index);
    % See Vermeer_Base.BlockResize()
    BusSelectorHeight = max(45 * min(length(Bus.Elements), 18), 30);
    % Add Inport
    Position = [Left, YPosn + (BusSelectorHeight - 16) / 2, ...
        Left + 30, YPosn + (BusSelectorHeight + 16) / 2];
    add_block('Vermeer_Base_Library/In1', [System, '/In1'], ...
        'Position', Position, 'Name', [Bus.Name, '_temp']);
    OutputSignals = unique({Bus.Elements.Element});
    OutputSignals = OutputSignals(~cellfun(@isempty, OutputSignals));
    if ~all(cellfun(@isempty, OutputSignals))
        % Add BusSelector
        Position = [Left + 80, YPosn, Left + 85, YPosn + 91];
        BusSelector = add_block('Vermeer_Base_Library/BusSelector', ...
            [System, '/BusSelector'], ...
            'MakeNameUnique', 'on', ...
            'Position', Position, ...
            'OutputSignals', strjoin(OutputSignals, ','));
        BusSelectorName = get_param(BusSelector, 'Name');
        % Connect Inport and BusSelector
        add_line(System, [Bus.Name, Suffix, '/1'], ...
            [BusSelectorName, '/1'], 'autorouting', 'smart');
        % Connect BusSelector to the destination of each original
        % BusElementIn
        for ElementIndex = 1:length(Bus.Elements)
            BusElement = Bus.Elements(ElementIndex);
            Port = find(strcmp(OutputSignals, BusElement.Element));
            PortConnectivity = BusElement.PortConnectivity;
            % If a single BusElementIn went to multiple destinations,
            % connect each
            for DstIndex = 1:length(PortConnectivity.DstBlock)
                Dst = [get_param(PortConnectivity.DstBlock(DstIndex), 'Name'), ...
                    '/', num2str(PortConnectivity.DstPort(DstIndex) + 1)];
                delete_line(System, ...
                    [get_param(BusElement.Block, 'Name'), '/1'], Dst);
                if isempty(BusElement.Element)
                    add_line(System,[Bus.Name, '_temp/1'], ...
                        Dst, 'autorouting', 'smart');
                else
                    add_line(System, [BusSelectorName, '/', num2str(Port)], ...
                        Dst, 'autorouting', 'smart');
                end
            end
        end
    else
        % Edge case for if a single BusElementIn was used like a port
        % (i.e. no BusSelector is needed)
        BusElement = Bus.Elements(1);
        PortConnectivity = BusElement.PortConnectivity;
        for DstIndex = 1:length(PortConnectivity.DstBlock)
            Dst = [get_param(PortConnectivity.DstBlock(DstIndex), 'Name'), ...
                '/', num2str(PortConnectivity.DstPort(DstIndex) + 1)];
            delete_line(System, ...
                [get_param(BusElement.Block, 'Name'), '/1'], Dst);
            add_line(System, [Bus.Name, Suffix, '/1'], ...
                Dst, 'autorouting', 'smart');
        end
    end
    % Move the Y position further down for the next iteration
    YPosn = YPosn + BusSelectorHeight + 15;
end

%% Find the elements in each bus
for BusIndex = 1:length(Buses)
    for ElementIndex = 1:length(Buses(BusIndex).Elements)    
        Buses(BusIndex).Elements(ElementIndex).PortConnectivity = ...
            get_param(Buses(BusIndex).Elements(ElementIndex).Block, ...
            'PortConnectivity'); %#ok<AGROW> 
    end
end

%% Insert a BusCreator and Outport for each bus out
% [left top right bottom]
OutBuses = Buses(~[Buses.Type]);
YPosn = Top;
for Index = 1:length(OutBuses)
    Bus = OutBuses(Index);
    % See Vermeer_Base.BlockResize()
    BusCreatorHeight = max(45 * min(length(Bus.Elements), 18), 30);
    Position = [Right, YPosn, Right + 5, YPosn + 91];
    CreateBusSelector(System, Bus, Position);
    Position = [Right + 50, ...
        YPosn + (BusCreatorHeight - 16) / 2, ...
        Right + 80, ...
        YPosn + (BusCreatorHeight + 16) / 2];
    add_block('Vermeer_Base_Library/Out1', [System, '/Out1'], ...
        'Position', Position, 'Name', [Bus.Name, '_temp']);
    add_line(System, [Bus.Name, 'BusCreator/1'], ...
        [Bus.Name, Suffix, '/1'], 'autorouting', 'smart');
    YPosn = YPosn + BusCreatorHeight;
end
%% Final steps
% Delete all BusElement blocks
% Can't do this until the end as sometimes InBusElements have lines
% directly connected to OutBusElements and deleteing them early would cause
% undefined block handles for PortConnectivity
for Index = 1:length(BusElementBlocks)
    delete_block(BusElementBlocks{Index});
end
% Rename each bus now that the bus elements are all deleted and the
% original names are available
for Index = 1:length(Buses)
    Bus = Buses(Index);
    set_param([System, '/', Bus.Name, Suffix], 'Name', Bus.Name);
end
%% Finish up
% Auto-arrange, if requested
% User can press Ctrl+Z at the end to undo the auto-arrange if it does not
% produce beneficial results.
if AutoArrange
    Simulink.BlockDiagram.arrangeSystem(System);
end
% Zoom to fit
set_param(System, 'ZoomFactor', 'FitSystem')

end