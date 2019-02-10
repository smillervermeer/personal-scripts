function CleanWorkspace()

Model = bdroot(gcs);
DictionaryFileName = get_param(Model, 'DataDictionary');

DictionaryObject = Simulink.data.dictionary.open(DictionaryFileName);

DesignSection = getSection(DictionaryObject, 'Design Data');
Entries = find(DesignSection);

assignin('base', 'Entries', Entries);
evalin('base', 'clear(Entries.Name)');
evalin('base', 'clear(''Entries'')');

end