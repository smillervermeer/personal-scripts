function FixTags(Model)

if nargin < 1
    Model = gcs;
end

Height = 16;
PerLetter = 6;
LetterPadding = 3;

% Find blocks
Options = Simulink.FindOptions('Variants', 'ActivePlusCodeVariants');
Blocks = Simulink.findBlocksOfType(Model, 'Goto', Options);
Blocks = [Blocks; Simulink.findBlocksOfType(Model, 'From', Options)];


for Index = 1:length(Blocks)
    Block = Blocks(Index);
    Tag = get_param(Block, 'GotoTag');
    Position = get_param(Block, 'Position');
    Width = (length(Tag) + LetterPadding) * PerLetter;
    Type = get_param(gcb,'BlockType');
    if isequal(Type, 'Goto')
        Position(3) = Position(1) + Width;
    else
        Position(1) = Position(3) - Width;
    end
    Midpoint = Position(2) + (Position(4) - Position(2)) / 2;
    Position(2) = Midpoint - Height / 2;
    Position(4) = Midpoint + Height / 2;
    set_param(Block, 'Position', Position);
end


end