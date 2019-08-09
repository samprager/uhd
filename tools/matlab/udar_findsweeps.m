function numtotalswps = udar_findsweeps(outdir)
%udar_findsweeps - parses a test directory to get number of sweeps inside
%
% Syntax:  numtotalswps = udar_findsweeps(outdir)
%
% Inputs:
%    outdir - Output directory of a test. Ie outdir = ['/Users/sam/.x300_Client/outputs/mytest-A/']      
%
% Outputs:
%    numtotalswps - number of sweeps in test directory
%    
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: udar_read.m,  udar_preprocess.m

% Author: Samuel Prager
% Microwave Systems, Sensors and Imaging Lab (MiXiL) 
% University of Southern California
% Email: sprager@usc.edu
% Created: 2019/02/07
%
% Copyright 2012-2019 University of Southern California
%------------- BEGIN CODE --------------
fids = dir(outdir);
dirflags = [fids.isdir];
subfolders = fids(dirflags);
numtotalswps = sum(contains({subfolders.name},'sweep'));
% numtotalswps = numel(subfolders)-2; % don't include '..', '.'
%------------- END CODE --------------