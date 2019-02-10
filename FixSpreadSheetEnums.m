function FixSpreadSheetEnums(Spreadsheet)

if nargin < 1
    Spreadsheet = [bdroot, '.xlsx'];
    Spreadsheet = strrep(Spreadsheet, 'Harness', '');
    
end

if isempty(which(Spreadsheet))
    error('File not found!')
end

SpreadsheetFileName = which(Spreadsheet);
ImportOptions = detectImportOptions(SpreadsheetFileName);
ImportOptions = setvartype(ImportOptions, 'char');
ImportOptions = setvartype(ImportOptions, 'Time', 'double');
SheetNames = sheetnames(SpreadsheetFileName);

for Sheet = 1:length(SheetNames)
    Data = readtable(SpreadsheetFileName, ImportOptions, 'Sheet', SheetNames(Sheet));
    Changed = false;
    for  Column = 1:width(Data)
        
        % Skip comments and time
        if any(strcmp(Data.Properties.VariableNames{Column}, ...
                {'Time', 'Comment'}))
            continue
        end
        
        % Replace the stuff below with the enum you're replacing
        if contains(Data.Properties.VariableNames{Column}, {'AutomationState', 'AutomationStatus'})
            Changed = true;
            Data(:,Column) = varfun(@(x) regexprep(x, 'AutomationState', 'Algorithm_AutomationState'), ...
                Data, 'InputVariables',Data.Properties.VariableNames{Column});
            Data(:,Column) = varfun(@(x) regexprep(x, 'AutomationStatus', 'Algorithm_AutomationState'), ...
                Data, 'InputVariables',Data.Properties.VariableNames{Column});
        end
    end
    if Changed
        [~, ShortFileName, ~] = fileparts(SpreadsheetFileName);
        fprintf('# %s - %s\n', ShortFileName, SheetNames(Sheet));
        writetable(Data, SpreadsheetFileName, 'Sheet', SheetNames(Sheet));
    end
end


%
% Model = Spreadsheet;
% Model = strrep(Model, '.', '');
% Model = strrep(Model, 'xlsx', '');
% Model = strrep(Model, 'Harness', '');

% Result = TestSingleModel([Model, 'Harness'])

% bdclose('all')

end