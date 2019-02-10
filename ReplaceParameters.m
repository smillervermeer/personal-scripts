function ReplaceParameters(Model, Find, Replace, varargin)
%% Function name: ReplaceParameters
%
% Description: Reads the specified spreadsheet for the DTC data
%   information.
%
% Inputs:
%   Model - char: Optional first parameter, name of controller model
%     to diff against a previous version of itself. Assumes the current 
%     open model if not passed
%   Find - char: If true, outputs progress to console.
%   Replace - char: If true, looks for changes, but doesn't apply them.
%   varargin - variable key value pairs: Optional parameters which may be:
%     Silent - char: If true, outputs progress to console.
%     DryRun - char: If true, looks for changes, but doesn't apply them.
%
% Outputs:
%   N/A
%
%--------------------------------------------------------------------------
% This data and code is protected by United States and international
% laws and shall not be reproduced, copied, or utilized without the
% express written consent of Vermeer Corporation.  This data and code
% should not be accessed or altered by unauthorized personnel.
% Unauthorized access to or alteration of this data and code may alter
% the performance of products and void applicable warranties.
% (c) 2021 - 2021 Vermeer Corporation.  All Rights Reserved.
%--------------------------------------------------------------------------

%% Parse input arguments
Parser = inputParser;
addParameter(Parser, 'Silent', false, @islogical);
addParameter(Parser, 'DryRun', false, @islogical);
parse(Parser, varargin{:})
Silent = Parser.Results.Silent;
DryRun = Parser.Results.DryRun;

%% Unlock model
% Lock = get_param(Model, 'Lock');
% if isequal(Lock, 'on')
%     set_param(Model, 'Lock', 'off')
% end

%% Get all blocks
if ~Silent
    fprintf('# Finding all blocks in model\n')
    fprintf('#   Patience, this may take a while...\n')
end
Blocks = Simulink.findBlocks(Model);
if ~Silent
    fprintf('# Found %d blocks\n', length(Blocks))
end

%% Update parameters
% Loop over blocks
for BlockIndex = 1:length(Blocks)
    Block = Blocks(BlockIndex);
    Mask = Simulink.Mask.get(Block);
    ParametersToWrite = {};
    NewParameters = {};
    OldParameters = {};
    if isempty(Mask)
        %% Blocks without masks
        % Most of this is directly copy/pasted from 
        % Vermeer_Tools.UpdateModelScriptDependencies
        % For blocks that don't have masks, ie ports, tags;
        % get the dialog parameters and parse those
        Parameters = get_param(Block, 'DialogParameters');
        if ~isempty(Parameters)
            % Filter out any parameters that cannot be edited
            if any(strcmp(get_param(Block, 'LinkStatus'), ...
                    {'resolved'}))
                Indexes = structfun(@(c) ...
                    any(strcmp(c.Attributes, 'read-write')) & ...
                    ~any(strcmp(c.Attributes, 'not-link-instance')), Parameters);
            else
                Indexes = structfun(@(c) ...
                    any(strcmp(c.Attributes, 'read-write')), Parameters);
            end
            Parameters = fieldnames(Parameters);
            Parameters = Parameters(Indexes);
        end
        % Look at the remaining parameters
        ParametersToWrite = {};
        for ParameterIndex = 1:length(Parameters)
            Parameter = Parameters{ParameterIndex};
            if any(strcmp(Parameter, {'Element', 'Name'}))
                continue;
            end
            CurrentValue = get_param(Block, Parameter);
            % Only process a character string of some sort
            if ~isempty(CurrentValue) &&...
                    (ischar(CurrentValue) || iscellstr(CurrentValue) ||...
                    isstring(CurrentValue))
                if ~isempty(regexp(CurrentValue, Find, 'once'))
                    NewValue = regexprep(CurrentValue, ...
                        Find, Replace);
                    ParametersToWrite = [ParametersToWrite, Parameter, NewValue]; %#ok<AGROW>
                    NewParameters = [NewParameters, Parameter, NewValue]; %#ok<AGROW>
                    OldParameters = [OldParameters, CurrentValue]; %#ok<AGROW>
                end
            end
        end
    else
        %% Blocks with masks
        Parameters = Mask.Parameters;
        % Loop over mask parameters in this block
        for ParameterIndex = 1:length(Parameters)
            Parameter = Parameters(ParameterIndex);
            if ~isempty(regexp(Parameter.Value, Find, 'once'))
                NewValue = regexprep(Parameter.Value, ...
                    Find, Replace);
                ParametersToWrite = [ParametersToWrite, Parameter.Name, NewValue]; %#ok<AGROW>
                NewParameters = [NewParameters, Parameter.Name, NewValue]; %#ok<AGROW>
                OldParameters = [OldParameters, Parameter.Name]; %#ok<AGROW>
            end
            if ~isempty(regexp(Parameter.Callback, Find, 'once'))
                NewValue = regexprep(Parameter.Callback, ...
                    Find, Replace);
                ParametersToWrite = [ParametersToWrite, Parameter.Name, NewValue]; %#ok<AGROW>
                NewParameters = [NewParameters, '', '']; %#ok<AGROW>
                OldParameters = [OldParameters, Parameter.Name]; %#ok<AGROW>
            end
        end
        % Also look at the init & display scripts
        AdditionalParameters = {'MaskInitialization', 'MaskDisplay'};
        for ParameterIndex = 1:length(AdditionalParameters)
            Parameter = AdditionalParameters{ParameterIndex};
            CurrentValue = get_param(Block, Parameter);
            if ~isempty(regexp(CurrentValue, Find, 'once'))
                NewValue = regexprep(CurrentValue, ...
                    Find, Replace);
                ParametersToWrite = [ParametersToWrite, Parameter, NewValue]; %#ok<AGROW>
                NewParameters = [NewParameters, '', '']; %#ok<AGROW>
                OldParameters = [OldParameters, Parameter]; %#ok<AGROW>
            end
        end
    end
    %% Print & write to block
    if ~isempty(ParametersToWrite)
        % Print output
        if ~Silent
            BlockName = getfullname(Block);
            fprintf('# %d/%d <a href="matlab:hilite_system(''%s'')">%s</a>\n', ...
                BlockIndex, length(Blocks), BlockName, BlockName)
            for ParameterIndex = 1:2:length(ParametersToWrite)
                fprintf('#    %s: %s -> %s\n', ...
                    NewParameters{ParameterIndex}, ...
                    OldParameters{ceil(ParameterIndex/2)}, ...
                    NewParameters{ParameterIndex + 1})
            end
        end
        % Write new parameters
        if ~DryRun
            set_param(Block, ParametersToWrite{:});
        end
    end
end
%% Done
if ~Silent && DryRun
    fprintf('# Dry run -- No changes made\n')
end
end