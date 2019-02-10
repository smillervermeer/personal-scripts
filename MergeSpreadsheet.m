function MergeSpreadsheet


Revision = 'origin/dev';
LocalSpreadsheet = 'Applications/Common/Parameters.xlsx';
UpstreamSpreadsheet = 'Applications/Common/Parameters_upstream.xlsx';
BaseSpreadsheet = 'Applications/Common/Parameters_base.xlsx';

%% Fetch first
% Execute Git command
% [Status, Results] = system('git fetch');
% If execution unsuccessful, just return
% if Status ~= 0
%     error(Results)
% end

% Find common ancestor
[Status, Results] = system(sprintf( ...
    'git merge-base HEAD %s', Revision));
if Status ~=0
    error(Results)
end
BaseRevision = strtrim(Results);

%% Get a local copy of the last version in Git
% Make sure path is clear
if isfile(UpstreamSpreadsheet)
    delete(UpstreamSpreadsheet)
end
% Execute Git command
[Status, Results] = system(sprintf('git show %s^:"%s" > "%s"', ...
    Revision, LocalSpreadsheet, UpstreamSpreadsheet));
% If execution unsuccessful, just return
if Status ~= 0
    error(Results)
end
% Make sure path is clear
if isfile(BaseSpreadsheet)
    delete(BaseSpreadsheet)
end
% Execute Git command
[Status, Results] = system(sprintf('git show %s^:"%s" > "%s"', ...
    BaseRevision, LocalSpreadsheet, BaseSpreadsheet));
% If execution unsuccessful, just return
if Status ~= 0
    error(Results)
end

%% Compare
Warning = warning('query', 'MATLAB:table:ModifiedAndSavedVarnames');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
Sheets = sheetnames(LocalSpreadsheet);
for Index = 1:length(Sheets)
    Sheet = Sheets{Index};
    % Read in everything as chars to avoid any NaN issues
    LocalOptions = detectImportOptions(LocalSpreadsheet, 'Sheet', Sheet);
    LocalOptions.VariableTypes = ...
        repmat({'char'}, 1, length(LocalOptions.VariableTypes));
    UpstreamOptions = detectImportOptions(UpstreamSpreadsheet, 'Sheet', Sheet);
    UpstreamOptions.VariableTypes = ...
        repmat({'char'}, 1, length(UpstreamOptions.VariableTypes));
    BaseOptions = detectImportOptions(BaseSpreadsheet, 'Sheet', Sheet);
    BaseOptions.VariableTypes = ...
        repmat({'char'}, 1, length(BaseOptions.VariableTypes));
    % Read tables
    LocalTable = readtable(LocalSpreadsheet, LocalOptions, 'Sheet', Sheet);
    UpstreamTable = readtable(UpstreamSpreadsheet, UpstreamOptions, 'Sheet', Sheet);
    BaseTable = readtable(BaseSpreadsheet, BaseOptions, 'Sheet', Sheet);
    % Compare
    LocalToUpstream = setdiff(LocalTable, UpstreamTable);
    if ~isempty(LocalToUpstream)
        LocalToBase = setdiff(LocalTable, BaseTable);
        UpstreamToBase = setdiff(UpstreamTable, BaseTable);
        Excel = actxserver('Excel.Application');
        Cleanup = onCleanup(@() Excel.Quit);
        if ~isempty(LocalToBase) && ~isempty(UpstreamToBase)
            error('Both modified');
        elseif ~isempty(LocalToBase)
            Workbook = Excel.Workbooks.Open(which(LocalSpreadsheet));
            Sheet = Workbook.Worksheets.Item(Index);
        else % ~iesmpty(UpstreamToBase)
            Workbook = Excel.Workbooks.Open(which(UpstreamSpreadsheet));
            Sheet = Workbook.Worksheets.Item(Index);
        end
        
            
            
        fprintf('# Using sheet %s from %s, no conflicting local changes\n', ...
            Sheet, Revision)
        % Excel wizardry
        
        
    end
    
    
end
warning(Warning.state, 'MATLAB:table:ModifiedAndSavedVarnames');


end