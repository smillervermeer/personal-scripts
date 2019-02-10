function FixHarness(Model)

if nargin < 1
    Model = bdroot;
end

% Apply config set
load('Tools\ConfigSets\MBSDHarnesses.mat', 'Configuration');
try
Vermeer_Tools.ApplyConfigSet(Model, Configuration, true);
catch ex
end

% Turn on information overlays
set_param(Model, 'ShowPortUnits', 'on')
set_param(Model, 'ShowLineDimensions', 'on')
set_param(Model, 'ShowPortDataTypes', 'on')
set_param(Model, 'LibraryLinkDisplay', 'all')
set_param(Model, 'PreSaveFcn', 'Vermeer_Base.ModelPreSave(bdroot);')

end