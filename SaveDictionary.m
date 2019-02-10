function SaveDictionary()

DataDictFilePaths = Simulink.data.dictionary.getOpenDictionaryPaths();

for i=1:length(DataDictFilePaths)
    DataDictObject = Simulink.data.dictionary.open(DataDictFilePaths{i});
    saveChanges(DataDictObject);
    close(DataDictObject);
end

end