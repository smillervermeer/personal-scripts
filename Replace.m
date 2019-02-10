function Replace(varargin)

Block = gcs;

% Find blocks
Blocks = find_system(Block,'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth','1','Selected','on');

% Filter out parent block
Blocks = Blocks(~strcmp(Blocks, Block));

for BlockIdx = 1:length(Blocks)
    try
        % If this is a bus element
        ObjectParameters = fieldnames( ...
            get_param(Blocks{BlockIdx}, 'ObjectParameters'));
        PropertyName = 'Name';
        if any(strcmp(ObjectParameters, 'Element'))
            if ~isempty(get_param(Blocks{BlockIdx}, 'Element'))
                PropertyName = 'Element';
            end
        elseif any(strcmp(ObjectParameters, 'VariableName'))
            if ~isempty(get_param(Blocks{BlockIdx}, 'VariableName'))
                PropertyName = 'VariableName';
            end
        end
        % Loop over all the search/replace pairs added
        Property = get_param(Blocks{BlockIdx}, PropertyName);
        for ArgIndex = 1:2:nargin
            Property = regexprep(Property, ...
                varargin(ArgIndex), varargin(ArgIndex + 1));
        end
        set_param(Blocks{BlockIdx}, PropertyName, Property);
        
        if isequal(get_param(Blocks{BlockIdx}, 'MaskType'), 'Bus Selector')
            OutputSignals = get_param(Blocks{BlockIdx}, 'OutputSignals');
            for ArgIndex = 1:2:nargin
                OutputSignals = regexprep(OutputSignals, ...
                    varargin(ArgIndex), varargin(ArgIndex + 1));
            end
            set_param(Blocks{BlockIdx}, 'OutputSignals', OutputSignals);
        end
    catch ex %#ok<NASGU>
    end
end

% Find lines
Lines = find_system(Block, 'findall','on','LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth','1','Selected','on','type','line');

for LineIdx = 1:length(Lines)
    try
        % If this is a bus element
        Name = get_param(Lines(LineIdx), 'Name');
        for ArgIndex = 1:2:nargin
            Name = regexprep(Name, ...
                varargin(ArgIndex), varargin(ArgIndex + 1));
        end
        set_param(Lines(LineIdx), 'Name', Name);
    catch ex %#ok<NASGU>
    end
end


end