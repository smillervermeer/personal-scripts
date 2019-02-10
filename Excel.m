function Excel(File)

if nargin < 1
    File = bdroot;
end

% Filter out some text just in case it was passed this way
File = strrep(File, 'Harness', '');
File = strrep(File, '.xlsx', '');
File = strrep(File, '.slx', '');


File = which([File, '.xlsx']);
if ~isfile(File)
    error('File %s does not exist', File)
end

% Open
winopen(File)

end