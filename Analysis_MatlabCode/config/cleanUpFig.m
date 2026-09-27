function fh = cleanUpFig( fh )

% consistent font across every figure that routes through here
set(findall(fh, '-property', 'FontName'), 'FontName', 'Times New Roman');

end