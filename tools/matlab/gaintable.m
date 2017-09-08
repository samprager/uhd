
addpath '~/Ettus/uhd/tools/matlab';

fs = 5e7;

fmin = 1e9; fmax = 4e9;

dfc = 45e6; Bs = 45e6;
er = 1;
v = 3e8/sqrt(er);

rngint = linspace(-100,400,10000);

%extampfullsweep extamp_gainluts extamp_txagc
%extamp_txgains_min26_ant_limited_gain40 extamp_txgains_min26_ant_default
trialname = 'extamp_txgains_min26_ant_default';
outdir = ['../outputs/',trialname];
wavedir = ['../waveforms/'];
waveform = [wavedir,'chirp50.bin'];

% ### Apply Amplitude Correction to each pulse individually ###
correct_amplitude =0;
% ### Apply H : wideband-chirp inversion filter calculated from ref  ###
chirp_filter=0;
% ### Set Hz : wideband-chirp inversion filter calculated from loopback data  ###
is_ref_filt = 0;
% ### Apply ref filter H or apply previously calculated Hz
use_ref_as_filt = 0;

trials = udar_read(outdir);

filt = file2wave(waveform);

trials = trials(([trials.freq]>=fmin)&([trials.freq]<=fmax));


zp_pre = 512;
filt = filt(zp_pre+1:end);
lb_rxAscale=[];
lb_rxBscale=[];

reftrials = trials;

for i=1:numel(trials)
    refscale = double(intmax('int16'))/max([max(real(trials(i).ref)),max(imag(trials(i).ref))]);
    refscale = 1;
    trials(i).data = refscale*trials(i).data(zp_pre+1:end);
    trials(i).ref = refscale*trials(i).ref(zp_pre+1:end);
    
    trials(i).awglen = trials(i).awglen-zp_pre;
    
    % Correct Phase
    [d,l]=xcorr(trials(i).ref,filt);
    len = 2*numel(trials(i).ref);
    dfft = fftshift(fft(ifftshift(d),len));
    xfft = fftshift(fft(trials(i).ref,len));
    zfft = fftshift(fft(trials(i).data,len));
    
%     xfft = xfft.*exp(-1i*angle(dfft));
%     zfft = zfft.*exp(-1i*angle(dfft));
  
    
    % Correct Amplitude
    filtfft = fftshift(fft(filt,len));
    ind = find(abs(filtfft)>0);
    mscale = ones(size(xfft));
    mscale(ind)=abs(filtfft(ind))./abs(xfft(ind));
        
    dscale = ones(size(zfft));
    dscale(ind)=abs(filtfft(ind))./abs(zfft(ind));
        
    lb_rxAscale = [lb_rxAscale;dscale];
    lb_rxBscale = [lb_rxBscale;mscale];
    
    if (correct_amplitude)       
        xfft = xfft.*mscale;
        zfft = zfft.*mscale;%lb_rxAscale(i,:);
    end

    xfft = ifft(ifftshift(xfft));
    zfft = ifft(ifftshift(zfft));
    
    trials(i).ref = xfft(1:numel(trials(i).ref));
    trials(i).data = zfft(1:numel(trials(i).data));
    
    filtmp=[filt,zeros(1,numel(trials(i).ref)-numel(filt))];
%     trials(i).ref = filtmp;

    reftrials(i).data = trials(i).ref;
    reftrials(i).ref = trials(i).ref;
    reftrials(i).awglen = trials(i).awglen;

end

trials = trials(1:1:end);

upfac = ceil(numel(trials)*5e7/fs);
%%
[z,x,x_tx,upfac]=freqstack5(trials,48e6,5e7, upfac);

% [z,x,x_tx,upfac]=freqstack6(trials,dfc,Bs, ceil(numel(trials)*5e7/fs));
% [z,x,~,upfac]=freqstack_num(trials,dfc,Bs, ceil(numel(trials)*5e7/fs));

figure;
obw(z,fs*upfac); title('z spectrum');
figure;
obw(x,fs*upfac); title('x spectrum');
 
if(chirp_filter)
zfft = fft(z);
xfft = fft(x);
x_txfft = fft(x_tx);
H = (x_txfft./xfft);
H(~isfinite(H))=1;
if (is_ref_filt)
    Hz = (x_txfft./zfft);
    Hz(~isfinite(Hz))=1;
end
if (use_ref_as_filt)
    zfft = zfft.*Hz;
else
    zfft = zfft.*H;
end
xfft = xfft.*H;
x = ifft(xfft);
z = ifft(zfft);
figure;
obw(x_tx,fs*upfac); title('x_tx spectrum');
figure;
obw(z,fs*upfac); title('z spectrum - chirp corrected');
figure;
obw(x,fs*upfac); title('x spectrum - chirp corrected');

end


[wxz,lxz]=xcorr(z,x);
figure; 
subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(wxz))))); title('mag fft xcorr');
subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(wxz)))))); title('phase fft xcorr');

rng = (lxz/(fs*upfac))*v/2;
[~,imin]=min(abs(rng-rngint(1)));
[~,imax]=min(abs(rng-rngint(end)));
imrng = rng(imin:imax);
imdata = db(abs(wxz(imin:imax)),'power');

trialstr = strrep(trialname,'_',' ');
if (correct_amplitude)
    trialstr = [trialstr, ' - amplitude corrected'];
end
if (chirp_filter)
    trialstr = [trialstr, ' - chirp filter'];
end

figure;
plot(imrng,imdata); grid on; axis tight;
xlabel('Range(m)'); ylabel('dB'); title(trialstr);

figure(100); hold on;
if verLessThan('matlab','8.4') % 2014a and earlier
    [~,~,~,lstrs] = legend();
else
    LEGH = legend;
    if (numel(LEGH)>0)
        lstrs = LEGH.String;
    else
        lstrs = {};
    end
end

if (numel(lstrs)>0)
    legstr = {lstrs{:},[sprintf('Test %i: ',numel(lstrs)+1),trialstr]};
else
    legstr = {['Test 1: ',trialstr]};
    scale = max(imdata);
end

ashift = scale-max(imdata);
imdata = imdata+ashift;

plot(imrng,imdata); grid on; axis tight;
xlabel('Range(m)'); ylabel('dB');
legend(legstr); title(sprintf('Stacked Frequencies: %g-%g mhz',fmin/1e6,fmax/1e6));

%%
% ### Apply H : wideband-chirp inversion filter calculated from ref  ###
chirp_filter_sc=0;
% ### Set Hz : wideband-chirp inversion filter calculated from loopback data  ###
is_ref_filt_sc = 0;
% ### Apply ref filter H or apply previously calculated Hz
use_ref_as_filt_sc = 1;
% ### Apply Ideal Chirp Filter
ideal_filter_sc = 1;

[d_sc,l_sc,d_sc_tx,upfac_sc]=freqstack_compress(trials,48e6,50e6, upfac);

[dref_sc,lref_sc,dref_sc_tx,upfacref_sc]=freqstack_compress(reftrials,48e6,50e6, upfac);


figure;
subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc))))); title('mag fft xcorr');
subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('phase fft xcorr');

figure;
subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc_tx))))); title('ideal mag fft xcorr');
subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc_tx)))))); title('ideal phase fft xcorr');

if(chirp_filter_sc)
    dfft = fft(d_sc);
    if (is_ref_filt_sc)
        Gz = (fft(d_sc_tx)./dfft);
        Gz(~isfinite(Gz))=1;
    end
    if (use_ref_as_filt_sc)
        dfft = dfft.*Gz;
    end
    d_sc = ifft(dfft);
    figure;
    subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc))))); title('d_sc corrected - mag fft xcorr');
    subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('d_sc corrected - phase fft xcorr');
elseif(ideal_filter_sc)
    dfft = fft(d_sc);
    H = fft(dref_sc_tx)./fft(dref_sc);
    % divide by DC gain for unitary filter gain
    H = H./abs(H(1));
    dfft = dfft.*H;
    d_sc = ifft(dfft);
    figure;
    subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc))))); title('d_sc ideal filt corrected - mag fft xcorr');
    subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('d_sc ideal filt corrected - phase fft xcorr');
end

figure; hold on;
plot(l_sc,20*log10(abs(d_sc)));
plot(l_sc,20*log10(abs(d_sc_tx)));
figure; hold on;
plot(interp(l_sc,10),20*log10(abs(interp(d_sc,10))));
plot(interp(l_sc,10),20*log10(abs(interp(d_sc_tx,10))));

rng = (l_sc/(fs*upfac))*v/2;
[~,imin]=min(abs(rng-rngint(1)));
[~,imax]=min(abs(rng-rngint(end)));
imrng = rng(imin:imax);
imdata = db(abs(d_sc(imin:imax)),'power');

trialstr = strrep(trialname,'_',' ');
trialstr = [trialstr,' - freqstack compress'];

figure;
plot(imrng,imdata); grid on; axis tight;
xlabel('Range(m)'); ylabel('dB'); title(trialstr);

figure(100); hold on;
if verLessThan('matlab','8.4') % 2014a and earlier
    [~,~,~,lstrs] = legend();
else
    LEGH = legend;
    if (numel(LEGH)>0)
        lstrs = LEGH.String;
    else
        lstrs = {};
    end
end

if (numel(lstrs)>0)
    legstr = {lstrs{:},[sprintf('Test %i: ',numel(lstrs)+1),trialstr]};
else
    legstr = {['Test 1: ',trialstr]};
    scale = max(imdata);
end

ashift = scale-max(imdata);
imdata = imdata+ashift;

plot(imrng,imdata); grid on; axis tight;
xlabel('Range(m)'); ylabel('dB');
legend(legstr); title(sprintf('Stacked Frequencies: %g-%g mhz',fmin/1e6,fmax/1e6));
%%
rxAs = lb_rxAscale.';
rxAs = rxAs(:).';
rxBs = lb_rxBscale.';
rxBs = rxBs(:).';
rxAsT = 10*log10(mean(lb_rxAscale,2))+35;
rxBsT = 10*log10(mean(lb_rxBscale,2))+35;
f = [trials.freq];
rxBsT = rxBsT;
rxAsT = rxAsT;

figure; hold on; 
cplot(f,rxAsT);cplot(f,rxBsT);

f1 = [f(1):1e6:f(end)];
z = interp1(f,rxBsT,f1);
z = conv([z(1)*ones(1,10),z,z(end)*ones(1,10)],ones(1,10)/10,'same');
z = z(11:end-10);
cplot(f1,z);

%%
fid = fopen('txgains.lut','w');
fprintf(fid,'%12s %12s\r\n','freq','gain');
fprintf(fid,'%12.2f %12.2f\r\n',[f1;z]);
fclose(fid);

%%
fid = fopen('extampgainlookup.txt','r');
H = fscanf(fid,'%s %s',[1 2]);
A = fscanf(fid,'%f %f',[2 Inf]);
fclose(fid);
figure; cplot(A(1,:),A(2,:));
