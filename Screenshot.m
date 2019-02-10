function Screenshot(Filename)

if nargin < 1
    Filename = 'screenshot';
end
if ~contains(Filename, '.png')
    Filename = [Filename, '.png'];
end

% Establish connection to display
Conn = ssh2.ssh2_config('192.168.5.2', 'root', '', 22);

% Testing out poking some data into the frame buffer to force refresh it
% first
[~, ~] = ssh2.ssh2_command(Conn, ...
    'dd if=/dev/urandom of=/dev/fb1 bs=12 count=1');

% Capture frame buffer
[~, ~] = ssh2.ssh2_command(Conn, 'mount -o remount, rw /');
[~, ~] = ssh2.ssh2_command(Conn, 'cat /dev/fb1 > framebuffer.raw');

% Get screen size
[~, Return] = ssh2.ssh2_command(Conn, 'fbset -fb /dev/fb1 -s');
Return = strjoin(Return, newline);
[Start, End] = regexp(Return, '(?<=geometry )((\w+ ){2})');
Return = Return(Start:End);
Dimensions = str2num(Return); %#ok<ST2NM>

% Download file
TempDir = tempname;
mkdir(TempDir);
RemoteFileName = 'framebuffer.raw';
%     sftp_get(Conn, RemoteFileName, TempDir);
Framebuffer = fullfile(TempDir, RemoteFileName);
% ssh2's sftp_get() is crazy slow, so we're going to issue a system
% call to WinSCP instead
[~, ~] = system(['"C:\Program Files (x86)\WinSCP\winscp.com" '...
    'root@192.168.5.2 /command '...
    '"get /home/framebuffer.raw "', Framebuffer, '"" '...
    'exit']);

% Read in data
File = fopen(Framebuffer);
Data = fread(File, [Dimensions(1), Dimensions(2)], 'uint16=>uint16');
fclose(File);

% Remove temp files
[~, ~] = ssh2.ssh2_command(Conn, 'rm framebuffer.raw');
ssh2.ssh2_close(Conn);
delete(Framebuffer);

% Interpret RGB data
Red = zeros(Dimensions);
Green = zeros(Dimensions);
Blue = zeros(Dimensions);
for Y=1:Dimensions(2)
    for X=1:Dimensions(1)
        Pixel = uint16(Data(X, Y));
        Red(X, Y) = single(bitshift(bitand(Pixel, uint16(63488)), -11)) / 32;
        Green(X, Y) = single(bitshift(bitand(Pixel, uint16(2016)), -5)) / 64;
        Blue(X, Y) = single(bitand(Pixel, uint16(31))) / 32;
    end
end
RGB = cat(3, Red, Green, Blue);
RGB = rot90(flip(RGB), -1);

% Save image file
imwrite(RGB, Filename)

% Show image
%     close all
%     imshow(RGB)

end