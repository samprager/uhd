function str = extract_identifier(trialnames)
%extract_identifier - try to figure out a good id name from a cell array of
% trial names

% Inputs:
%    trialnames - cell array of strings. ie {'trial1','trial2',...}
%
% Outputs:
%    str - identifier. ie 'trial' for example input

% Author: Samuel Prager
% Microwave Systems, Sensors and Imaging Lab (MiXiL) 
% University of Southern California
% Email: sprager@usc.edu
% Created: 2018/06/07 10:45:47; Last Revised: 2018/06/07 10:45:47
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------

if (numel(trialnames)<2)
    error('input cell array must have at least two elements');
end
if (~iscell(trialnames))
    error('input must be cell array');
end
%%
% parse common delimiters
delims = {'_','-','/','.'};
trialcell1 = textscan(trialnames{1},'%s','Delimiter',delims{1});
trialcell2 = textscan(trialnames{1},'%s','Delimiter',delims{2});
trialcell3 = textscan(trialnames{1},'%s','Delimiter',delims{3});
trialcell4 = textscan(trialnames{1},'%s','Delimiter',delims{4});

% flatten
trialcell = {trialcell1{:},trialcell2{:},trialcell3{:},trialcell4{:}}; 

[~,mind] = max([numel(trialcell{1}),numel(trialcell{2}),numel(trialcell{3}),numel(trialcell{4})]);

trialcell1 = trialcell{mind};
trialcell2 = textscan(trialnames{2},'%s','Delimiter',delims{mind});
trialcell2 = trialcell2{:};

%------------- END OF CODE --------------
