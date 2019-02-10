function UpdateSPNs(System)

if nargin < 1
    System = gcs;
end
Model = bdroot(System);

J1939Configuration = Simulink.data.evalinGlobal(Model, 'J1939Configuration');
InvalidBlocks = <Library>_J1939.ListSPNBlocks(Model, 'Option', 'invalid');

Blocks = find_system(System, 'FollowLinks', 'on', ...
    'LookUnderMasks', 'all', 'MaskType', 'SPNTx');
Blocks = [Blocks; find_system(System, 'FollowLinks', 'on', ...
    'LookUnderMasks', 'all', 'MaskType', 'SPNRx')];

for Index = 1:length(Blocks)
    if ~any(InvalidBlocks == getSimulinkBlockHandle(Blocks{Index}))
        continue
    end
    NameParts = <Library>_J1939.GetUniqueSPNVariableParts( ...
        get_param(Blocks{Index}, 'UniqueName'), 'ExpandId', true);
    SPNDescription = get_param(Blocks{Index}, 'SPNDescription');
    fprintf('#\n# %s\n', SPNDescription)
    fprintf('# <a href="matlab:hilite_system(''%s'')">%s</a>\n', ...
        Blocks{Index}, Blocks{Index})
    NewSPN = FindSimilarName(J1939Configuration, SPNDescription);
    if NewSPN == -1
        Error = true;
        while(Error)
            fprintf('# New SPN: ')
            NewSPN = input('');
            Error = SetSPN(NewSPN, Blocks{Index});
        end
    else
        fprintf('# New SPN: %u\n', NewSPN)
        Error = SetSPN(NewSPN, Blocks{Index}, NameParts.SPN.SA);
        while(Error)
            fprintf('# New SPN: ')
            NewSPN = input('');
            Error = SetSPN(NewSPN, Blocks{Index});
        end
    end
    NameParts = <Library>_J1939.GetUniqueSPNVariableParts( ...
        get_param(Blocks{Index}, 'UniqueName'), 'ExpandId', true);
    SPNDescription = get_param(Blocks{Index}, 'SPNDescription');
    fprintf('# New Name: %s\n', SPNDescription)
end


    function SPN = FindSimilarName(J1939Configuration, OldDescription)
        SPN = -1;
        for NetworkIndex = 1:length(J1939Configuration.Networks)
            if J1939Configuration.Networks(NetworkIndex).Port == -1
                continue
            end
            AllDescriptions = J1939Configuration.Networks(NetworkIndex).SPNs.Label;
            OldDescription = CleanDescription(OldDescription);
            AllDescriptions = CleanDescription(AllDescriptions);
            NewDescriptionIndex = find(strcmp(OldDescription, AllDescriptions));
            if ~isempty(NewDescriptionIndex)
                SPN = J1939Configuration.Networks(NetworkIndex). ...
                    SPNs(NewDescriptionIndex, :).SPN;
                if length(SPN) > 1
                    SPN = SPN(1);
                end
                break
            end
        end
    end

    function Output = CleanDescription(Input)
        Output = lower(Input);
        Output = strrep(Output, ' ', '');
        Output = strrep(Output, 'statue', 'status');
        Output = strrep(Output, 'operationalstatus', 'action');
        Output = strrep(Output, 'commandstatus', 'command');
        Output = strrep(Output, 'errorstatus', 'error');
        Output = strrep(Output, 'temperature', 'temp');
        Output = strrep(Output, 'normallyclosedcontact', 'nc');
        Output = strrep(Output, 'normallyopencontact', 'no');
        Output = strrep(Output, 'stabilizer', 'outrigger');
        Output = strrep(Output, 'seperation', 'separation');
        
    end

end