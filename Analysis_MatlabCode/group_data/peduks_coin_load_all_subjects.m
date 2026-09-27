function subjectData = peduks_coin_load_all_subjects( options )
%Loads subData and perform for every
%subject once, so the group-level table builders can share one copy
%instead of each reloading the same files from disk 
%   OUT: subjectData - containers.Map, keyed by subID (double), each
%       value a struct with fields subData and perform

subIDs = options.subjectIDs;
subjectData = containers.Map('KeyType', 'double', 'ValueType', 'any');

for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    try
        details = peduks_coin_subjects(subID, options);
        S = load(details.analysis.onlineTrain.behav{1}.responseData, 'subData');
        P = load(details.analysis.onlineTrain.behav{1}.performance, 'perform');

       
        entry.subData = S.subData;
        entry.perform = P.perform;
        subjectData(subID) = entry;
    catch ME
        warning('Subject %d: could not load subData/perform (%s) - skipping', subID, ME.message);
    end
end

end
