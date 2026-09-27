function peduks_coin_check_kernel_methods_placeholders( options, subjectData )
%Collects the numbers for
%the Methods "Integration kernels" subsection, for CP and RW:
%   (1) grand-average kernel shape (mean +/- SD across subjects, pooled
%       over instrCond, at each of the 5 lags)
%   (2) how many subject x condition cells are lost to the tau fit
%       (outside bounds, or within bounds but R^2 < 0)
%   OUT: printed to console only.

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
kernelData = peduks_coin_build_kernel_array(options, excludedBlocks, subjectData);

%grand-average kernel shape
printGrandAverageShape('CP', kernelData, options);
printGrandAverageShape('RW', kernelData, options);

%tau fit exclusions 
printTauExclusions('CP', options, excludedBlocks, subjectData);
printTauExclusions('RW', options, excludedBlocks, subjectData);

fprintf('\n(slopeLast3 has no equivalent exclusion - polyfit always returns a defined slope\n');
fprintf('given non-NaN kernel betas, so 0 subject x condition cells are lost to the fit itself.)\n');

end


function printGrandAverageShape(seqTypeLabel, kernelData, options)
seqIdx = find(strcmp(options.seqIDs, seqTypeLabel));
bySubj = squeeze(mean(kernelData(:, seqIdx, :, :), 3, 'omitnan'));  % nSubjects x 5
grandMean = mean(bySubj, 1, 'omitnan');
grandSD   = std(bySubj, 0, 1, 'omitnan');

fprintf('\n=== Grand-average %s kernel (all subjects, both instrCond pooled) ===\n', seqTypeLabel);
fprintf('lag:    %s\n', sprintf('%8d', -5:-1));
fprintf('mean:   %s\n', sprintf('%8.4f', grandMean));
fprintf('SD:     %s\n', sprintf('%8.4f', grandSD));
end


function printTauExclusions(seqTypeLabel, options, excludedBlocks, subjectData)
tauTable = peduks_coin_build_expdecay_pooled_table(options, table(), excludedBlocks, subjectData, seqTypeLabel);

nAttempted = height(tauTable);
nBoundary  = sum(isnan(tauTable.tauPooled));
nR2neg     = sum(~isnan(tauTable.tauPooled) & tauTable.R2pooled < 0);
nExcluded  = nBoundary + nR2neg;
nValid     = nAttempted - nExcluded;

fprintf('\n=== exponential-decay (tau) fit exclusions, %s ===\n', seqTypeLabel);
fprintf('subject x condition cells attempted: %d\n', nAttempted);
fprintf('excluded - fit outside bounds (tau/A, NaN):    %d\n', nBoundary);
fprintf('excluded - within bounds but R^2 < 0:          %d\n', nR2neg);
fprintf('total excluded:                                %d (%.1f%%)\n', nExcluded, 100*nExcluded/nAttempted);
fprintf('valid tau fits remaining:                       %d\n', nValid);
end
