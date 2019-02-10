function ForceVersion(Model, Release, Version)

% If no model file(s) supplied, assume we want all .slx files
if nargin == 0
    Model = '*.slx';
end

% Get information about current Matlab version
if nargin <= 1
    Release = ['R', version('-release')];
    Version = sscanf(version, '%s(');
end

% Find files
Models = dir(['**\', Model]);
for i = 1:numel(Models)
    
    % Create temp location to extract to
    TempDir = fullfile(tempdir, Models(i).name);
    if ~exist(TempDir, 'dir')
        mkdir(TempDir)
    end
    
    % Unzip to temp location
    unzip(fullfile(Models(i).folder, Models(i).name), TempDir);
    
    % Replace relevant XML tags in the metadata files
    Files = dir(fullfile(TempDir, 'metadata', '*.xml'));
    for j = 1:numel(Files)
        Contents = fileread(fullfile(Files(j).folder, Files(j).name));
        Contents = regexprep(Contents, '<cp:version>.*</cp:version>', ...
            ['<cp:version>', Release, '</cp:version>']);
        Contents = regexprep(Contents, '<matlabRelease>.*</matlabRelease>', ...
            ['<matlabRelease>', Release, '</matlabRelease>']);
        Contents = regexprep(Contents, '<matlabVersion>.*</matlabVersion>', ...
            ['<matlabVersion>', Version, '</matlabVersion>']);
        FileID = fopen(fullfile(Files(j).folder, Files(j).name), 'w');
        fprintf(FileID, Contents);
        fclose(FileID);
    end
    
    % Zip updated files
    Zipfile = fullfile(TempDir, '..', Models(i).name);
    zip(Zipfile, '*.*', TempDir);
    
    % Rename to a original filename
    movefile([Zipfile, '.zip'], fullfile(Models(i).folder, Models(i).name))
    
    % Clean up temp location
    rmdir(TempDir, 's')
    
end

end