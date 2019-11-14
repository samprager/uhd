function udar_removesweeps(outdir,sweepinds)
%udar_removesweeps - remove sweeps in a trial directory and reindex
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Inputs:
%    outdir - Base directory containing sweep-0,...
%    sweepinds - sweep numbers to delete ie. [0,5,...]
%    input3 - Description
%
%
% Example: 
%    udar_removesweeps('~/.x300_client/outputs/mytest/',[10,15])
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Samuel Prager
% Microwave Systems, Sensors and Imaging Lab (MiXiL) 
% University of Southern California
% Email: sprager@usc.edu
% Created: 2018/09/25 14:12:52; Last Revised: 2018/09/25 14:12:52
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------

if (~strcmp(outdir(end),'/')&&(isunix))
    outdir = [outdir,'/'];
elseif (~strcmp(outdir(end),'\')&&(ispc))
    outdir = [outdir,'\'];
end

deldir = [outdir,'deleted/'];
if (exist(deldir)==0)
    mkdir(deldir);
end

fids = dir(outdir);
dirflags = [fids.isdir];
subfolders = fids(dirflags);

currentswp = sweepinds(1);
numtotalswps = numel(subfolders);
lastgoodswp = currentswp-1;

numtotalswps = numtotalswps-3; % 'deleted/', './', and '../' don't count
if (numtotalswps<1)
    error('unable to find valid sweep directories in %s',outdir);
end

for i=1:numel(sweepinds)
    movefile([outdir,sprintf('sweep-%i',sweepinds(i))],[deldir,sprintf('sweep-%i',sweepinds(i))]);
    newind = lastgoodswp+1;
    if (i<numel(sweepinds))
        endind = (sweepinds(i+1)-1);
    else
        endind = numtotalswps-1;
    end
    for j=(sweepinds(i)+1):endind
        movefile([outdir,sprintf('sweep-%i',j)],[outdir,sprintf('sweep-%i',newind)]);
        newind = newind+1;
    end
    lastgoodswp = newind-1;
end

%------------- END OF CODE --------------
