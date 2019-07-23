function b = linearPhaseEstimate(d,fs,varargin)
%linearPhaseEstimate - estimate linear phase slope over occupied bw

% Syntax:  b = linearPhaseEstimate(d,fs,bwpercent=.99)
%
% Inputs:
%    d - time domain signal
%    fs - sample freq
%    bwpercent (optional) - obw percent to estimate over (default = .99)
%
% Outputs:
%    output1 - Description
%    output2 - Description
%
% Example: 
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
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
% Created: 2018/01/19 15:14:28; Last Revised: 2018/01/19 15:14:28
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------
p = inputParser;
paramName = 'fracBW';
defaultVal = 1;
errorMsg = 'Value must be numeric scalar between 0 and 1'; 
validationFcn = @(x) assert(isnumeric(x) && isscalar(x) && (x>=0) && (x<=1),errorMsg);
addOptional(p,paramName,defaultVal,validationFcn);

parse(p,varargin{:})
inparams = p.Results;

bwpercent = inparams.fracBW;

Nd = numel(d);
n = (0:Nd-1)-Nd/2;
% f = n*fs/(Nd-1);
f = n*fs/(Nd);


dfft = fftshift(fft(ifftshift(d)));
dphase = unwrap(angle(dfft));
    
d_obw = obw(d,fs)*bwpercent/.99;

[~,imin]=min(abs(f+d_obw/2));
[~,imax]=min(abs(f-d_obw/2));
fobw = f(imin:imax);
dphase_obw = dphase(imin:imax);

A = [ones(Nd,1),f(:)];
A_obw = [ones(numel(fobw),1),fobw(:)];

b = (A_obw'*A_obw)\(A_obw'*dphase_obw(:));
%------------- END OF CODE --------------
