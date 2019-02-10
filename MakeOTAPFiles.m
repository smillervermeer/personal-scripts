function MakeOTAPFiles()
Files = [dir(fullfile('Applications', '**', '*U.slx')); ...
    dir(fullfile('Applications', '**', '*U2.slx'))];
for Index = 1:length(Files)
    [~, Model] = fileparts(Files(Index).name);
    if ~isfile(fullfile(Files(Index).folder, [Model, '.sldd']))
        continue;
    end
    Dictionary = Simulink.data.dictionary.open([Model, '.sldd']);
    DesignData = getSection(Dictionary, 'Design Data');
    try
        SoftwareProperties = evalin(DesignData, 'SoftwareProperties');
    catch Ex
        if isequal(Ex.identifier, 'SLDD:sldd:InvalidEvalinCommand')
            continue
        end
    end
    % See Vermeer_HAL.ProcessBinaries()
    switch SoftwareProperties.VersionPostfix
        case 'Alpha (A)'
            Postfix = '-A';
        case 'Beta (B)'
            Postfix = '-B';
        case 'Release Candidate (RC)'
            Postfix = '-RC';
        otherwise
            Postfix = '';
    end
    OTAPName = sprintf('%s_%d_v%d.%d.%d%s+%d%s', ...
        Model, ...
        SoftwareProperties.PartNumber, ...
        SoftwareProperties.VersionMajor, ...
        SoftwareProperties.VersionMinor, ...
        SoftwareProperties.VersionPatch, ...
        Postfix, ...
        SoftwareProperties.BuildNumber);
    Binary = fullfile(Files(Index).folder, [Model, '.mcx']);
    DisplayBinary = fullfile(Files(Index).folder, 'update.tar.gz');
    if isfile(Binary)
        copyfile(Binary, fullfile(pwd, [OTAPName, '.mcx']))
    elseif isfile(DisplayBinary)
        copyfile(DisplayBinary, fullfile(pwd, [OTAPName, '.tar.gz']))
    end
end
fclose(fopen('Readme.EN.txt', 'w'));
fclose(fopen('DealerCenter.pdf', 'w'));
end