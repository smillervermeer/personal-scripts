function SetMaskImage(Symbol, Block)

% Handle arguments
switch nargin
    case 0
        warning('Need at least one argument.')
        return;
    case 1
        Block = gcb;
end

DrawingCmds = [ ...
    'Block = gcb;', newline, ...
    'Position = get_param(Block, ''Position'');', newline, ...
    'Height = abs(Position(3) - Position(1));', newline, ...
    'Width = abs(Position(4) - Position(2));', newline, ...
    'ImageSize = min(min(Height, Width) / 2, 65);', newline, ...
    'UserData = get_param(Block, ''UserData'');', newline, ...
    'image(UserData.Image, ...', newline, ...
    '    [(Height - ImageSize) / 2, (Width - ImageSize) / 2, ...', newline, ...
    '    ImageSize, ImageSize])'];

% Read in image
[~, ~, Transparency] = imread(Symbol, 'png');
Transparency = 255 - Transparency;
Image(:,:,1) = Transparency;
Image(:,:,2) = Transparency;
Image(:,:,3) = Transparency;

% Set image
UserData = get_param(Block, 'UserData');
UserData.Image = Image;

% Assign to block
set_param(Block, 'UserDataPersistent', 'on', ...
    'UserData', UserData, ...
...%     'MaskDisplay', DrawingCmds, ...
    'MaskIconUnits', 'Pixels');

end