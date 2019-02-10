function Connect()


[Block1, Port1] = GetBlock('Outport');
[Block2, Port2] = GetBlock('Inport');
% if Block1 == Block2
%     error('Same block')
% else
    BlockName1 = get_param(Block1, 'Name');
    BlockName2 = get_param(Block2, 'Name');
    add_line(gcs, sprintf('%s/%s', BlockName1, Port1), ...
        sprintf('%s/%s', BlockName2, Port2), 'autorouting', 'smart');
    fprintf('# %s/%s to %s/%s\n', BlockName1, Port1, BlockName2, Port2)
% end

    function [Block, Port] = GetBlock(Type)

        if isequal(Type, 'Inport')
            Label = 'to';
        else
            Label = 'from';
        end

        input(sprintf('# Select block %s:', Label))
        Block = gcbh;
        fprintf('#  %s\n', getfullname(Block));

        Ports = get_param(Block, 'PortHandles');
        Ports = Ports.(Type);

        if isempty(Ports)
            error('No ports');
        elseif length(Ports) > 1
            Port = [];
            while isempty(Port)
                Port = num2str(input('# Select port: '));
            end
        else
            Port = '1';
        end
    end

end
