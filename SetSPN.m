function Error = SetSPN(SPN, Block, SA)

if nargin < 2
    Block = gcb;
end
Model = bdroot(Block);
Tx = isequal(get_param(Block, 'MaskType'), 'SPNTx');
if nargin < 3 || SA <= 0
    SA = -1;
end

J1939Configuration = Simulink.data.evalinGlobal(Model, 'J1939Configuration');

SPNTableRow = [];
for NetworkIndex=1:length(J1939Configuration.Networks)
    if J1939Configuration.Networks(NetworkIndex).Port == -1
        continue
    end
    if Tx
        SA = J1939Configuration.Networks(NetworkIndex).SourceAddress;
    end
    Index = find(J1939Configuration.Networks(NetworkIndex).SPNs.SPN == SPN);
    if Index ~= -1
        NewRow = J1939Configuration.Networks(NetworkIndex).SPNs(Index, :);
        NewRow.Network = ...
            repmat({J1939Configuration.Networks(NetworkIndex).Name}, ...
            height(NewRow),1);
        SPNTableRow = [SPNTableRow; NewRow];
        
    end
end

if height(SPNTableRow) > 1
    Bus = '';
    BusString = unique(SPNTableRow.Network);
    if length(BusString) > 1
        BusString = strjoin(BusString, ',');
        while ~any(strcmp(Bus, SPNTableRow.Network))
            fprintf('# Which Bus (%s): ', BusString)
            Bus = input('', 's');
        end
        SPNTableRow(~strcmp(Bus, SPNTableRow.Network), :) = [];
    end
end

if ~Tx && height(SPNTableRow) > 1
    while ~any(SA == SPNTableRow.SA)
        SAString = strjoin(arrayfun(@num2str, SPNTableRow.SA, ...
            'UniformOutput', false), ',');
        fprintf('# Which SA (%s): ', SAString)
        SA = input('');
    end
    if SA ~= -1
        SPNTableRow(SPNTableRow.SA ~= SA, :) = [];
    end
end

% if Tx 
%    SPNTableRow(SPNTableRow.SA ~= SA, :) = []; 
% end



if isempty(SPNTableRow)
    warning('SPN not found')
    Error = true;
    return
end

Network = SPNTableRow.Network;
SPNId = <Library>_J1939.GenerateUniqueSPNId(SPNTableRow);
Tx = strcmp(get_param(Block, 'MaskType'), 'SPNTx');
UniqueName = <Library>_J1939.GenerateUniqueSPNVariableName(Network{1}, SPNId, Tx);

set_param(Block, 'UniqueName', UniqueName)

Error = ReapplyMlapp(Block);

end