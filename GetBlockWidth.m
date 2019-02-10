function Width = GetBlockWidth(Block)

if nargin < 1
    Block = gcb;
end

% Position = [left top right bottom]
Position = get_param(Block, 'Position');
Width = Position(3) - Position(1);

end