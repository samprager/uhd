function [Bs,dfc,bweff,upfac,BWtotal,varargout] = udar_analyze(trials,varargin)
%udar_analyze - parameter analysis to calculate reconstruction values
%
% Syntax:  [Bs,dfc,bweff,upfac,BWtotal] = udar_analyze(trials)
%
% Inputs:
%    trials - struct array of freq. sweep trials. Must contain field trials.data,
%             trials.ref, trials.awglen, trials.freq and trials.fs.
%             -> trials.freq should contain the center frequencies of each sub-pulse           
%
% Outputs:
%    Bs - Sub-pulse bandwidth (calculated with obw())
%    dfc - average sub-pulse spacing
%    bweff - calculated bandwidth efficiency (0-1)
%    upfac - recommended freq stacking upsample factor
%    BWtotal - total bandwidth of frequency sweep.
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: udar_read.m,  udar_preprocess.m, freqstack_nonuniform.m

% Author: Samuel Prager
% Microwave Systems, Sensors and Imaging Lab (MiXiL) 
% University of Southern California
% Email: sprager@usc.edu
% Created: 2018/05/23 15:12:32; Last Revised: 2018/05/23 15:12:32
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------
p = inputParser;
paramName = 'debugmode';
defaultVal = 0;
errorMsg = 'value must be numeric'; 
validationFcn = @(x) assert((isnumeric(x) && isscalar(x)),errorMsg);
addParameter(p,paramName,defaultVal,validationFcn);

parse(p,varargin{:})
inparams = p.Results;

debugmode = inparams.debugmode;

if (numel(trials)<1)
    error('trials struct empty');
elseif(numel(trials)<2)
    Bs = obw(trials(1).ref,trials(1).fs)*(1.0/.99);
    bweff = 1;
    dfc = Bs;
    BWtotal = Bs;
    upfac = 1;
    return;
end

freqs = [trials.freq];
fs = trials(1).fs;

Bs = obw(trials(1).ref,fs)*(1.0/.99);
upfac = ceil(numel(trials)*(Bs)/fs);

bweffavg = 0;
% bwlims = [freqs-bw/2;freqs+bw/2]
bwlims = circshift(diag(freqs-Bs/2,1),-1,2)+diag(freqs+Bs/2,-1);
% bweffs = [bweffavg];
navg=0;
for i=2:numel(trials)
    f1max = freqs(i-1)+Bs/2;
    f2min = freqs(i)-Bs/2;
    foverlap = f1max-f2min;
    if (foverlap>0)
        bweffavg = bweffavg+(Bs-foverlap)/Bs;
        navg = navg+1;
    end
%     bweffs = [bweffs,bweffavg/navg];

end
bweffavg = bweffavg/navg;
% figure(500);hold on; plot(bweffs); title('bweffs');

freq_rec = freqs;
for i=2:numel(trials)
    f1max = freq_rec(i-1)+Bs/2;
    f2min = freq_rec(i)-Bs/2;
    foverlap = f1max-f2min;
    if (foverlap<0)
        if (debugmode<=1)
            freq_rec(i:end) = freq_rec(i:end) + foverlap - (1-bweffavg)*Bs;
        else
            nsteps = round((freq_rec(i)-freq_rec(i-1))/Bs);
            freq_rec(i:end) = freq_rec(i:end)-(nsteps-1+(1-bweffavg))*Bs;
        end
    end
    
    if (debugmode>0)
        freq_rec(i)-freq_rec(i-1)
    end

end

bweff = bweffavg;
dfc = (Bs/1.0)*(bweff);

BWspread = (trials(end).freq- trials(1).freq)+Bs;
BWtotal = (numel(trials)-1)*dfc+Bs;
BWtotal = min([BWtotal,BWspread]);

if (nargout>5)
    varargout{1} = freq_rec;
end
%------------- END OF CODE --------------
