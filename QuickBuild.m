bdclose('all')
% Start = 1;
% [Models, ~] = Vermeer_Library_Tools.CollectSource(fullfile(pwd, 'Source'));
% for Index = Start:77%length(Models)
%     fprintf("%d/%d: %s...", Index, length(Models), ...
%         Models(Index).Name)
%     try
%     load_system(Models(Index).Harness)
%     String = get_param([Models(Index).Name, 'Harness'], 'PreLoadFcn');
%     String = [String, get_param([Models(Index).Name, 'Harness'], 'PostLoadFcn')];
%     load_system(Models(Index).Name)
%     String = [String, get_param(Models(Index).Name, 'PreLoadFcn')];
%     String = [String, get_param(Models(Index).Name, 'PostLoadFcn')];
%     if ~isempty(String)
%             fprintf("%d/%d: %s...", Index, length(Models), ...
%         Models(Index).Name)
%     end
%     Result = Vermeer_Test_Tools.TestModel(Models(Index));
%     catch
%     end
%     close_system(Models(Index).Harness, 0)
%     bdclose('all')
%     fprintf("... %s\n", Result.Status)
% end

Function = 'Vermeer_Device.Define_HAL_Enum(''HAL_OutputStatus'');';

Models = {'ControllersOnline', ...
    'DigitalPowerOutputCal', ...
    'FaultEquipped', ...
    'OutputEnable', ...
    'DrillTrackSelector', ...
    'ThrustEnable', ...
    'TrackingEnable', ...
    'SensorSupplyFault'};
for Index = 1:length(Models)
    Model = Models{Index};

    load_system([Model, 'Harness']);
    set_param([Model, 'Harness'], ...
        'PreLoadFcn', Function, 'PostLoadFcn', '');
    save_system([Model, 'Harness']);

    load_system(Model);
    set_param(Model, 'Lock', 'off')
    set_param(Model, ...
        'PreLoadFcn', Function, 'PostLoadFcn', '');
    save_system(Model);

    TestSingleModel([Model, 'Harness']);
end