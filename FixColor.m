function FixColor()

% Find blocks
% Blocks = find_system(gcs, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
%     'SearchDepth', '1', 'selected', 'on');
Blocks = find_system(bdroot, 'LookUnderMasks', 'all');

% Set each block's color
for Index = 1:length(Blocks)
    Fieldnames = fieldnames(get_param(Blocks{Index}, 'ObjectParameters'));
    if any(strcmp(Fieldnames, 'IsBusElementPort'))
        IsBusElementPort = get_param(Blocks{Index}, 'IsBusElementPort');
        if strcmp(IsBusElementPort, 'on')
            % BusElement
            set_param(Blocks{Index}, ...
                'ForegroundColor', 'black', ...
                'BackgroundColor', 'black');
        else
            % Port
            set_param(Blocks{Index}, ...
                'ForegroundColor', 'black', ...
                'BackgroundColor', 'white');
        end
    else
        if any(strcmp(Fieldnames, 'MaskInitialization'))
            % Reapply library color
            InitScript = get_param(Blocks{Index}, 'MaskInitialization');
            % Get color, if any
            Color = regexp(InitScript, ...
                '(?<=(SetBackgroundColor\(\''))[a-zA-Z]+(?=(\''\)))', ...
                'match', 'once');
            if ~isempty(Color)
                % Colored library block
                set_param(Blocks{Index}, ...
                    'ForegroundColor', 'black', ...
                    'BackgroundColor', Color);
            else
                % Other block
                set_param(Blocks{Index}, ...
                    'ForegroundColor', 'black', ...
                    'BackgroundColor', 'white');
            end
        end
    end
    
end
