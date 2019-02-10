function TestAllModels

Files = dir(fullfile('Source', '**', '*.slx'));
Files = Files(~cellfun(@(x) contains(x, 'Harness'), {Files.name}));

Start = 152;

for Index = Start:length(Files)
    try
        fprintf('# % 3u. %s\n', Index, Files(Index).name)
        HarnessName = [strrep(Files(Index).name, '.slx', ''), 'Harness'];
        Results = TestSingleModel(HarnessName);
        if ~Results.Passed
            warning('# Failed!');
        end
    catch Ex
        warning('# Error!');
    end
    
end

end

git reba