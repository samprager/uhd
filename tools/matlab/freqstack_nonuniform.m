function varargout = freqstack_nonuniform(varargin)
% freqstack - Synthesize wide band chirp signal with frequency stacking and
% compress pulse for nonuniform case so that overlaps are removed
%
% Usage:
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_nonuniform(trials)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_nonuniform(trials,Bs)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_nonuniform(trials,dfc,Bs,upfac)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_nonuniform(trials,dfc,Bs,upfac,fs)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_nonuniform(trials,dfc,Bs,upfac,fs,window)
%    [data_u, filt_u, (x_tx), (upfac)] = freqstack_nonuniform(trials,dfc,Bs,upfac,window,stitchmode)

% Inputs:
%    trials - struct array of trials. Must contain field trials.data,
%       trials.ref, trials.awglen, and trials.fs
%    upfac - upsample factor
%    dfc - center frequency separation
%    Bs - sub waveform bandwidth
%    fs - sample freq
%    window - 'rect' 'hamming' or 'chebyshev' for linear. 'nl_hamming', etc
%       for nonlinear
%    stitchmode - 'optimal' or 'default' or Nx2 array of flims to use
%
% Outputs:
%    data_u - compressed pulse after freq stacking
%    l - sample lag
%    d_tx - ideal wideband compressed pulse
%    upfac - upsampling factor
%    flims - Nx2 matrix of stitch points used

% See also: udar_read.m

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/12/04 01:13:06; Last Revised: 2017/12/04 01:13:06

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
  
stitchmode = 'default';
if(nargin>=7)
    if (isnumeric(varargin{7}))
        stitchmode = 'provided';
        flimsin = varargin{7};
    else
        stitchmode = varargin{7};
    end
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
    d = mfiltu(trials(i).data,trials(i).ref,upfac);
    ttemp = -Tp/2:(1/fs2):(Tp/2-1/fs2);
    d = d.*exp(1i*2*pi*ttemp*dfn(i));
    dfft = fftshift(fft(ifftshift(d)));
    D(i,:) = dfft;
end

ftemp = -fs2/2:(fs2/n):(fs2/2-fs2/n);
if(strcmp(stitchmode,'provided'))
    flims = flimsin;
else
    flims = zeros(numel(dfn),2);
    flims(1,1)=-fs2/2;
    if (strcmp(stitchmode,'optimal'))
        f_range = Bs/10;
        grad_wgt = 1;
        val_wgt = 1;
        for i=1:(numel(dfn)-1)
            flim_c=(dfn(i)+dfn(i+1))/2;
            flim_1 = flim_c-f_range/2;
            flim_2 = flim_c+f_range/2;
            finds = find(ftemp>=flim_1 & ftemp<flim_2);
        %     d1 = gradient(D(i,finds));
        %     d2 = gradient(D(i+1,finds));
            d1 = (D(i,finds));
            d2 = (D(i+1,finds));
            [~,minind]=min(val_wgt*abs(d1-d2)+grad_wgt*abs(gradient(d1)-gradient(d2)));
        %     flims(i,2) = ftemp(finds(1)+minind-1)+fs2/n;
            flims(i,2) = ftemp(finds(1)+minind-1);
            flims(i+1,1)=flims(i,2);
        end
    else % default
        for i=1:(numel(dfn)-1)
            flim_c=(dfn(i)+dfn(i+1))/2;
            flims(i,2) = (dfn(i)+dfn(i+1))/2;
            flims(i+1,1)=flims(i,2);
        end
    end
    flims(end,2)=fs2/2;
end


% for i=1:(numel(dfn)-1)
%     flim_c=(dfn(i)+dfn(i+1))/2;
%     flims(i,2) = (dfn(i)+dfn(i+1))/2;
%     flims(i+1,1)=flims(i,2);
% end
% flims(end,2)=fs2/2;

for i=1:N
    D(i,:) = D(i,:).*rect(ftemp,flims(i,1),flims(i,2),1);
end

% for i=1:N
%     dfft = fftshift(fft(trials(i).data).*conj(fft(trials(i).ref)));
% %     ftemp = linspace(-fs/2,fs/2,numel(dfft));
%     dftemp = fs/numel(dfft);
%     ftemp = [-fs/2:dftemp:fs/2-dftemp];
%     
%     flim1 = -Bs/2;
%     flim2 = Bs/2;
% 
%     dfft = dfft.*rect(ftemp,flim1,flim2,1);
% 
%     dfft = [zeros(1,nzero),dfft,zeros(1,nzero)];
%     D(i,:) = shift(dfft,dfn(i)*numel(dfft)/fs2);
% 
% end

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
        if(strfind(varargin{6},'hamming'))
            tx_win = tx_rect;
            tx_win2 = getHamming(numel(tx_win(tx_win~=0))).';
            tx_win(tx_win~=0)=tx_win2;
        elseif(strfind(varargin{6},'chebwin'))
            tx_win = tx_rect;
            tx_win2 = chebwin(numel(tx_win(tx_win~=0))).';
            tx_win(tx_win~=0)=tx_win2;
        else
            tx_win = tx_rect;
        end
        x_tx = exp(1i*pi*((dfn(end)+Bs/2)/(Tp/2))*t_tx.^2).*tx_rect;
%         d_tx = fftshift(ifft(fft(x_tx).*conj(fft(x_tx.*tx_win))));
        s_l = sqrt(tx_win).*x_tx;
        Btnl = dfn(end)-dfn(1)+Bs;
        if (strfind(varargin{6},'nl'))
            [s_nl,~]=nonlinearfm(s_l,fs2,Btnl);
        else
            s_nl = s_l;
        end
        [d_tx,~]=mfiltu(s_nl,s_nl,1);
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
if(nargout>=5)
    varargout{5}=flims;
end
end
%------------- END OF CODE --------------