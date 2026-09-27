function dim = peduks_coin_figure_dimensions

dim.xPos = 100; 
dim.yPos = 700; 

dim.height = 250;

% Based on A4 width = 210mm, 10mm on each side -> 190mm full width
% With a 50mm height, we get a width of 190mm for a full-width figure,
% 2x90mm (+10mm in between) for 2 half-width figures and 3x60mm (+2x 5mm in
% between) for 3 third-width figures.

dim.wThird = dim.height*1.2; 
dim.wHalf = dim.height*1.8; 
dim.wFull = dim.height*3.8;