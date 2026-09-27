function kernelData = peduks_coin_build_kernel_array( options, excludedBlocks, subjectData )
%Builds an array of betas, one cell per subject x seqType x instrCond 

if nargin < 3
    subjectData = [];
end

subIDs = options.subjectIDs;
nSub = numel(subIDs);
% subjects x sequence type x instruction x 5 lags
kernelData = nan(nSub, 2, 2, 5);
if nargin < 2 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

% go through every subject, then every block of that subject
for iSub = 1:nSub
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    cellBetas = cell(2,2);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        % skip excluded blocks and blocks of the other sequence type
        if ismember(iB, subExcluded)
            continue
        end
        blockData = subData(subData.blockID == iB, :);
        seqIdx = find(strcmp(options.seqIDs, charify(blockData.seqType(1))));
        instrIdx = find(strcmp(options.instrIDs, charify(blockData.instrCond(1))));

        blockMove = peduks_coin_blockMovements(blockData, options);
        betas = peduks_coin_blockKernels(blockData, blockMove, options);
        % put this block's kernel weights into its condition cell
        cellBetas{seqIdx, instrIdx} = [cellBetas{seqIdx, instrIdx}; betas(:)'];
    end

    % one average kernel per subject and condition
    for iS = 1:2
        for iI = 1:2
            if ~isempty(cellBetas{iS,iI})
                kernelData(iSub, iS, iI, :) = mean(cellBetas{iS,iI}, 1, 'omitnan');
            end
        end
    end
end

end

function s = charify(x)
if iscell(x), s = char(x{1}); else, s = char(x); end
end
