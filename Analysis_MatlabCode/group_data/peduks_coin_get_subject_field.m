function data = peduks_coin_get_subject_field( subID, options, subjectData, fieldName )
%PEDUKS_COIN_GET_SUBJECT_FIELD Returns subData or perform for one subject.
%   IN: subID, options, subjectData,
%       fieldName - 'subData' or 'perform'

% use the preloaded cache when the caller passed one
if ~isempty(subjectData) && isKey(subjectData, subID)
    entry = subjectData(subID);
    data = entry.(fieldName);
    return
end

% otherwise read subject's files from disk
try
    details = peduks_coin_subjects(subID, options);
    if strcmp(fieldName, 'subData')
        S = load(details.analysis.onlineTrain.behav{1}.responseData, 'subData');
        data = S.subData;
    else
        P = load(details.analysis.onlineTrain.behav{1}.performance, 'perform');
        data = P.perform;
    end
% a missing file should not stop the whole analysis
catch ME
    warning('Subject %d: could not load %s (%s) - skipping', subID, fieldName, ME.message);
    data = [];
end

end
