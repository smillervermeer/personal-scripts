function SetReq(varargin)

Block = gcs;

% Find blocks
Blocks = find_system(Block, ...
    'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', ...
    'SearchDepth', '1', ...
    'Selected', 'on');
% Filter out parent block
Blocks = Blocks(~strcmp(Blocks, Block));

% Set each block's annotation
for Index = 1:length(Blocks)
    Block = Blocks{Index};
    Reqs = [varargin{:}];
    if contains(get_param(Block, 'ReferenceBlock'), '<Library>_HDD_Library')
        Reqs = [Reqs, FindInternalReqs(Block)]; %#ok<AGROW> 
    end
    Reqs = unique(Reqs);
    ReqString = MakeReqString(Reqs);
    set_param(Block, 'AttributesFormatString', ReqString);
end

    function InternalReqs = FindInternalReqs(Block)
        InternalBlocks = find_system(Block, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on');
        InternalBlocks = InternalBlocks(~strcmp(InternalBlocks, Block));
        InternalReqs = [];
        for InternalIndex = 1:length(InternalBlocks)
            InternalBlock = InternalBlocks{InternalIndex};
            ObjectParams = get_param(InternalBlock, 'ObjectParameters');
            if any(strcmp(fieldnames(ObjectParams), 'AttributesFormatString'))
                Annotation = get_param(InternalBlock, 'AttributesFormatString');
                if ~isempty(Annotation)
                    ThisBlockReqs = regexp(Annotation, '(?<=HDD-)\d+', 'match');
                    ThisBlockReqs = cellfun(@str2double, ThisBlockReqs);
                    InternalReqs = [InternalReqs, ThisBlockReqs]; %#ok<AGROW> 
                end
            end
        end
        InternalReqs = unique(InternalReqs);
    end

    function String = MakeReqString(Numbers)
        String = '';
        Length = length(Numbers);
        if Length > 6
            Columns = 3;
        elseif Length > 2
            Columns = 2;
        else
            Columns = 1;
        end
        for ReqIndex = 1:Length
            if ReqIndex == Length
                Delimiter = '';
            else
                if mod(uint8(ReqIndex), Columns)
                    Delimiter = ' ';
                else
                    Delimiter = newline;
                end
            end
            String = [String, 'HDD-', num2str(Numbers(ReqIndex)), Delimiter]; %#ok<AGROW>
        end
    end

end