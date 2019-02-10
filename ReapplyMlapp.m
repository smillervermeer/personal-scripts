function Error = ReapplyMlapp(Block)

if nargin < 1

% Find selected blocks
System = gcs;
Blocks = find_system(System,'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth','1','Selected','on');

% Filter out parent block
Blocks = Blocks(~strcmp(Blocks, System));

else
   Blocks = {Block}; 
end

% Loop over blocks
for Index = 1:length(Blocks)
    
    try
        % Get current block handle & related properties
        Block = getSimulinkBlockHandle(Blocks{Index});
        ReferenceBlock = get_param(Block, 'ReferenceBlock');
        ParsedName = split(ReferenceBlock, '/');
        LibraryName = strrep(ParsedName{1}, '_Library', '');
        
        % Skip this block if not linked to a library
        if isempty(ReferenceBlock)
            continue
        end
        
        % Search the library's package folder for a corresponding mlapp
        % and skip this block if none found
        Files = what(LibraryName);
        for File = 1:length(Files)
            MlappFiles = Files(File).mlapp;
        end
        if ~any(strcmp(MlappFiles, [ParsedName{2}, '_Mask.mlapp']))
            continue
        end
        
        % Print status
        fprintf('# <a href="matlab: hilite_system(''%s'',''find'')">%s</a>...', ...
            getfullname(Blocks{Index}), getfullname(Blocks{Index}))
        
        % Open mask
        Mask = eval([LibraryName, '.', ParsedName{2}, '_Mask(Block)']);
        
        % Call the mask's SetBlockParams() function
        Mask.SetBlockParams(matlab.ui.eventdata.ButtonPushedData)
        
        % Close mask
        eval(['close(Mask.', ParsedName{2}, 'UIFigure)'])
        
        % Done
        fprintf('applied!\n')
        
    catch Ex
        
        % Catch any exceptions
        fprintf('error!\n')
        Vermeer_Basic.PrintError(Ex)
        Error = true;
    end
    
    Error = false;
end