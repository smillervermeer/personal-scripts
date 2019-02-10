% Scan the current project to find folders and get a default
Project = currentProject;
Folders = Vermeer_HAL.FindFolders(Project.RootFolder, '', 'cache|slprj');
Model = Vermeer_HAL.FindFiles(Folders, '.*DU(_[0-9]+)?.slx$');
DefaultModelName = strrep(Model(1).Name, '.slx', '');
ShortModelName = regexprep(DefaultModelName, '_[0-9]+', '');

% Parse
BinaryFolder = Vermeer_HAL.FindFolders(Project.RootFolder, '', 'slprj');
ModelName = DefaultModelName;
Build = 'release';

% Find binary
Binary = Vermeer_HAL.FindFiles(BinaryFolder, [ModelName, '\.exe']);
Binary(~contains({Binary.Folder}, Build)) = [];
if isempty(Binary)
    Error = MException('VermeerQt:Deploy:NoBinary', ...
        'No binaries found. Please run a release build in QtCreator');
    throw(Error);
elseif length(Binary) > 1
    warning(['Multiple ', Build, ' builds found, using ', ...
        fullfile(Binary(1).Folder, Binary(1).Name)])
    Binary = Binary(1);
end

% Read in makefile to get information
MakeFile = fullfile(Binary.Folder, '..', ...
    ['Makefile.', regexprep(Build,'(\<[a-z])','${upper($1)}')]);
if ~isfile(MakeFile)
    Error = MException('VermeerQt:Deploy:NoMakefile', ...
        'Could not find a makefile');
    throw(Error);
end
MakeFileContents = fileread(MakeFile);
MakeFileContents = strsplit(MakeFileContents, newline);

% Find qmake
QMakeFolder = MakeFileContents{contains(MakeFileContents,'QMAKE ')};
QMakeFolder = regexp(QMakeFolder, '(?<=QMAKE\s+=).*?(?=qmake\.exe)', ...
    'match');
QMakeFolder = strtrim(char(QMakeFolder));
Architecture = regexp(QMakeFolder, '(?<=mingw\d*_)\d{2}', 'match');
Architecture = Architecture{1};
WinDeployQt = fullfile(QMakeFolder, 'windeployqt.exe');
if ~isfile(WinDeployQt)
    Error = MException('VermeerQt:Deploy:NoWinDeployQt', ...
        'Could not find windeployqt.exe');
    throw(Error);
end

% Run display
Path = getenv('PATH');
if ~contains(Path, QMakeFolder)
    setenv('PATH', [Path, ';', QMakeFolder]);
end
LogFile = 'C:\Users\sm19052\OneDrive - Vermeer Corporation\Documents\LogFiles\D550.vrm';
[Status, Output] = system(sprintf('"%s"', fullfile(Binary.Folder, Binary.Name)))
setenv('PATH', Path);

% Get PID
% Output = 'No tasks are running';
% while contains(Output, 'No tasks are running')
%     [Status, Output] = system( ...
%         'tasklist /FI "WINDOWTITLE eq Vermeer Service Tool" /nh /fo csv');
%     pause(1)
% end
% Rows = strsplit(Output, newline);
% Rows = Rows(~cellfun(@isempty, Rows));
% Data = {};
% for Index = 1:length(Rows)
%     Data(Index, :) = strrep(strsplit(Rows{Index}, ','), '"', '');
% end
% PIDs = Data(:,2);
% PIDs = cellfun(@str2double, PIDs);









