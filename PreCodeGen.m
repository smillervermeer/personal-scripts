function PreCodeGen(varargin)

%% Parse input arguments
Parser = inputParser;
addOptional(Parser, 'Model', bdroot(gcs), @ischar)
addParameter(Parser, 'ReloadJ1939', false, @islogical);
parse(Parser, varargin{:})
Model = Parser.Results.Model;
ReloadJ1939 = Parser.Results.ReloadJ1939;

%% Setup
% Sanity check on model
if ~bdIsLoaded(Model)
    error(['Model ', Model, ' is not loaded!'])
end
% Find code folder
CodeFolder = fullfile('Cache', [Model, '_Code']);
% Make temporary folder
TempDir = tempname;
mkdir(TempDir);

%% Reload J1939
if ReloadJ1939
    Spreadsheet = get_param([Model, '/CAN/J1939Properties'], 'DataSource');
    Vermeer_J1939.LoadConfiguration(Model, Spreadsheet);
end

%% CodeGen
% Copy out existing codegen
copyfile(CodeFolder, TempDir)
% Run new pre-codegen
ert_make_rtw_hook('entry', Model, '', '', ...
    struct('TargetLangExt', {'c'}), '')
% Copy new over existing
copyfile(CodeFolder, TempDir)
% Move everything back
copyfile(TempDir, CodeFolder)

%% Clean up
rmdir(TempDir, 's');

end