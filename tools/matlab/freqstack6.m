function varargout = freqstack6(varargin)
% freqstack - Synthesize wide band chirp signal with frequency stacking
%
% Usage:
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack5(trials)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack5(trials,Bs)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack5(trials,dfc,Bs,upfac)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack5(trials,dfc,Bs,upfac,fs)
% Inputs:
%    trials - struct array of trials. Must contain field trials.data,
%    trials.ref, trials.awglen, and trials.fs
%    upfac - upsample factor
%    dfc - center frequency separation
%    Bs - sub waveform bandwidth
%    fs - sample freq
%
% Outputs:
%    data_u - stacked frequency complex data vector
%    filt_u - stacked frequency matched filter compelex waveform
%    x_tx - wideband chirp we are attempting to reconstruct
%    upfac - upsampling factor

% See also: udar_read.m

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:13:06; Last Revised: 2017/04/06 01:13:06

%------------- BEGIN CODE --------------
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
    upfac = ceil(N*Bs/fs);   
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
    upfac = varargin{4};
elseif(nargin==5)
    trials = varargin{1};
    dfc = varargin{2};
    Bs = varargin{3};
    N = numel(trials);
    upfac = varargin{4};
    fs = varargin{5};
else
    usage = sprintf('\n\t[data_u, filt_u, (x_tx)] = freqstack5(trials,dfc)\n\t[data_u, filt_u, (x_tx)] = freqstack5(trials,dfc,Bs,upfac)\n\t[data_u, filt_u, (x_tx)] = freqstack5(trials,dfc,Bs,upfac,fs)');
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
if (nargin>2)
    fc = fc0+(N-1)*dfc/2;
    fn = fc0+(0:(N-1))*dfc;
else
    fc = (trials(end).freq+trials(1).freq)/2;
    fn = [trials.freq];
end
dfn = fn-fc;
dTn = dfn/K;

nzero = (upfac-1)*numel(trials(1).data)/2;
data = zeros(N,upfac*numel(trials(1).data));
filt = zeros(N,upfac*numel(trials(1).ref));

ntau = numel(data(1,:))-n; 
tau=ntau/fs2;
t = linspace(-Tp/2,Tp/2+tau,n+ntau);
t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);


Xn = [];
Zn = [];
for i=1:N
    dfft = fftshift(fft(trials(i).data));
    ftemp = linspace(-fs/2,fs/2,numel(dfft));
%    dfft = dfft.*exp(1i*2*pi*(ftemp+dfn(i))*numel(dfft)*(N/2-i)/fs);
    rec = rect(ftemp,-Bs/2,Bs/2,1);
    ind = find(rec==1);
    if (i<N)
        Zn = [Zn,dfft(ind(1:end-1))];
    else
        Zn = [Zn,dfft(ind)];
    end
    rfft = fftshift(fft(trials(i).ref));
    ftemp = linspace(-fs/2,fs/2,numel(rfft));
%     rfft = rfft.*exp(1i*2*pi*(ftemp+dfn(i))*numel(rfft)*(N/2-i)/fs);
    rec = rect(ftemp,-Bs/2,Bs/2,1);
    ind = find(rec==1);
    if (i<N)
        Xn = [Xn,rfft(ind(1:end-1))];
    else
        Xn = [Xn,rfft(ind)];
    end
end
nzero = max(0,ceil((upfac*numel(trials(1).data)-numel(Zn))/2));
Zn = [zeros(1,nzero),Zn,zeros(1,nzero)];
nzero = max(0,ceil((upfac*numel(trials(1).ref)-numel(Xn))/2));
Xn = [zeros(1,nzero),Xn,zeros(1,nzero)];

% 
% % xn = zeros(1,size(filt,2));
% % zn = zeros(1,size(data,2));
% xn = zeros(1,numel(filt));
% zn = zeros(1,numel(data));
% m = size(data,2);
% for i=1:N
%     xn(m*(i-1)+1:i*m) =  (filt(i,:).*exp(1i*2*pi*dfn(i)*t));%.*exp(1i*pi*dTn(i)*dfn(i));
% %     xn = xn +  (filt(i,:).*exp(1i*2*pi*dfn(i)*t));%.*exp(1i*pi*dTn(i)*dfn(i));
%     zn(m*(i-1)+1:i*m)  = (data(i,:).*exp(1i*2*pi*dfn(i)*t));%.*exp(1i*pi*dTn(i)*dfn(i));
% %     zn = zn + (data(i,:).*exp(1i*2*pi*dfn(i)*t));%.*exp(1i*pi*dTn(i)*dfn(i));
% end
% % t = linspace(-Tp/2,Tp/2+tau,n+ntau);
% % t2 = linspace(-Tp/2,(N-1)*Tp+tau+Tp/2,N*(n+ntau));


data_u = ifft(ifftshift(Zn));
filt_u = ifft(ifftshift(Xn));

t_tx = linspace(-N*Tp/2,N*Tp/2+tau,numel(Xn));
xscale = max(real(filt_u));
x_tx = xscale*exp(1i*pi*K*t_tx.^2).*rect(t_tx,t_tx(1),t_tx(end-ntau),1);

 
if(nargout>=1)
    varargout{1}=data_u;
end
if(nargout>=2)
    varargout{2}=filt_u;
end
if(nargout>=3)
    varargout{3}=x_tx;
end
if(nargout>=4)
    varargout{4}=upfac;
end
end
%------------- END OF CODE --------------