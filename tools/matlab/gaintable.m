
addpath 'USCRepos\uhd\tools\matlab'
sharedir = 'C:\Users\prager\VirtualBox VMs\share_folder';

fs = 5e7;

fmin = 0e9; fmax = 4e9;

dfc = 45e6; Bs = 45e6;
er = 1;
v = 3e8/sqrt(er);

rngint = linspace(-100,400,10000);

%extampfullsweep extamp_gainluts extamp_txagc
trialname = 'extamp_txagc2';
outdir = [sharedir,'\outputs\',trialname];
wavedir = [sharedir,'\waveforms\'];
waveform = [wavedir,'chirp50.bin'];

correct_amplitude =0;
chirp_filter=1;

trials = udar_read(outdir);
filt = file2wave(waveform);

trials = trials(([trials.freq]>=fmin)&([trials.freq]<=fmax));

zp_pre = 512;
filt = filt(zp_pre+1:end);
lb_rxAscale=[];
lb_rxBscale=[];

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
    xfft = xfft.*exp(-1i*angle(dfft));
    zfft = zfft.*exp(-1i*angle(dfft));
  
    
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

end


trials = trials(1:1:end);
[z,x,x_tx,upfac]=freqstack5(trials,48e6,5e7, ceil(numel(trials)*5e7/fs));
% [z,x,x_tx,upfac]=freqstack6(trials,dfc,Bs, ceil(numel(trials)*5e7/fs));
% [z,x,~,upfac]=freqstack_num(trials,dfc,Bs, ceil(numel(trials)*5e7/fs));

figure;
plotanalysis(z,[],'freq','zero','db','z spectrum');
%figure;  hold on;
figure;
plotanalysis(x,[],'freq','zero','db','x spectrum');

if(chirp_filter)
zfft = fft(z);
xfft = fft(x);
x_txfft = fft(x_tx);
H = (x_txfft./xfft);
H(~isfinite(H))=1;
% Hz = (x_txfft./zfft);
% Hz(~isfinite(Hz))=1;
zfft = zfft.*Hz;
xfft = xfft.*H;
x = ifft(xfft);
z = ifft(zfft);
figure;
plotanalysis(x_tx,[],'freq','zero','db','x_tx spectrum');

figure;
plotanalysis(z,[],'freq','zero','db','z spectrum - chirp filter');
%figure;  hold on;
figure;
plotanalysis(x,[],'freq','zero','db','x spectrum - chirp filter');

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
cplot(imrng,imdata); grid on; axis tight;
xlabel('Range(m)'); ylabel('dB'); title(trialstr);

figure(100); hold on;
[~,~,~,lstrs] = legend();
if (numel(lstrs)>0)
    legstr = {lstrs{:},[sprintf('Test %i: ',numel(lstrs)+1),trialstr]};
else
    legstr = {['Test 1: ',trialstr]};
    scale = max(imdata);
end

shift = scale-max(imdata);
imdata = imdata+shift;

cplot(imrng,imdata); grid on; axis tight;
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
