function [p1, p2] = peduks_coin_plot_kernelWeights_perSubject( conKernelData, ...
    col1, col2, col3, sampleOrder, offset )

    nSubjects = size(conKernelData,1);

    for iSub = 1:nSubjects
        for iSamp = 1:5
            plot([sampleOrder(iSamp)-offset sampleOrder(iSamp)+offset], ...
                squeeze(conKernelData(iSub,:,iSamp)), ...
                '-', 'color', col3);
            hold on;
        end
    end
    for iSub = 1:nSubjects
        p1 = plot(sampleOrder-offset, squeeze(conKernelData(iSub, 1, :)), 'o', ...
            'color', col1, 'MarkerFaceColor',col1, 'MarkerSize', 8);
        p2 = plot(sampleOrder+offset, squeeze(conKernelData(iSub, 2, :)), 'o', ...
            'color', col2, 'MarkerFaceColor',col2, 'MarkerSize', 8);
    end
    
    for iSamp = 1:5
        [h, p] = ttest(squeeze(conKernelData(:,1,iSamp)), squeeze(conKernelData(:,2,iSamp)));
        if p<0.1
            plot(sampleOrder(iSamp), max(max(conKernelData(:,:,iSamp)))+0.1, '*', ...
                'color', 'k', 'MarkerSize',10, 'linewidth', 1.5);
        end
    end
    xlim([-5.5 -0.5])
    
    yline(0);
    
    xlabel('Beam event preceding shield movement')
    ylabel('Average weight on decision')

end