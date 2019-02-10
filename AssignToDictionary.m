function AssignToDictionary(Model)

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
Changed = false;
for Index = 1:length(Entries)
    Exists = evalin('base', sprintf('exist(''%s'')', Entries{Index}));
    if Exists
        NewValue = evalin('base', Entries{Index});
        OldValue = Dictionary.getEntry(['Design Data.', Entries{Index}]);
        if ~isequal(NewValue, OldValue)
            Dictionary.setEntry(['Design Data.', Entries{Index}], NewValue);
            Changed = true;
        end
        evalin('base', sprintf('clear(''%s'')', Entries{Index}));
    end 
end

if Changed
    saveChanges(Dictionary);
end

end