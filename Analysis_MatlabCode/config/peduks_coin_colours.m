function col = peduks_coin_colours

% main effects
col.stable = [41 103 165]/255; %[0 0 0.8];
col.volatile = [165 41 103]/255;%[0.8 0 0];
col.precise = [70 70 70]/255;
col.noisy = [160 160 160]/255;

% interaction
col.stabNoisy = col.stable/2;
col.volaNoisy = col.volatile/2;

% gray levels
col.lowNoise = [0.1 0.1 0.1];
col.medNoise = [0.3 0.3 0.3];
col.highNoise = [0.5 0.5 0.5];
col.vHighNoise = [0.7 0.7 0.7];

% blue levels
col.sessions = [ 176 176 255;...
    128 129 255; ...
    96 97 191; ...
    64 65 128]./255;

% subject lines/dots
col.individ = col.sessions(1,:); %col.vHighNoise

% line styles (jump sizes)
col.lineStyles = {'-', '--', ':'};

% unused
col.preciseOld = [84 82 175]/255;%[0 0.6 0.8];
col.noisyOld = [173 175 82]/255;%[0.8 0.6 0];

%col.sessions = [ 0.5 0.5 1;...
%    0.25 0.25 0.75; ...
%    0 0 0.5; ...
%    0 0 0.25];

