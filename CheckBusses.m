function CheckBusses(StartIndex)
lastwarn('');
Description = 'Select elements of a bus or the entire bus, signal, or message from the input port.';
BusElements = find_system(gcs, 'LookUnderMasks', 'on', ...
    'BlockDescription', Description);
AlreadyChecked = {};

if nargin < 1
    StartIndex = 1;
end

for Index = StartIndex:length(BusElements)
    PortPath = fullfile(fileparts(BusElements{Index}), ....
        get_param(BusElements{Index}, 'PortName'));
    
    if any(contains(AlreadyChecked, PortPath))
        continue
    end
    fprintf('# %u/%u - %s\n', Index, length(BusElements), PortPath)
    
    Ports = get_param(BusElements{Index}, 'PortHandles');
    BusSignals = get_param([Ports.Inport, Ports.Outport], 'SignalHierarchy');
    List = Vermeer_Basic.BusChildren(BusSignals); %#ok<NASGU>
    
    AlreadyChecked = [AlreadyChecked; PortPath]; %#ok<AGROW>
    
%     [WarningMessage, WarningId] = lastwarn();
%     if ~isempty(WarningMessage)
%         switch(WarningId)
%             case {'Simulink:BusElPorts:SigHierPropOutputDoesNotMatchInput'}
%                 error(WarningMessage)
%                 fprintf('\n');
%             otherwise
%                 disp(WarningMessage)
%                 continue
%         end
%     end
end

end