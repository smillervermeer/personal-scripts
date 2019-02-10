function GetExpected(Results)

for Index = 1:length(Results.Tests)
    for Output = 1:2:width(Results.Tests(Index).Expected)
        Values = Results.Tests(Index).Expected(Output)
    end

end



end