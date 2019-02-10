function SetBlockWidth(Block, Width)

if nargin < 1
    Width = 175;
    Block = gcb;
elseif nargin == 1
    if isnumeric(Block)
        Width = Block;
        Block = gcb;
    else
        Width = 175;
    end
end

% Position = [left top right bottom]
Position = get_param(Block, 'Position');
Position(3) = Position(1) + Width;
set_param(Block, 'Position', Position);

end