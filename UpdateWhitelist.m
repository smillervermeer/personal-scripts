function UpdateWhitelist

%% Initialize
% Get information from project
Silent = false;
Function = @UpdateTable;
Project = currentProject;
Files = dir(fullfile('Source', '**'));
WhitelistFile = [strrep(char(Project.Name), 'Library', 'Whitelist'), ...
    '.xlsx'];

% Read in whitelist spreadsheet
WhitelistModels = readtable(WhitelistFile, 'Sheet', 'Models');
WhitelistScripts = readtable(WhitelistFile, 'Sheet', 'Scripts');

% Update Git
system('git fetch origin master');

%% Loop over all scripts
Scripts = Files(arrayfun(@(x) ~x.isdir && ...
    endsWith(x.name, {'.mlapp', '.m', '.p'}), Files));
% Remove any old files
[~, IntersectIndex, ~] = intersect(WhitelistScripts.Name, ...
    cellfun(@(x) regexp(x, '.*(?=\.)', 'match'), {Scripts.name})');
WhitelistScripts = WhitelistScripts(IntersectIndex, :);
WhitelistScriptsOut = table( ...
    'Size', [height(Scripts), width(WhitelistScripts)], ..., ...
    'VariableNames', WhitelistScripts.Properties.VariableNames, ...
    'VariableTypes', ...
    varfun(@class, WhitelistScripts, 'OutputFormat', 'cell'));
for Index = 1:height(Scripts)
    File = Scripts(Index);
    [~, Output] = system(sprintf( ...
        'git log -n 1 --pretty=format:%%H -- "%s"', ...
        fullfile(File.folder, File.name)));
    [~, Name, ~] = fileparts(File.name);
    WhitelistScriptsOut(Index, :) = feval(Function, WhitelistScripts, ...
        Name, Output, Silent); %#ok<FVAL>
end

%% Loop over all models
Models = Files(arrayfun(@(x) ~x.isdir && ...
    endsWith(x.name, '.slx') && ~contains(x.name, 'Harness'), Files));
% Remove any old files
[~, IntersectIndex, ~] = intersect(WhitelistModels.Name, ...
    cellfun(@(x) regexp(x, '.*(?=\.)', 'match'), {Models.name})');
WhitelistModels = WhitelistModels(IntersectIndex, :);
WhitelistModelsOut = table(...
    'Size', [height(Models), width(WhitelistModels)], ...
    'VariableNames', WhitelistModels.Properties.VariableNames, ...
    'VariableTypes', ...
    varfun(@class, WhitelistModels, 'OutputFormat', 'cell'));
for Index = 1:height(Models)
    File = Models(Index);
    [~, Name, Extension] = fileparts(File.name);
    % Skip directory entries
    if File.isdir || ~isequal(Extension, '.slx') || ...
            contains(Name, 'Harness')
        continue
    end
    % All 3 parts of a valid test
    Model = fullfile(File.folder, File.name);
    Harness = fullfile(File.folder, strrep(File.name, '.slx', 'Harness.slx'));
    Test = fullfile(File.folder, strrep(File.name, '.slx', '.xlsx'));
    Parts = {Model, Harness, Test};
    % Skip if any don't existver
    if ~all(isfile(Parts))
        continue
    end
    LastChangedCommit = cell(1, length(Parts));
    LastChangedDate = zeros(1, length(Parts));
    for PartIndex = 1:length(Parts)
        [~, Output] = system(sprintf( ...
            'git log -n 1 --pretty=format:%%H,%%at -- "%s"', ...
            Parts{PartIndex}));
        Output = strsplit(Output, ',');
        LastChangedCommit(PartIndex) = Output(1);
        LastChangedDate(PartIndex) = str2double(Output{2});
    end
    [~, DateIndex] = max(LastChangedDate);
    LastChangedCommit = LastChangedCommit{DateIndex};
    WhitelistModelsOut(Index, :) = feval(Function, WhitelistModels, ...
        Name, LastChangedCommit, Silent); %#ok<FVAL>
end
% Remove any empty rows
WhitelistModelsOut = WhitelistModelsOut( ...
    rowfun(@(x) ~isempty(x{:}), WhitelistModelsOut, ...
    'InputVariables', 'Name', 'OutputFormat', 'uniform'), :);

%% Finalize
% Sort tables
[~, Order] = sortrows(rowfun(@lower, WhitelistModelsOut, 'InputVariables', 'Name'));
WhitelistModelsOut = WhitelistModelsOut(Order, :);
[~, Order] = sortrows(rowfun(@lower, WhitelistScriptsOut, 'InputVariables', 'Name'));
WhitelistScriptsOut = WhitelistScriptsOut(Order, :);

% Write back to spreadsheet file
writetable(WhitelistModelsOut, WhitelistFile, 'Sheet', 'Models', 'WriteMode', 'OverwriteSheet')
writetable(WhitelistScriptsOut, WhitelistFile, 'Sheet', 'Scripts', 'WriteMode', 'OverwriteSheet')

%% Internal Functions
    function WhitelistRow = UpdateTable(Whitelist, Name, ...
            LastChangedCommit, Silent)
        WhitelistIndex = strcmp(Whitelist.Name, Name);
        if ~any(WhitelistIndex)
            Whitelist = [Whitelist; {Name, LastChangedCommit}];
            WhitelistIndex = height(Whitelist);
        else
            WhitelistCommit = char(Whitelist.Commit(WhitelistIndex));
            if ~isequal(WhitelistCommit, LastChangedCommit)
                if ~Silent
                    fprintf('# %s\n', Name);
                end
                Whitelist.Commit{WhitelistIndex} = LastChangedCommit;
            end
        end
        WhitelistRow = Whitelist(WhitelistIndex, :);
    end

end