function varargout = freqstack3(varargin)
% freqstack - Synthesize wide band chirp signal with frequency stacking
%
% Usage:
%    [data_u, (x_tx)] = freqstack3(trials,fs)
%    [data_u, (x_tx)] = freqstack3(trials,fs,dfc,Bs,upfac)
%    [data_u, (filt_u), (x_tx)] = freqstack3(trials,filt,fs,dfc,Bs,upfac)
% Inputs:
%    trials - struct array of trials. Must contain field trials.data
%    filt - complex matched filter waveform data
%    upfac - upsample factor
%    fs - original baseband adc sampling freq
%    dfc - center frequency separation
%    Bs - sub waveform bandwidth
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
    fs = varargin{2};
    
    data_in = [];
    if(strcmp(class(trials),'struct'))
        N=numel(trials);
        for i=1:N
            data_in = [data_in; trials(i).data];
        end
    else
        N = size(trials,1);
        data_in = trials;
    end
    
    % correct frequency shift error to center waveform
%     for i=1:N
%         t_c = linspace(0,size(data_in,2)/fs,size(data_in,2));
%         [a,b,c] = obw(data_in(i,:),fs);
%         ferr = -1*(b+c)/2;
%         data_in(i,:)=data_in(i,:).*exp(1i*2*pi*ferr*t_c);
%     end
    
    % estimate required bw and upsample factor
    ob = obw(data_in(1,:),fs);
    dfc = ob;
    Bs = ob;
    reqbw = N*ob-(N-1)*(ob-dfc);
    upfac = ceil(2*reqbw/fs);
    
    data = [];
    for i=1:N
        data = [data; interp(data_in(i,:),upfac)];
    end
        
    fs2 = fs*upfac;
    n = size(data,2);
    Tp = n/fs2;
    K = Bs/Tp;
    fc0 = 0; fc = fc0+(N-1)*dfc/2;
    fnq = N*Bs*2;
    fn = fc0+(0:(N-1))*dfc;
    dfn = fn-fc;
    dTn = dfn/K;
    
    ntau = 0;
    tau=ntau/fs2;
    
    t = linspace(-Tp/2,Tp/2+tau,n+ntau);
    t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);
    
    xscale = max(real(data(1,:)));    
    x_tx = xscale*exp(1i*pi*K*t2.^2).*rect(t2,t2(1),t2(end-ntau),1);

    gn = [];
    tfilt = t2;
%     for i=1:N
%         gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
%             exp(1i*pi*dTn(i)*fn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
%     end
    for i=1:N
        gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
            exp(1i*pi*dTn(i)*dfn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
    end

    dtu = 1/(N*fnq);

    Zn = [];
    fftlen = 2*ceil(size(gn,2));
    for i=1:N
        Zn  = [Zn;fft(gn(i,:),fftlen).*fft((data(i,:).*exp(1i*2*pi*dfn(i)*t)),fftlen)];
    end

    if (N>1)
        data_u = ifft(sum(Zn));
    else
        data_u = ifft(Zn);
    end    
    
    if(nargout>=1)
        varargout{1}=data_u;
    end
    if(nargout>=2)
        varargout{2}=x_tx;
    end
    
elseif(nargin==5)
    trials = varargin{1};
    fs = varargin{2};
    dfc = varargin{3};
    Bs = varargin{4};
    upfac = varargin{5};
    
    data = [];
    if(strcmp(class(trials),'struct'))
        N=numel(trials);
        for i=1:N
            data = [data; interp(trials(i).data,upfac)];
        end
    else
        N = size(trials,1);
        for i=1:N
            data = [data; interp(trials(i,:),upfac)];
        end
    end
    
    fs2 = fs*upfac;
    n = size(data,2);
    Tp = n/fs2;
    K = Bs/Tp;
    fc0 = 0; fc = fc0+(N-1)*dfc/2;
    fnq = N*Bs*2;
    fn = fc0+(0:(N-1))*dfc;
    dfn = fn-fc;
    dTn = dfn/K;
    
    ntau = 0; 
    tau=ntau/fs2;
    
    t = linspace(-Tp/2,Tp/2+tau,n+ntau);
    t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);
    
    xscale = max(real(data(1,:)));    
    x_tx = xscale*exp(1i*pi*K*t2.^2).*rect(t2,t2(1),t2(end-ntau),1);


    gn = [];
    tfilt = t2;
%     for i=1:N
%         gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
%             exp(1i*pi*dTn(i)*fn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
%     end
    for i=1:N
        gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
            exp(1i*pi*dTn(i)*dfn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
    end

    dtu = 1/(N*fnq);

    Zn = [];
    fftlen = 2*ceil(size(gn,2));
    for i=1:N
        Zn  = [Zn;fft(gn(i,:),fftlen).*fft((data(i,:).*exp(1i*2*pi*dfn(i)*t)),fftlen)];
    end

    if (N>1)
        data_u = ifft(sum(Zn));
    else
        data_u = ifft(Zn);
    end    
    
    if(nargout>=1)
        varargout{1}=data_u;
    end
    if(nargout>=2)
        varargout{2}=x_tx;
    end
    
elseif(nargin==6)
    trials = varargin{1};
    filt = varargin{2};
    fs = varargin{3};
    dfc = varargin{4};
    Bs = varargin{5};
    upfac = varargin{6};
    
    N = numel(trials);
    ob = obw(filt,fs);
    reqbw = N*ob-(N-1)*(ob-dfc);
    %upfac_guess = ceil(2*reqbw/fs)

    filt = interp(filt,upfac);
    data = [];
    for i=1:N
        data = [data; interp(trials(i).data,upfac)];
    end

    fs2 = fs*upfac;
    Tp = numel(filt)/fs2;
    K = Bs/Tp;
    fc0 = 0; fc = fc0+(N-1)*dfc/2;
    fnq = N*Bs*2;
    fn = fc0+(0:(N-1))*dfc;
    dfn = fn-fc;
    dTn = dfn/K;

    n = numel(filt);
    ntau = numel(data(1,:))-numel(filt); 
    tau=ntau/fs2;
    t = linspace(-Tp/2,Tp/2+tau,n+ntau);
    t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);

    xscale = max(real(filt));
    x_tx = xscale*exp(1i*pi*K*t2.^2).*rect(t2,t2(1),t2(end-ntau),1);
    
   

    filt = [filt,zeros(1,ntau)];

    gn = [];

    tfilt = t2;
%     for i=1:N
%         gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
%             exp(1i*pi*dTn(i)*fn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
%     end
    for i=1:N
        gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
            exp(1i*pi*dTn(i)*dfn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
    end

    dtu = 1/(N*fnq);
    
    Xn = []; Zn = [];
    fftlen = 2*ceil(size(gn,2));
    for i=1:N
        Xn  = [Xn;fft(gn(i,:),fftlen).*fft((filt.*exp(1i*2*pi*dfn(i)*t)),fftlen)];
        Zn  = [Zn;fft(gn(i,:),fftlen).*fft((data(i,:).*exp(1i*2*pi*dfn(i)*t)),fftlen)];
    end

    if (N>1)
        data_u = ifft(sum(Zn));
        filt_u = ifft(sum(Xn));
    else
        data_u = ifft(Zn);
        filt_u = ifft(Xn);
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
else
    usage = sprintf('\n\t[data_u, (x_tx)] = freqstack3(trials,fs)\n\t[data_u, (x_tx)] = freqstack3(trials,fs,dfc,Bs,upfac)\n\t[data_u, (filt_u), (x_tx)] = freqstack3(trials,filt,fs,dfc,Bs,upfac)');
    error(['Invalid number of arguments. Usage: ',usage]);
end
end
%------------- END OF CODE --------------
