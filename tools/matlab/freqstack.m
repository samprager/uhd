function [data_u,filt_u] = freqstack(trials,filt,upfac,fs,fc)
% freqstack - Synthesize wide band chirp signal with frequency stacking
%
% Inputs:
%    trials - struct array of trials. Must contain field trials.data
%    filt - complex matched filter waveform data
%    upfac - upsample factor
%    fs - original baseband adc sampling freq
%    fc - center frequency separation
%
% Outputs:
%    data_u - stacked frequency complex data vector
%    filt_u - stacked frequency matched filter compelex waveform
%
% See also: udar_read.m

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:13:06; Last Revised: 2017/04/06 01:13:06

%------------- BEGIN CODE --------------
fs2 = fs*upfac; 

filt_u = [];
data_u = 0;
t_u = linspace(0,upfac*size(filt,2)/fs2,upfac*size(filt,2));
t_u1 = linspace(0,upfac*size(trials(1).data,2)/fs2,upfac*size(trials(1).data,2));

ntrials = numel(trials);
% for i=1:ntrials
%     predelay = [zeros(1,numel(filt_u)) 1];
%     filt_u = [filt_u,interp(filt,upfac).*exp(1i*(i-1)*2*pi*fc*t_u)];
%     data_utemp = conv(interp(trials(i).data,upfac).*exp(1i*(i-1)*2*pi*fc*t_u1),predelay);
%     postdelay = [1 zeros(1,numel(data_utemp)-numel(data_u))];
%     data_u = conv(data_u,postdelay)+data_utemp;
% end

lastind = 1;
for i=1:ntrials
    filt_u = [filt_u,interp(filt,upfac).*exp(1i*(i-1)*2*pi*fc*t_u)];
    data_utemp = interp(trials(i).data,upfac).*exp(1i*(i-1)*2*pi*fc*t_u1);
    firstind = 1;
    if(i>1)
    for j=1:numel(data_utemp)
        if(abs(data_utemp(j))>(max(abs(data_utemp))/10))
            firstind = j;
            break;
        end
    end
    end

    predelay = [zeros(1,max(0,lastind-firstind)) 1];
    data_utemp = conv(data_utemp,predelay);

    postdelay = [1 zeros(1,numel(data_utemp)-numel(data_u))];
    data_u = conv(data_u,postdelay)+data_utemp;
    
    lastind = numel(data_u);
    for j=numel(data_u):-1:1
        if(abs(data_u(j))>(max(abs(data_u))/10))
            lastind = j;
            break;
        end
    end
end
end
%------------- END OF CODE --------------
