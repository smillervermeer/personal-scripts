function BuildDisplays()

    % Get recent directories from Matlab history
    Settings = settings();
    History = Settings.matlab.desktop.currentfolder.History.PersonalValue;
    % Remove any directories that don't have a Simulink project in them
    Indices = cellfun(@(x) ~isempty(Vermeer_HAL.FindFiles(x, '.*.prj')), ...
        History);
    History = History(Indices);
    % Format and prompt the user for which project directory to use
    HistoryStr = strrep(strjoin(strcat({Tab}, ...
        cellstr(string(1:length(History))), ...
        {['.', Tab]}, History), newline), '\', '\\');
    Input = input(['# Your recent history:', newline, HistoryStr, ...
        newline, '# Prompt - Which project:'], 's');
    ProjectDir = History{str2double(Input)};
    % Find any relevant subfolders in the chosen project directory
    ExcludeFilter = 'slprj|code|libraries|\+|*_ert_rtw';
    Subfolders = Vermeer_HAL.FindFolders(ProjectDir, '', ExcludeFilter);
    Indices = cellfun(@isempty,regexp(Subfolders, ExcludeFilter));
    Subfolders = Subfolders(Indices);
    Subfolders = [Subfolders, ProjectDir];
    % Find any models in the subfolders
    Models = Vermeer_HAL.FindFiles(Subfolders, '^.*.slx$', '.*_Library.*');
    % Format and prompt the user for which model to use
    ModelsStr = strrep(strjoin(strcat({Tab}, ...
        cellstr(string(1:length(Models))), ...
        {['.', Tab]}, {Models.Name}), newline), '\', '\\');
    Input = input([ModelsStr, newline, '# Prompt - Which model:'], 's');
    Model = fullfile(Models(str2double(Input)).Folder, ...
        Models(str2double(Input)).Name);
    
    
    % Build package
    BuildAppPackage(Model, TempFolder, EnableTouch);
    Destination = fileparts(Model);


end