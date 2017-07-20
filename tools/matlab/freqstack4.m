function varargout = freqstack4(varargin)
% freqstack - Synthesize wide band chirp signal with frequency stacking
%
% Usage:
%    [data_u, filt_u, (x_tx)] = freqstack4(trials,dfc)
%    [data_u, filt_u, (x_tx)] = freqstack4(trials,dfc,Bs,upfac)
%    [data_u, filt_u, (x_tx)] = freqstack4(trials,dfc,Bs,upfac,fs)
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

% See also: udar_read.m

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:13:06; Last Revised: 2017/04/06 01:13:06

%------------- BEGIN CODE --------------
if(nargin==2)
    trials = varargin{1};
    dfc = varargin{2}; 
    Bs = dfc;
    fs = trials(1).fs;
    N = numel(trials);
    upfac = ceil(N*2*Bs/fs);
    
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
    usage = sprintf('\n\t[data_u, filt_u, (x_tx)] = freqstack4(trials,dfc)\n\t[data_u, filt_u, (x_tx)] = freqstack4(trials,dfc,Bs,upfac)\n\t[data_u, filt_u, (x_tx)] = freqstack4(trials,dfc,Bs,upfac,fs)');
    error(['Invalid number of arguments. Usage: ',usage]);
end
    
if ((numel(trials(1).ref)==0) || (fs==0) || (~isstruct(trials)))
    error('trials must be a struct with fields trials.data,trials.ref, trials.awglen, (and trials.fs)');
end
    
n = trials(1).awglen*upfac;
fs2 = fs*upfac;
Tp = n/fs2;
K = Bs/Tp;
fc0 = 0; fc = fc0+(N-1)*dfc/2;
fnq = N*Bs*2;
fn = fc0+(0:(N-1))*dfc;
dfn = fn-fc;
dTn = dfn/K;

data = [];
for i=1:N
    data = [data; upsample(trials(i).data,upfac)];
end

filt = [];
for i=1:N
    filt = [filt; upsample(trials(i).ref,upfac)];
end

ntau = numel(data(1,:))-n; 
tau=ntau/fs2;
t = linspace(-Tp/2,Tp/2+tau,n+ntau);
t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);

% t = linspace(-Tp/2,Tp/2+tau,n+ntau);
% t2 = linspace(-Tp/2,(N-1)*Tp+tau+Tp/2,N*(n+ntau));

xscale = max(real(filt(1,:)));
x_tx = xscale*exp(1i*pi*K*t2.^2).*rect(t2,t2(1),t2(end-ntau),1);

gn = [];

tfilt = t2;
for i=1:N
    gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
        exp(1i*pi*dTn(i)*dfn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
end

dtu = 1/(N*fnq);
zn = []; xn = [];
for i=1:N
    zn = [zn;conv(data(i,:).*exp(1i*2*pi*dfn(i)*t),gn(i,:))];
    xn = [xn;conv(filt(i,:).*exp(1i*2*pi*dfn(i)*t),gn(i,:))];
end

if (N>1)
    data_u = sum(zn);
    filt_u = sum(xn);
else
    data_u = zn;
    filt_u = xn;
end

if(nargout>=1)
    varargout{1}=data_u;
end
if(nargout>=2)
    varargout{2}=filt_u;
end
if(nargout>=3)
    varargout{3}=x_tx;
end
end
%------------- END OF CODE --------------
