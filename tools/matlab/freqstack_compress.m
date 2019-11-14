function varargout = freqstack_compress(varargin)
% freqstack - Synthesize wide band chirp signal with frequency stacking and
% compress pulse
%
% Usage:
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_compress(trials)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_compress(trials,Bs)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_compress(trials,dfc,Bs,upfac)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_compress(trials,dfc,Bs,upfac,fs)
% Inputs:
%    trials - struct array of trials. Must contain field trials.data,
%    trials.ref, trials.awglen, and trials.fs
%    upfac - upsample factor
%    dfc - center frequency separation
%    Bs - sub waveform bandwidth
%    fs - sample freq
%
% Outputs:
%    data_u - compressed pulse after freq stacking
%    l - sample lag
%    d_tx - ideal wideband compressed pulse
%    upfac - upsampling factor

% See also: udar_read.m

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:13:06; Last Revised: 2017/04/06 01:13:06

%------------- BEGIN CODE --------------
usedfc = 1;
if(nargin==1)
    trials = varargin{1}; 
    fs = trials(1).fs;
    N = numel(trials);
    if (N>1)
        dfc = trials(2).freq-trials(1).freq; 
    else
        error('When using one argument, trials struct array must contain at least two trials'); 
    end
    Bs = dfc;
    upfac = ceil((N)*Bs/fs);   
elseif(nargin==2)
    trials = varargin{1};
    Bs = varargin{2}; 
    fs = trials(1).fs;
    N = numel(trials);
    if (N>1)
        dfc = trials(2).freq-trials(1).freq; 
    else
        dfc = Bs;
    end
    upfac = ceil(N*Bs/fs);    
elseif(nargin==4)
    trials = varargin{1};
    fs = trials(1).fs;
    dfc = varargin{2};
    Bs = varargin{3};
    N = numel(trials);
    if(dfc==-1)
        usedfc = 0;
        if (N>1)
            dfc = trials(2).freq-trials(1).freq; 
        else
            dfc = Bs;
        end
    end
    upfac = varargin{4};
elseif(nargin>=5)
    trials = varargin{1};
    dfc = varargin{2};
    Bs = varargin{3};
    N = numel(trials);
    if(dfc==-1)
        usedfc = 0;
        if (N>1)
            dfc = trials(2).freq-trials(1).freq; 
        else
            dfc = Bs;
        end
    end
    upfac = varargin{4};
    fs = varargin{5};
else
    usage = sprintf('\n\t[data_u, filt_u, (x_tx)] = freqstack_compress(trials,dfc)\n\t[data_u, filt_u, (x_tx)] = freqstack_compress(trials,dfc,Bs,upfac)\n\t[data_u, filt_u, (x_tx)] = freqstack_compress(trials,dfc,Bs,upfac,fs)');
    error(['Invalid number of arguments. Usage: ',usage]);
end
    
if ((numel(trials(1).ref)==0) || (fs==0) || (~isstruct(trials)))
    error('trials must be a struct with fields trials.data,trials.ref, trials.awglen, (and trials.fs)');
end
    
% n = trials(1).awglen*upfac;
n= numel(trials(1).data)*upfac;
fs2 = fs*upfac;
Tp = n/fs2;
K = Bs/Tp;
fnq = N*Bs*2;
fc0 = 0; 
if ((nargin>2)&&(usedfc == 1))
    fc = fc0+(N-1)*dfc/2;
    fn = fc0+(0:(N-1))*dfc;
else
    fc = (trials(end).freq+trials(1).freq)/2;
    fn = [trials.freq];
end
dfn = fn-fc;
dTn = dfn/K;


nzero = (upfac-1)*numel(trials(1).data)/2;

ntau = upfac*numel(trials(1).data)-n; 
tau=ntau/fs2;

D = zeros(N,upfac*numel(trials(1).data));

for i=1:N
    dfft = fftshift(fft(trials(i).data).*conj(fft(trials(i).ref)));
%     ftemp = linspace(-fs/2,fs/2,numel(dfft));
    dftemp = fs/numel(dfft);
    ftemp = [-fs/2:dftemp:fs/2-dftemp];
    
    flim1 = -Bs/2;
    flim2 = Bs/2;
%     if (i==1)
%         flim1 = ftemp(1);
%     end
%     if(i==N)
%         flim2 = ftemp(end);
%     end
    dfft = dfft.*rect(ftemp,flim1,flim2,1);

    dfft = upfac*[zeros(1,nzero),dfft,zeros(1,nzero)];
    D(i,:) = shift(dfft,dfn(i)*numel(dfft)/fs2);

end

data_u = fftshift(ifft(ifftshift(sum(D,1))));

% t_tx = linspace(-Tp/2,Tp/2+tau,numel(data_u));
dTp = Tp/numel(data_u);
t_tx = [-Tp/2:dTp:Tp/2+tau-dTp];

% x_tx = exp(1i*pi*K*t_tx.^2).*rect(t_tx,t_tx(1),t_tx(end-ntau),1);

if (nargin>5)
    if (strcmp(varargin{6},'rect'))
        ftemp = linspace(-fs*upfac/2,fs*upfac/2,numel(t_tx));
        d_tx = fftshift(ifft(ifftshift(rect(ftemp,-1*(dfn(end)+Bs/2),dfn(end)+Bs/2,1))));
    else
        tx_rect =  rect(t_tx,t_tx(1),t_tx(end-ntau),1);
        if(strcmp(varargin{6},'hamming'))
            tx_win = tx_rect;
            tx_win2 = getHamming(numel(tx_win(tx_win~=0))).';
            tx_win(tx_win~=0)=tx_win2;
        elseif(strcmp(varargin{6},'chebwin') || strcmp(varargin{6},'chebyshev'))
            tx_win = tx_rect;
            tx_win2 = chebwin(numel(tx_win(tx_win~=0))).';
            tx_win(tx_win~=0)=tx_win2;
        else
            tx_win = tx_rect;
        end
        x_tx = exp(1i*pi*((dfn(end)+Bs/2)/(Tp/2))*t_tx.^2).*tx_rect;
        d_tx = fftshift(ifft(fft(x_tx).*conj(fft(x_tx.*tx_win))));
    end
end


% l = linspace(-numel(data_u)/2,numel(data_u)/2,numel(data_u));
% l = l + l(end/2);
l = -numel(data_u)/2:1:(numel(data_u)/2-1);
 
if(nargout>=1)
    varargout{1}=data_u;
end
if(nargout>=2)
    varargout{2}=l;
end
if(nargout>=3)
    varargout{3}=d_tx;
end
if(nargout>=4)
    varargout{4}=upfac;
end
end
%------------- END OF CODE --------------