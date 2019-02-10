function get_params(Key)
Blocks = find_system(gcs, 'FollowLinks', 'on', ...
    'LookUnderMasks', 'all', 'selected', 'on');
for i=1:length(Blocks)
    try
        disp([Blocks{i}, ': ', get_param(Blocks{i}, Key)])
    catch
    end
end
end