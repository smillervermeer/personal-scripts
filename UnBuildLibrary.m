function UnBuildLibrary(BuiltLibrary, UnBuiltLibrary)

% Built locations
BuiltLibrary = ['<Library>_' BuiltLibrary, '_Library.slx'];
[BuiltFolder, ~, ~] = fileparts(which(BuiltLibrary));
PackageFolder = fullfile(BuiltFolder, ls(fullfile(BuiltFolder, '+*')));
CodeFolder = fullfile(BuiltFolder, 'Code');

% Unbuilt locations
SourceFolder = fullfile(UnBuiltLibrary, 'Source');
AssetsFolder = fullfile(UnBuiltLibrary, 'Assets');

ScriptFiles = dir(PackageFolder);

% Make regex
IgnoreRegex = '';
for Index = 1:length(ScriptFiles)
    BuiltFile = fullfile(ScriptFiles(Index).folder, ScriptFiles(Index).name);
    if ~isfile(BuiltFile)
        continue
    end
    [~, FunctionName, ~] = fileparts(BuiltFile);
    IgnoreRegex = [IgnoreRegex, '-I', FunctionName, '\( ']; %#ok<AGROW>
    
end

ScriptFiles = [ScriptFiles; dir(fullfile(CodeFolder, '**'))];

Index = 1;
while Index < length(ScriptFiles)
    BuiltFile = fullfile(ScriptFiles(Index).folder, ScriptFiles(Index).name);
    [~, ~, Extension] = fileparts(BuiltFile);
    if ~isfile(BuiltFile) || any(strcmp(Extension, {'.mlapp'}))
        Index = Index + 1;
        continue
    end
    if isequal(Extension, '.m')
        UnBuiltFile = dir(fullfile(SourceFolder, '**', ScriptFiles(Index).name));
    else
        UnBuiltFile = dir(fullfile(AssetsFolder, '**', ScriptFiles(Index).name));
    end
    if isempty(UnBuiltFile)
        switch Extension
            case '.m'
                Destination = SourceFolder;
            case {'.c', '.cpp'}
                Destination = fullfile(AssetsFolder, 'Code', 'Src');
            case '.h'
                Destination = fullfile(AssetsFolder, 'Code', 'Inc');
        end
        % If doesn't exist in Source, just copy it
        copyfile(BuiltFile, Destination)
        Index = Index - 1;
        continue;
    end
    UnBuiltFile = fullfile(UnBuiltFile.folder, UnBuiltFile.name);
    
    Args = '';
    if isequal(Extension, '.m')
        Args = [Args, IgnoreRegex]; %#ok<AGROW>
    end
    
    [Return, Output] = system(['git diff ', Args, '"', BuiltFile, '" "', UnBuiltFile, '"']);
    
    if Return ~= 0
        fprintf('# %s\n', strrep(BuiltFile, [BuiltFolder, filesep], ''))
        ParsedOutput = regexprep(Output, ...
            '(diff --git|index [a-f0-9]{7}|\-\-\-|\+\+\+).*', ...
            '\b', 'dotexceptnewline');
        ParsedOutput = strtrim(strrep(ParsedOutput, char(8), ''));
        ParsedOutput = strjoin(strcat({'#     '}, strsplit(ParsedOutput, newline)), newline);
        fprintf('%s\n', ParsedOutput)
        Decision = '';
        while ~any(strcmp(Decision, {'c','d','g','i'}))
            Decision = lower(input('(C)opy, (d)iff, (g)it diff, (i)gnore? (c/d/g/i):', 's'));
        end
        switch Decision
            case 'c'
                copyfile(BuiltFile, UnBuiltFile)
            case 'd'
                visdiff(BuiltFile, UnBuiltFile)
                Index = Index - 1; %#ok<NASGU,FXSET>
                % Probably don't use this since you have to exit this
                % script to use visdiff
                return
            case 'g'
                system(['git difftool ', IgnoreRegex, '-y "', BuiltFile, '" "', UnBuiltFile, '"'])
                Index = Index - 1; %#ok<FXSET>
        end
    end
    Index = Index + 1;
end
