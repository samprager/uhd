function varargout = freqstack_num(varargin)
% freqstack - Synthesize wide band chirp signal with frequency stacking
%
% Usage:
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_num(trials)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_num(trials,Bs)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_num(trials,dfc,Bs,upfac)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_num(trials,dfc,Bs,upfac,fs)
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
    usage = sprintf('\n\t[data_u, filt_u, (x_tx)] = freqstack_num(trials,dfc)\n\t[data_u, filt_u, (x_tx)] = freqstack_num(trials,dfc,Bs,upfac)\n\t[data_u, filt_u, (x_tx)] = freqstack_num(trials,dfc,Bs,upfac,fs)');
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

ntau =0; 
tau=ntau/fs2;
t = linspace(-Tp/2,Tp/2+tau,n+ntau);
t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);

x_tx = exp(1i*pi*K*t2.^2).*rect(t2,t2(1),t2(end-ntau),1);
% win = tukeywin(numel(x_tx),0.1).';
% x_tx=x_tx.*win;
X_tx = fft(x_tx);

fftlen = numel(x_tx);
X_tx = fft(x_tx,fftlen);
Xn = zeros(N,fftlen);
Zn = zeros(N,fftlen);
nzero = (upfac-1)*numel(trials(1).data)/2;
for i=1:N
    dfft = fftshift(fft(trials(i).data));
    ftemp = linspace(-fs/2,fs/2,numel(dfft));
    dfft = [zeros(1,nzero),dfft.*rect(ftemp,-Bs/2,Bs/2,1),zeros(1,nzero)];   
    Zn(i,:)  = fft(((ifft(ifftshift(dfft))).*exp(1i*2*pi*dfn(i)*t)),fftlen);
    rfft = fftshift(fft(trials(i).ref));
    ftemp = linspace(-fs/2,fs/2,numel(rfft));
    rfft = [zeros(1,nzero),rfft.*rect(ftemp,-Bs/2,Bs/2,1),zeros(1,nzero)];
    Xn(i,:)  = fft(((ifft(ifftshift(rfft))).*exp(1i*2*pi*dfn(i)*t)),fftlen);
end    

Z_rx = 0;
X_rx = 0;
ftemp=linspace(-fs2/2,fs2/2,size(Xn,2));
for i=1:N
%    X_rx  = X_rx+Gn(i,:).*Xn(i,:).*ifftshift(rect(linspace(-fs2/2,fs2/2,numel(Xn(i,:))),dfn(i)-Bs/2,dfn(i)+Bs/2,1));
%    Z_rx  = Z_rx+Gn(i,:).*Zn(i,:).*ifftshift(rect(linspace(-fs2/2,fs2/2,numel(Zn(i,:))),dfn(i)-Bs/2,dfn(i)+Bs/2,1));
    H = (1./(Xn(i,:)./X_tx));
    H(~isfinite(H))=1;
   X_rx  = X_rx+(Xn(i,:).*H).*ifftshift(rect(ftemp,dfn(i)-Bs/2,dfn(i)+Bs/2,1));
   Z_rx  = Z_rx+(Zn(i,:).*H).*ifftshift(rect(ftemp,dfn(i)-Bs/2,dfn(i)+Bs/2,1));
end
data_u = ifft(Z_rx);
filt_u = ifft(X_rx);
    

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