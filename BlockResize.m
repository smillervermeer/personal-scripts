function BlockResize(varargin)
System = gcs;
Blocks = find_system(System, 'FollowLinks', 'on', ...
    'LookUnderMasks', 'all', 'selected', 'on');
for Index = 1:length(Blocks)
    <Library>_Base.BlockResize(Blocks{Index}, varargin{:});
end
end