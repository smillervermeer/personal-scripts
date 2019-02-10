function DumpDictionary(Model)

% Dumps the current model's data dictionary into the workspace
% Use CleanWorkspace() to clear them out again to allow you to build
% Use AssignToDictionary to assign any changes from the workspace back to
% the dictionary

DictionaryFileName = '';
if nargin < 1
    Model = bdroot(gcs);
else
    if contains(Model, 'sldd')
        DictionaryFileName = Model;
    end
end
if isempty(which(DictionaryFileName))
    DictionaryFileName = get_param(Model, 'DataDictionary');
end

Dictionary = Simulink.dd.open(DictionaryFileName);
Entries = Dictionary.getChildNames('Design Data');

for Index = 1:length(Entries)
    % Skip enums
    Value = Dictionary.getEntry(['Design Data.', Entries{Index}]);
    if isequal(class(Value), 'Simulink.data.dictionary.EnumTypeDefinition')
        continue
    end
    assignin('base', Entries{Index}, Value);
end

end