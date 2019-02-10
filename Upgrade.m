% Libraries = rdir('source\**\*.slx');
ConfigSet = 'tools\configSets\MBSD 12-28-2019.mat';

Models = get_param(Simulink.allBlockDiagrams(), 'Name');
if isempty(Models)
    return
end
if iscell(Models)
    Models = Models(cellfun(@isempty,regexp(Models, '.*_Library|simulink')));
else
    Models = {Models};
end

MoreModels = [];
for i=1:length(Models)
    if ~contains(Models, [Models{i}, 'Harness'])
        MoreModels = [MoreModels, {[Models{i}, 'Harness']}];
    end
end
Models = [Models; MoreModels'];

StartIndex = 1;

for i=StartIndex:length(Models)
    % Get properties
    FileName = Models{i};
    %[~, LibraryName, ~] = fileparts(Models(i));
    LibraryName = FileName;
    
    
    fprintf('%u/%u - %s', i, length(Models), LibraryName);
    
    % Load model
    open_system(FileName);
    
    % If its a harness, apply our new ConfigSet
    if ~bdIsLibrary(LibraryName)
        Simulink.BlockDiagram.loadActiveConfigSet(LibraryName, ConfigSet);
        
        % Run test
        ModelToTest.Name = strrep(LibraryName, 'Harness', '');
        ModelToTest.Harness = LibraryName;
        ModelToTest.Test = [ModelToTest.Name, '.xlsx'];
        Results = Vermeer_Tools.TestModel(ModelToTest);
        fprintf(' - %s\n', Results.Status);
    else
        fprintf('\n', Results.Status);
    end
    
    % Save
    Vermeer_Base.ModelPreSave(LibraryName);
    save_system(FileName);
    
    % Close
    close_system(FileName);
end

bdclose('all')