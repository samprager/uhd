function [trialsout,reftrials] = udar_preprocess(trials,varargin)
%udar_preprocess - performs pre-processing of usrp udar data (phase
%correction, zeropad removal
%Optional file header info (to give more details about the function than in the H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Inputs:
%    input1 - Description
%    input2 - Description
%    input3 - Description
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
% Created: 2018/01/19 13:47:37; Last Revised: 2018/01/19 13:47:37
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------

p = inputParser;
paramName = 'Freqs';
defaultVal = [0 Inf];
errorMsg = 'Value must be numeric'; 
validationFcn = @(x) assert(isnumeric(x),errorMsg);
% addParameter(p,paramName,defaultVal,validationFcn);
addOptional(p,paramName,defaultVal,validationFcn);

paramName = 'WaveDirectory';
defaultVal = '~/.x300_Client/waveforms/';
errorMsg = 'String must be a path of an existing waveform directory'; 
% validationFcn = @(x) assert(((exist(x)==7) && ischar(x)),errorMsg);
validationFcn = @(x) assert(ischar(x),errorMsg);

% addParameter(p,paramName,defaultVal,validationFcn);
addOptional(p,paramName,defaultVal,validationFcn);


paramName = 'CorrectPhase';
defaultVal = 1;
errorMsg = 'Value must be 0 (false) or 1 (true)'; 
validationFcn = @(x) assert((isnumeric(x) && isscalar(x) && ((x==1)||(x==0)))||(islogical(x)) && (x >= 0),errorMsg);
addParameter(p,paramName,defaultVal,validationFcn);
paramName = 'LinearPhaseFit';
defaultVal = 0;
errorMsg = 'Value must be 0 (false) or 1 (true)'; 
validationFcn = @(x) assert((isnumeric(x) && isscalar(x) && ((x==1)||(x==0)))||(islogical(x)) && (x >= 0),errorMsg);
addParameter(p,paramName,defaultVal,validationFcn);
paramName = 'IQEqualize';
defaultVal = 1;
errorMsg = 'Value must be 0 (false) or 1 (true)'; 
validationFcn = @(x) assert((isnumeric(x) && isscalar(x) && ((x==1)||(x==0)))||(islogical(x)) && (x >= 0),errorMsg);
addParameter(p,paramName,defaultVal,validationFcn);
paramName = 'Zeropad';
defaultVal = 512;
errorMsg = 'Value must numeric and >= 0'; 
validationFcn = @(x) assert((isnumeric(x) && isscalar(x) && (x>=0)),errorMsg);
addParameter(p,paramName,defaultVal,validationFcn);
paramName = 'Window';
defaultVal = '';
errorMsg = 'Value must be window id string (hamming,chebyshev, kaiser<alpha>, hann, blackman-harris)'; 
validationFcn = @(x) assert(ischar(x),errorMsg);
addParameter(p,paramName,defaultVal,validationFcn);

parse(p,varargin{:})
inparams = p.Results;

wavedirfound = (exist(inparams.WaveDirectory)==7);

if (inparams.CorrectPhase)
    if(~wavedirfound)
        errstr = sprintf('Asked to use waveform file, but waveform directory: %s does not exist',inparams.WaveDir);
        error(errstr);
    end
end

fmin = inparams.Freqs(1);
fmax = inparams.Freqs(end);
zp_pre = inparams.Zeropad;
wavedir = inparams.WaveDirectory;
correct_phase = inparams.CorrectPhase;
lin_phase_fit = inparams.LinearPhaseFit;
iq_equalize = inparams.IQEqualize;


trials = trials(([trials.freq]>=fmin)&([trials.freq]<=fmax));

fs = trials(1).fs;
device = trials(1).device;

trialsout = trials;
reftrials = trials;

for i=1:numel(trialsout)

    [~,awgfile,ext] = fileparts(trialsout(i).awgfile);
    waveform_auto = [wavedir,awgfile,ext];
    if(wavedirfound)
        filt = file2wave(waveform_auto);
        waveform = [wavedir,'chirp50.bin'];
        if(numel(filt)==0)
            filt = file2wave(waveform);
        end
        filt = filt(zp_pre+1:end);
    else
        filt = [];
    end

    % equilize I and Q levels
    if (iq_equalize)
        dataremax = max(real(trialsout(i).data));
        dataimmax = max(imag(trialsout(i).data));
        trialsout(i).data = (max(dataremax,dataimmax)/dataremax)*real(trialsout(i).data(zp_pre+1:end))+1i*(max(dataremax,dataimmax)/dataimmax)*imag(trialsout(i).data(zp_pre+1:end));

    % equilize I and Q levels
        refremax = max(real(trialsout(i).ref));
        refimmax = max(imag(trialsout(i).ref));
        trialsout(i).ref = (max(refremax,refimmax)/refremax)*real(trialsout(i).ref(zp_pre+1:end))+1i*(max(refremax,refimmax)/refimmax)*imag(trialsout(i).ref(zp_pre+1:end));
    else
        trialsout(i).data = trialsout(i).data(zp_pre+1:end);
        trialsout(i).ref = trialsout(i).ref(zp_pre+1:end);
    end
    trialsout(i).awglen = trialsout(i).awglen-zp_pre;

%     trialsout(i).freq = trialsout(i).freq + (randi(4e6,1,1)-2e6);

    if(correct_phase)
    % Correct Phase
    %     [d,l]=xcorr(trialsout(i).ref,filt);
    %     len = 2*numel(trialsout(i).ref);
        [d,l]=mfiltu(trialsout(i).ref,filt,1);
        len = 1*numel(trialsout(i).ref);

        dfft = fftshift(fft(ifftshift(d),len));
        xfft = fftshift(fft(trialsout(i).ref,len));
        zfft = fftshift(fft(trialsout(i).data,len));
        if(lin_phase_fit)
            dphase = unwrap(angle(dfft));

            Nd = numel(d);
            n = (0:Nd-1)-Nd/2;
            f = n*fs/(Nd);
            d_obw = obw(d,fs)*.9/.99;

            [~,imin]=min(abs(f+d_obw/2));
            [~,imax]=min(abs(f-d_obw/2));
            fobw = f(imin:imax);
            dphase_obw = dphase(imin:imax);

            A = [ones(Nd,1),f(:)];
            A_obw = [ones(numel(fobw),1),fobw(:)];

            b = (A_obw'*A_obw)\(A_obw'*dphase_obw(:));

            xfft = xfft.*exp(-1i*(A*b).');
            zfft = zfft.*exp(-1i*(A*b).');
        else
            xfft = xfft.*exp(-1i*angle(dfft));
            zfft = zfft.*exp(-1i*angle(dfft));
        end
        xfft = ifft(ifftshift(xfft));
        zfft = ifft(ifftshift(zfft));

        trialsout(i).ref = xfft(1:numel(trialsout(i).ref));
        trialsout(i).data = zfft(1:numel(trialsout(i).data));
    end
    win = getWindow(inparams.Window,numel(filt));
    filt = filt.*sqrt(win);
    trialsout(i).filt = filt;

    filtmp=[filt,zeros(1,numel(trialsout(i).ref)-numel(filt))];

    reftrials(i).data = trialsout(i).ref;
    reftrials(i).ref = trialsout(i).ref;
    reftrials(i).awglen = trialsout(i).awglen;
    reftrials(i).freq = trialsout(i).freq;
    reftrials(i).filt = filt;

end

%------------- END OF CODE --------------
