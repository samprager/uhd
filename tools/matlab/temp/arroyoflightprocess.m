addpath 'USCRepos\uhd\tools\matlab'
sharedir = 'C:\Users\prager\VirtualBox VMs\share_folder';

% Create map container for all trials

testdir = [sharedir,'\outputs\arroyoflight\tworeflec\'];
tmap = udar_map(testdir);
%%
fs = 50e6; 

dfc = 48e6; Bs = 48e6;

er = 1;
v = 3e8/sqrt(er);

fmin = 0e8; fmax = 6e9;
fmins = [fmin:dfc:fmax];
fmaxs = [fmax:-dfc:fmin];

%% Plot GPS position on map
trials = tmap('buildingfar50_d48');
% trials = trials('sweep-0');
skycal = tmap('skyactive50_d48');

outdir = [sharedir,'\outputs\e312_outdoortest2\buildingclose48\'];
wavedir = [sharedir,'\waveforms\'];
waveform = [wavedir,'chirp50.bin'];

filt = file2wave(waveform);
skycal = skycal(([skycal.freq]>=fmin)&([skycal.freq]<=fmax));
trials = trials(([trials.freq]>=fmin)&([trials.freq]<=fmax));

imu = textscan([trials.imu],'(%f,%f,%f)');
imu = [imu{:}];

gpspos = reshape([trials.gps_vec],3,numel(trials))';
gpslat = gpspos(:,1); %[34.1909   34.2109];
gpslon = gpspos(:,2); %[-118.1794 -118.1594];

demFilename = 'C:\Users\prager\Downloads\1662688-pasadena\8914_75m.dem';
[lat, lon,Z, header, prof] = usgs24kdem(demFilename,2); 
% Move all points at sea level to -1 to color them blue. 
Z(Z==0) = -1;
% Compute the latitude and longitude limits for the DEM. 
latlim = [min(lat(:)) max(lat(:))];
lonlim = [min(lon(:)) max(lon(:))];

% Display the DEM values as a texture map. 
% figure; hold on;
% ax = usamap(latlim, lonlim);
% setm(ax, 'GColor','k', ...
%     'PLabelLocation',.05, 'PLineLocation',.05)
% geoshow(lat, lon, Z, 'DisplayType','texturemap');
% demcmap(Z)
% daspectm('m',1)
% geoshow(gpslat,gpslon, 'DisplayType','point', 'Color', 'r')
% title('map')


[latlim,lonlim] = geoquadline(gpslat,gpslon);
buf = .002;
[latlim,lonlim] = bufgeoquad(latlim,lonlim,buf,buf);
figure(50); hold on; 
plot(gpslon,gpslat,'+r','MarkerSize',15) 
plot(lonlim,latlim,'.k','MarkerSize',1) 
plot_google_map('MapType','hybrid');


% ### Apply Amplitude Correction to each pulse individually ###
correct_amplitude =0;
% ### Apply H : wideband-chirp inversion filter calculated from ref  ###
chirp_filter=0;
% ### Set Hz : wideband-chirp inversion filter calculated from loopback data  ###
is_ref_filt = 0;
% ### Apply ref filter H or apply previously calculated Hz
use_ref_as_filt = 0;
% #### Subtract skycal data
subskycal = 0;

rngint = linspace(-0,20,1000);
% trialnames = {'arroyotest2/arroyotest2p2_singlereflec','arroyotest2/arroyotest2p2_tworeflec1m','arroyotest2/arroyotest2p2_tworeflec_p5m','arroyotest2/arroyotest2p2_tworeflec_20cm'};

trialnames = {};
for i = 1:45
    trialnames{i} = sprintf('arroyoflight/arroyoflight2_tworeflec_tukey_p%g',i);
end

Z = [];
for tint = 1:numel(trialnames)
%extampfullsweep extamp_gainluts extamp_txagc
%extamp_txgains_min26_ant_limited_gain40 extamp_txgains_min26_ant_default
%arroyotest2p2_singlereflec arroyotest2p2_tworeflec_20cm_betterangle  arroyotest2p2_tworeflec_20cm
% trialname = trialnames{tint}
% 'arroyotest2/arroyotest2p2_singlereflec_tukey'
% trialname = 'arroyoflight/arroyoflight2_tworeflec_tukey_p1'; %'extamp_txgains_min26_shortlb_default';%
trialname = trialnames{tint}
outdir = ['../outputs/',trialname];
wavedir = ['../waveforms/'];
waveform = [wavedir,'tukey50.bin'];


trials = udar_read(outdir);

skycal = udar_read('../outputs/arroyotest2/arroyotest2p2_skycaltukey');


filt = file2wave(waveform);

trials = trials(([trials.freq]>=fmin)&([trials.freq]<=fmax));
skycal = skycal(([skycal.freq]>=fmin)&([skycal.freq]<=fmax));

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
        
    if (subskycal)
        skycal(i).data = refscale*skycal(i).data(zp_pre+1:end);
        skycal(i).ref = refscale*skycal(i).ref(zp_pre+1:end);
        skycal(i).awglen = skycal(i).awglen-zp_pre;


        % Skycal Correct Phase
        [d,l]=xcorr(skycal(i).ref,filt);
        len = 2*numel(skycal(i).ref);
        dfft = fftshift(fft(ifftshift(d),len));
        xfft = fftshift(fft(skycal(i).ref,len));
        zfft = fftshift(fft(skycal(i).data,len));

        xfft = xfft.*exp(-1i*angle(dfft));
        zfft = zfft.*exp(-1i*angle(dfft));

        xfft = ifft(ifftshift(xfft));
        zfft = ifft(ifftshift(zfft));

        skycal(i).ref = xfft(1:numel(skycal(i).ref));
        skycal(i).data = zfft(1:numel(skycal(i).data));
        
        trials(i).data = trials(i).data - skycal(i).data;
    end

    
    
    reftrials(i).data = trials(i).ref;
    reftrials(i).ref = trials(i).ref;
    reftrials(i).awglen = trials(i).awglen;

end

trials = trials(1:1:end);

upfac = ceil(numel(trials)*5e7/fs);


    
dfc = 48e6; Bs = 48e6;

% ### Apply H : wideband-chirp inversion filter calculated from ref  ###
chirp_filter_sc=0;
% ### Set Hz : wideband-chirp inversion filter calculated from loopback data  ###
is_ref_filt_sc = 0;
% ### Apply ref filter H or apply previously calculated Hz
use_ref_as_filt_sc = 0;
% ### Apply Ideal Chirp Filter
ideal_filter_sc = 1;


savefig = 1;
savestr = '';
savelegstr = {};
% savelegstr = {'before filter','after filter'};

alltrials = trials(1:end);
allrefs = reftrials(1:end);
% Z = [];
% for i=1:numel(alltrials)
%     trial = alltrials(1:i);
%     reftrial = allrefs(1:i);
    trial = alltrials(1:end);
    reftrial = allrefs(1:end);
% [d_sc,l_sc,d_sc_tx,upfac_sc]=freqstack_compress(trials);
% [dref_sc,lref_sc,dref_sc_tx,upfacref_sc]=freqstack_compress(reftrials);

[d_sc,l_sc,d_sc_tx,upfac_sc]=freqstack_compress(trial,dfc,Bs, upfac);
[dref_sc,lref_sc,dref_sc_tx,upfacref_sc]=freqstack_compress(reftrial,dfc,Bs, upfac);

% [d_sc,l_sc,d_sc_tx,upfac_sc]=freqstack_compress(trials,48e6,48e6, upfac,trials(1).fs,'rect');
% [dref_sc,lref_sc,dref_sc_tx,upfacref_sc]=freqstack_compress(reftrials,48e6,48e6, upfac,reftrials(1).fs,'rect');

% 
% figure;
% subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc))))); title('mag fft xcorr');
% subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('phase fft xcorr');
% 
% figure;
% subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc_tx))))); title('ideal mag fft xcorr');
% subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc_tx)))))); title('ideal phase fft xcorr');
figure(299);
f = linspace(-fs*upfac/2,fs*upfac/2,numel(d_sc));
plot(f/1e6,10*log10(abs(fftshift(fft(ifftshift(d_sc)))))); title('synthetic spectrum magnitude');
xlabel('freq (mhz)'); ylabel('dB');

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
%     figure;
%     subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc))))); title('d_sc corrected - mag fft xcorr');
%     subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('d_sc corrected - phase fft xcorr');
elseif(ideal_filter_sc)
    dfft = fft(d_sc);
    H = fft(dref_sc_tx)./fft(dref_sc);
    
    BWtotal = numel(trial)*dfc;
    f = linspace(-fs*upfac/2,fs*upfac/2,numel(H));
    H = H.*(ifftshift(rect(f,-BWtotal/2,BWtotal/2)));    
    % divide by DC gain for unitary filter gain
    H = H./abs(H(1));
    
    
%     H(H==0)=1;

    H(~isfinite(H))=1;
    
   % 10 point moving average
%     H=filter(.1*ones(1,10),1,H);
    
    dfft = dfft.*H;
    d_sc = ifft(dfft);
%     figure;
%     subplot(2,1,1); plot(abs(fftshift(fft(ifftshift(d_sc))))); title('d_sc ideal filt corrected - mag fft xcorr');
%     subplot(2,1,2); plot(unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('d_sc ideal filt corrected - phase fft xcorr');
end

% figure(300);
% f = linspace(-fs*upfac/2,fs*upfac/2,numel(d_sc));
% plot(f/1e6,10*log10(abs(fftshift(fft(ifftshift(d_sc)))))); title('corrected synthetic spectrum magnitude');
% xlabel('freq (mhz)'); ylabel('dB');

% figure;
% subplot(2,1,1); plot(f,10*log10(abs(fftshift(fft(ifftshift(d_sc)))))); title('reconstructed spectrum magnitude');
% subplot(2,1,2); plot(f,unwrap(angle(fftshift(fft(ifftshift(d_sc)))))); title('reconstructed spectrum phase');
%
% figure;
% subplot(2,1,1); plot(f,10*log10(abs(fftshift(fft(ifftshift(dref_sc)))))); title('ref mag fft xcorr');
% subplot(2,1,2); plot(f,unwrap(angle(fftshift(fft(ifftshift(dref_sc)))))); title('ref phase fft xcorr');


% figure; hold on;
% plot(l_sc,20*log10(abs(d_sc)));
% plot(l_sc,20*log10(abs(d_sc_tx)));
% figure; hold on;
% plot(interp(l_sc,10),20*log10(abs(interp(d_sc,10))));
% plot(interp(l_sc,10),20*log10(abs(interp(d_sc_tx,10))));


% d_sc = interp(d_sc_tx,4);
% l_sc = interp(l_sc,4);

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

if (mod(i,5)==1)
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
%imdata = imdata+ashift;

plot(imrng,imdata); grid on; axis tight;
xlabel('Range(m)'); ylabel('dB');
legend(legstr); title(sprintf('Stacked Frequencies: %g-%g mhz',fmin/1e6,fmax/1e6));
end

Z = [Z; interp1(imrng,imdata-max(abs(imdata)),rngint)];

end

if (savefig)

    figoutdir = '~/USC/MiXIL/UDAR-Papers/paper1/flight/';
    if(ideal_filter_sc)
        savestr = [savestr,'_ideal_filter'];
    end
    if(subskycal)
        savestr = [savestr,'_skycal'];
    end
    [a,b,c]=fileparts(trialnames{1});
    if (isempty(a))
        a=b;
    end
    tempstr = sprintf('_to_p%g_fmin%gmhz_fmax%gmhz_dfc%gmhz%s.png',numel(trialnames),trials(1).freq/1e6,trials(end).freq/1e6,dfc/1e6,savestr);

    
%     figure(200); hold on;
%     plot(imrng,imdata-max(abs(imdata))); grid on; axis tight;
%     % title('Compressed Pulse of Wideband Chirp vs Synthetic Frequency Stacked Chirp');
%     % legend(['\Delta f_c =', sprintf('%g mhz. B_s = %g mhz. N = %g',dfc/1e6,Bs/1e6,N)]); 
%     xlabel('Range [m]'); ylabel('Amplitude [dB]');
%     if (numel(savelegstr)>0)
%         legend(savelegstr);
%     end
%     saveas(gcf,[figoutdir,'reconstructed_',savestr,a,sprintf('_fmin%gmhz_fmax%gmhz_dfc%gmhz.png',trials(1).freq/1e6,trials(end).freq/1e6,dfc/1e6)]);

if (size(Z,1)>1)
    [X,Y] = meshgrid(rngint,[1:numel(trialnames)]*.5);
    figure; surf(X,Y,Z,'FaceColor','interp','EdgeColor','interp','FaceAlpha',.5); colormap jet;
    xlabel('range(m)'); ylabel('Cross range (m)'); view([16,45]); grid on; axis tight;
    % title(sprintf('Frequency Stacking: %g-%g mhz (1-%g sub-pules).',alltrials(1).freq/1e6,alltrials(end).freq/1e6,numel(alltrials)));
        saveas(gcf,[figoutdir,'radargram_',a,'_',b,tempstr],'png');

    figure; surf(X,Y,Z,'FaceColor','interp','EdgeColor','interp','FaceAlpha',.5); colormap jet;
    xlabel('range(m)'); ylabel('Cross range (m)'); view([0,90]); grid on; axis tight;
    % title(sprintf('Frequency Stacking: %g-%g mhz (1-%g sub-pules).',alltrials(1).freq/1e6,alltrials(end).freq/1e6,numel(alltrials)));
        saveas(gcf,[figoutdir,'radargram_flat_',a,'_',b,tempstr],'png');

    [X,Y] = meshgrid(rngint,[1:numel(trialnames)]);

    figure; surf(X,Y,Z,'FaceColor','interp','EdgeColor','interp','FaceAlpha',.5); colormap jet;
    xlabel('range(m)'); ylabel('Pulse number'); view([16,45]); grid on; axis tight;
    % title(sprintf('Frequency Stacking: %g-%g mhz (1-%g sub-pules).',alltrials(1).freq/1e6,alltrials(end).freq/1e6,numel(alltrials)));
        saveas(gcf,[figoutdir,'radargram_numY_',a,'_',b,tempstr,savestr],'png');


% figure(200); hold on;
% plot(imrng,imdata-max(abs(imdata))); axis tight; grid on;
% % title('Compressed Pulse of Wideband Chirp vs Synthetic Frequency Stacked Chirp');
% % legend(['\Delta f_c =', sprintf('%g mhz. B_s = %g mhz. N = %g',dfc/1e6,Bs/1e6,N)]); 
% xlabel('Range [m]'); ylabel('Amplitude [dB]');
% if (numel(savelegstr)>0)
%     legend(savelegstr);
% end
% [a,b,c]=fileparts(trialname);
% saveas(gcf,[figoutdir,'reconstructed_',savestr,b,sprintf('_fmin%gmhz_fmax%gmhz_dfc%gmhz.png',trials(1).freq/1e6,trials(end).freq/1e6,dfc/1e6)]);
% end



    % [X,Y] = meshgrid(rngint,([alltrials.freq]-alltrials(1).freq+5e7)/1e6);
%     [X,Y] = meshgrid(rngint,[1:numel(alltrials)]);
%     halfdbwidth = zeros(1,size(Z,1));
%     bw = dfc*Y(:,1)';
%     res = 3e8./(2*bw);
%     rng = interp(X(1,end/2-1000:end/2+1000),100);
%     for i= 1:size(Z,1)
%         z = interp(Z(i,end/2-1000:end/2+1000),100);
%         [v,ind] = max(z);
%         ir = ind;
%         vr = v;
%         rfound = 0;
%         while(~rfound)
%             ir = ir+1;
%             vr = z(ir);
%             if ((v-vr)>=10*log10(2))
%                 rfound = 1;
%             end
%         end
%         il = ind;
%         vl = v;
%         lfound = 0;
%         while(~lfound)
%             il = il-1;
%             vl = z(il);
%             if ((v-vl)>=10*log10(2))
%                 lfound = 1;
%             end
%         end
%         halfdbwidth(i) = rng(ir)-rng(il);
%     end    
% 
%     pinds = find(bw>0e9);       
%     figure;hold on; plot(bw(pinds)/1e6,res(pinds)); plot(bw(pinds)/1e6,halfdbwidth(pinds)); axis tight; grid on;
%     xlabel('Bandwidth (mHz)'); ylabel('Resolution (m)');
%     legend('Theoretical','Frequency Stacking 1/2 dB Pulse Width');
%     saveas(gcf,[figoutdir,'theoretical_vs_actual_int_',savestr,b,sprintf('_fmin%gmhz_fmax%gmhz_dfc%gmhz.png',trials(1).freq/1e6,trials(end).freq/1e6,dfc/1e6)]);

end
end




