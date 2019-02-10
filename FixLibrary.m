function FixLibrary(Model)

if nargin < 1
    Model = bdroot;
end

% Turn on information overlays
set_param(Model, 'ShowPortUnits', 'on')
set_param(Model, 'ShowLineDimensions', 'on')
set_param(Model, 'ShowPortDataTypes', 'on')
set_param(Model, 'LibraryLinkDisplay', 'all')
set_param(Model, 'PreSaveFcn', 'Vermeer_Base.ModelPreSave(bdroot);')

end