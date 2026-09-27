function savedData = peduks_coin_load_savedData( fileNames )
% GEÄNDERT
%PEDUKS_COIN_LOAD_SAVEDDATA Loads in a series of csv spreadsheets, each
%containing the data for one session of the COIN task in the PEDUK study.
% IN:   fileNames       - cell array with strings containing the full path
%                       to the csv files to be loaded
% NOTE: the column numbers of variables to be selected will depend on
% study-specific format of the csv files

savedData = [];

for iFile = 1: numel(fileNames)
    if ~isempty(fileNames{iFile})
        opts = detectImportOptions(fileNames{iFile});
        if numel(opts.VariableNames) > 20
            opts.SelectedVariableNames = {
                'participant', 'order', ...     
                'blockID', 'currentFrame', ...
                'laserRotation', 'shieldRotation', 'shieldDegrees', ...
                'trueMean', 'trueVariance', ...
                'currentHit', 'totalReward', ...
                'seqType', 'instruction_framing', 'instr', ...
                'volatility', 'stochasticity', 'blockFileName'
            };
        else
            opts.SelectedVariableNames = opts.VariableNames;
        end

        fileData = readtable(fileNames{iFile}, opts);
        fileData(isnan(fileData.blockID), :) = [];
        fileData(fileData.blockID == 0, :) = []; %Without practice blocks
        fileData.blockID = fileData.blockID + 4*(iFile-1);
        fileData.sessID = iFile*ones(size(fileData,1),1);

        savedData = [savedData; fileData];
    end
end
