function InjectATSData()
%% Function name: InjectATSData
%
% Description: Injects ATS data immediately after the file prefix or "magic
%   number" of a .mcx file.
%
% Inputs:
%   varargin - variable key value pairs: See BuildModels()
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
% (c) 2022 - 2022 Vermeer Corporation.  All Rights Reserved.
%--------------------------------------------------------------------------

%% Data
% Define some common variables for layout
FieldHeight = 22;
ButtonWidth = 100;
DateFormat = 'MM-dd-yyyy';
OnlyShowRequired = true;
% Define fields
Today = datetime('today', 'InputFormat', DateFormat);
Data = [
    struct('Field', 'Base Part Number',         'Type', 'string', 'Length', 10, 'Default', '999999999',     'Required', false, 'Handle', []); ...
    struct('Field', 'Base Revision',            'Type', 'string', 'Length', 2,  'Default', 'A',             'Required', false, 'Handle', []); ...
    struct('Field', 'Application Part Number',  'Type', 'string', 'Length', 10, 'Default', '999999999',     'Required', true,  'Handle', []); ...
    struct('Field', 'Application Revision',     'Type', 'string', 'Length', 2,  'Default', 'A',             'Required', true,  'Handle', []); ...
    struct('Field', 'Application Name',         'Type', 'string', 'Length', 32, 'Default', 'V123',          'Required', true,  'Handle', []); ...
    struct('Field', 'Application Version',      'Type', 'string', 'Length', 5,  'Default', 'A',             'Required', true,  'Handle', []); ...
    struct('Field', 'Application Date',         'Type', 'date',   'Length', 6,  'Default', Today,           'Required', true, 'Handle', []); ...
    struct('Field', 'Device CAN Id',            'Type', 'number', 'Length', 1,  'Default', '254',           'Required', true,  'Handle', []); ...
    struct('Field', 'Hardware Serial Number',   'Type', 'string', 'Length', 10, 'Default', '0',             'Required', false, 'Handle', []); ...
    struct('Field', 'Hardware Part Number',     'Type', 'string', 'Length', 10, 'Default', '999999999',     'Required', true,  'Handle', []); ...
    struct('Field', 'Hardware Revision',        'Type', 'string', 'Length', 2,  'Default', 'A',             'Required', true,  'Handle', []); ...
    struct('Field', 'Hardware Name',            'Type', 'string', 'Length', 32, 'Default', 'Enovation MCx', 'Required', true,  'Handle', []) ...
    ];

%% Check for saved data
DefaultMcxFile = '';
SavedDataFile = fullfile(pwd, 'Cache', 'ATSData.mat');
if isfile(SavedDataFile)
    load(SavedDataFile, 'McxFile', 'SavedData');
    for Index = 1:length(SavedData) %#ok<FXUP>
        Data(Index).Default = SavedData(Index).Default;
    end
    DefaultMcxFile = McxFile;
end

%% Draw UI
% Check for existing figures
Figure = findall(0, 'Type', 'figure', 'tag', 'ATS Data');
if ~isempty(Figure)
    % Focus on existing figure
    figure(Figure)
else
    % Make a new figure
    Figure = uifigure('Name', 'ATS Data', 'Tag', 'ATS Data');
    % Let Figure assume the default position, then adjust the width/height from
    % there
    Figure.Position(3) = 500;
    Figure.Position(4) = ...
        FieldHeight * 1.5 * (length(Data([Data.Required])) + 1) + ...
        (FieldHeight * 5);
    Figure.Position(2) = Figure.Position(2) - Figure.Position(4) / 2;
    % Fields
    PromptPosition = [Figure.Position(3) * 0.10, ...
        Figure.Position(4) - FieldHeight * 4, Figure.Position(3) * 0.40, 22];
    InputPosition = [Figure.Position(3) * 0.50, ...
        Figure.Position(4) - FieldHeight * 4, Figure.Position(3) * 0.40, 22];
    for Index = 1:length(Data) %#ok<FXUP>
        if OnlyShowRequired && Data(Index).Required
            uilabel(Figure, 'Text', Data(Index).Field, 'Position', PromptPosition);
            if isequal(Data(Index).Type, 'date')
                Data(Index).Handle = uidatepicker(Figure, ...
                    'Position', InputPosition, ...
                    'DisplayFormat', DateFormat, ...
                    'Value', Data(Index).Default);
            else
                Data(Index).Handle = uitextarea(Figure, ...
                    'Position', InputPosition, ...
                    'Value', Data(Index).Default, ...
                    'HorizontalAlignment', 'right');
            end
            PromptPosition(2) = PromptPosition(2) - 33;
            InputPosition(2) = InputPosition(2) - 33;
        end
    end
    % File prompt
    FilePosition = [Figure.Position(3) * 0.10, ...
        Figure.Position(4) - FieldHeight * 2, ...
        Figure.Position(3) * 0.80 - ButtonWidth - FieldHeight, FieldHeight];
    FileEditField = uieditfield(Figure, ...
        'Position', FilePosition, ...
        'Value', DefaultMcxFile);
    FileButton = [Figure.Position(3) * 0.90 - ButtonWidth, ...
        Figure.Position(4) - FieldHeight * 2, ButtonWidth, FieldHeight];
    uibutton(Figure, 'Push', ...
        'Text', 'Browse', ...
        'Position', FileButton, ...
        'ButtonPushedFcn', {@PickFile, FileEditField});
    % Okay button
    OkayButtonPosition = [Figure.Position(3) * 0.75, FieldHeight, ...
        ButtonWidth, FieldHeight];
    uibutton(Figure, 'Push', ...
        'Text', 'Okay', ...
        'Position', OkayButtonPosition, ...
        'ButtonPushedFcn', {@WriteMcxFile, FileEditField, Data});
    % Cancel button
    CancelButtonPosition = [ ...
        Figure.Position(3) * 0.75 - ButtonWidth - FieldHeight, ...
        FieldHeight, ButtonWidth, FieldHeight];
    uibutton(Figure, 'Push', ...
        'Text', 'Cancel', ...
        'Position', CancelButtonPosition, ...
        'ButtonPushedFcn', {@CloseFigure, Figure, Data, FileEditField});
    Figure.set('DeleteFcn', {@CloseFigure, [], Data, FileEditField})
end

%% Internal functions

    function CloseFigure(Button, Event, Handle, Data, EditField) %#ok<INUSL>
        %% Function name: CloseFigure
        %
        % Description: Close the passed figure.
        %
        % Inputs:
        %   Button - matlab.ui.control.button(1): The button object that
        %     was pushed to call this function.
        %   Event - matlab.ui.eventdata.ButtonPushedData(1): Event data
        %     passed to this function when pushed.
        %   Handle - matlab.ui.Figure(1): Handle to a figure to be closed.
        %
        % Outputs:
        %   N/A
        %
        
        % Save off data
        SavedData = [];
        for Index = 1:length(Data) %#ok<FXUP>
            SavedData(Index).Field = Data(Index).Field;
            if isempty(Data(Index).Handle)
                SavedData(Index).Default = ...
                    Data(Index).Default;
            else
                SavedData(Index).Default = ...
                    Data(Index).Handle.Value;
            end
        end
        if isfolder(fullfile(pwd, 'Cache'))
            SaveFilePath = fullfile(pwd, 'Cache');
        else
            SaveFilePath = pwd;
        end
        McxFile = EditField.Value;
        save(fullfile(SaveFilePath, 'ATSData.mat'), ...
            'SavedData', 'McxFile');
        % Close figure
        if ~isempty(Handle)
            close(Handle)
        end
    end

    function PickFile(Button, Event, EditField) %#ok<INUSL>
        %% Function name: PickFile
        %
        % Description: Close the passed figure.
        %
        % Inputs:
        %   Button - matlab.ui.control.button(1): The button object that
        %     was pushed to call this function.
        %   Event - matlab.ui.eventdata.ButtonPushedData(1): Event data
        %     passed to this function when pushed.
        %   EditField - matlab.ui.control.editField(1): Edit field
        %     containing the path/name of the MCx file currently selected.
        %
        % Outputs:
        %   N/A
        %
        
        % Default to the already selected file's directory, if it is valid
        if isfile(EditField.Value)
            Default = EditField.Value;
        else
            Default = pwd;
        end
        % Prompt for selecting a new .mcx file
        [File, Path] = uigetfile('*.mcx', 'Select MCx file', Default);
        % If file is valid, update user interface
        NewFile = fullfile(Path, File);
        if isfile(NewFile)
            EditField.Value = NewFile;
        end
    end

    function WriteMcxFile(Button, Event, EditField, Data)
        %% Function name: WriteMcxFile
        %
        % Description: Write the entered data to the MCx file.
        %
        % Inputs:
        %   Button - matlab.ui.control.button(1): The button object that
        %     was pushed to call this function.
        %   Event - matlab.ui.eventdata.ButtonPushedData(1): Event data
        %     passed to this function when pushed.
        %   EditField - matlab.ui.control.editField(1): Edit field
        %     containing the path/name of the MCx file currently selected.
        %   Data - struct: Contains all necessary data to be written to MCx
        %     Type - char: Either 'string', 'date', or 'number', to
        %       determine how the data should be represented. (Many numbers
        %       are represented as strings since that is how the original
        %       ATS C code stores them.)
        %     Length - double(1): Number of characters allocated for this
        %       field.
        %     Handle - matlab.ui.control(1): A subclass of
        %       matlab.ui.control representing an edit field, date picker,
        %       etc containing entered data.
        %
        % Outputs:
        %   N/A
        %
        
        % Check that .mcx file exists
        McxFile = EditField.Value;
        if ~isfile(McxFile)
            return;
        end
        % Read in entire .mcx file
        McxFileHandle = fopen(McxFile, 'r');
        McxData = fread(McxFileHandle, 'uint8=>char')';
        fclose(McxFileHandle);
        % Trim off the existing "magic number" header and any pre-existing
        % ATS data; exit if none found
        if strncmp(McxData, 'MCx app', 7)
            McxData = [zeros(1, sum([Data.Length])), McxData(7:end)];
        elseif strncmp(McxData, 'ext MCx app', 11)
            McxData = [zeros(1, sum([Data.Length])), McxData(11 + sum([Data.Length]):end)];
        else
            fclose(McxFile);
            return;
        end
        % Pack entered data in the .mcx file array
        for Index = 1:length(Data) %#ok<FXUP>
            Value = char(Data(Index).Handle.Value);
            switch Data(Index).Type
                case 'date'
                    Value = regexprep(Value, '\d{2}(?=\d{2})', '');
                    Value = strrep(Value, '-', '');
                case 'number'
                    Value = str2double(Value);
            end
            Start = max(1, sum([Data(1:Index-1).Length]));
            End = Start + min(length(Value), Data(Index).Length) - 1;
            McxData(Start:End) = Value;
        end
        % Prepend new "magic number" header
        McxData = ['ext MCx app', McxData];
        % Write new .mcx file on top of old one
        McxFileHandle = fopen(McxFile, 'w');
        fwrite(McxFileHandle, McxData);
        fclose(McxFileHandle);
        % Close
        CloseFigure(Button, Event, EditField.Parent, Data, EditField);
    end

end