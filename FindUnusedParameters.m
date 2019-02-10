function FindUnusedParameters()

Model = bdroot(gcb);

% Find blocks
Blocks = getfullname(Simulink.findBlocksOfType( ...
    Model, 'SubSystem', 'MaskType', 'MachineSpecificParameter'));
UsedParams = get_param(Blocks, 'Parameter');

AvailableParams = Simulink.data.evalinGlobal(Model, ...
    'MachineSpecificParameters');

UnusedParams = setdiff({AvailableParams.Name}, UsedParams);

disp(UnusedParams');

end