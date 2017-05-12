% Test 1
addpath '/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GPR/Software/matlab'
%file = '/Users/sam/Ettus/uhd/host/outputs/usrp_samples.dat';
%file = '/Users/sam/Projects/Cpp/complex_test/out.dat';
tests = {'box11','box10','box9','box8','box7','box6','box5'}; 
logscale = 1;
use_win = 'Hamming';
h1 = figure;
legend_names = {'distance 1','distance 2','distance 3','distance 4','distance 5','distance 6','distance 7'};
% d = fdesign.lowpass('Fp,Fst,Ap,Ast',0.4,0.5,1,60);
% Hd = design(d,'equiripple');
% fvtool(Hd)

for j=1:numel(tests)
file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/usrp_x300_samples_lin_',tests{j},'.dat'];
[datai,dataq] = readComplexData(file,'int16');

dataiq = datai - 1i*dataq;

n = 4096-512; fs = 2e8; c = 3e8;
f0 = 10e6; f1 = 90e6; f_ricker =122e6;
t = linspace(0,n/fs,n);
%win_types = {'','hamming','blackman','blackman-harris'};
%win = [ones(1,n); getHamming(n)'; getBlackman(n)';getBlackmanHarris(n)'];
win_types = {use_win};
win = [getHamming(n)'];

% h2 = figure;
h3 = figure;
for i= 1:size(win,1)

    I_lin =chirp(t,f0,t(end),f1,'linear').*win(i,:);
    Q_lin =chirp(t,f0,t(end),f1,'linear',90).*win(i,:);

    filtiq = I_lin - 1i*Q_lin;
%    dataiq = [zeros(1,600),filtiq] + [zeros(1,598),filtiq,zeros(1,2)];
%    dataiq = [zeros(1,600),chirp(t,f0,t(end),f1,'linear')-1i*chirp(t,f0,t(end),f1,'linear',90)];

    if (n < numel(dataiq))
        filtiq = [filtiq,zeros(1,numel(dataiq)-n)];
    end

    [acor,lag] = xcorr(dataiq,filtiq);
    start = floor(numel(acor)/2)+1;
    acor = acor(start:end);
    lag = lag(start:end);
    range = lag*(c/(2*fs))-113;
%     x1 = floor(numel(acor)/2)+130; x2 = x1+60;
    x1 = 100; x2 = 300;
    
    acor_filt = fft(dataiq).*conj(fft(filtiq));
    acor_filt(ceil(end/2):end) = 0;
    acor_filt = abs(ifft(acor_filt));
    
    if(strcmp(tests{j},'box5'))
        acor = acor/(10^(27/20));
        acor_filt = acor_filt/(10^(27/20));
    end
   
   % Constant false alaram rate threshold
    windowSize = 100;
    cfar_const = 4;
    IQ_cfar_thresh = cfar_const*cfar(acor_filt,windowSize,'caso');
    
    IQ_cfar = abs(acor_filt);
    IQ_cfar(IQ_cfar<IQ_cfar_thresh) = 0;
    [IQ_cfar_val, IQ_cfar_ind] = findpeaks(IQ_cfar);
%     IQ_cfar_rng = (IQ_cfar_ind+lag(1)-1)*(c/(2*fs))-113;
    [p, ind] = sort(IQ_cfar_val,'descend');
    m = IQ_cfar_ind(ind(1:min(20,end)));
    cut = 100;
    maxinds = m(((range(m)>=(range(m(1))))&(range(m)<=(range(m(1))+cut))));
    %IQ_cfar_rng = (maxinds+lag(1)-1)*(c/(2*fs))-113;
    IQ_cfar_rng = range(maxinds);
    IQ_cfar_val = IQ_cfar(maxinds);
    
    detection_rng = IQ_cfar_rng(min(2,end));
    detection_val = IQ_cfar_val(min(2,end));
    
       % Constant false alaram rate threshold
    if(numel(maxinds)>=3)
        IQ_cfar2 = abs(acor_filt(maxinds(2):maxinds(2)+cut));

        windowSize = 20;
        cfar_const = 1.5;
        IQ_cfar_thresh2 = cfar_const*cfar(IQ_cfar2,windowSize);

%         figure; hold on; plot(20*log10(IQ_cfar_thresh2)); plot(20*log10(IQ_cfar2)); legend('thresh','data');title('iq cfar2');

        IQ_cfar2(IQ_cfar2<IQ_cfar_thresh2) = 0;
        [IQ_cfar_val2, IQ_cfar_ind2] = findpeaks(IQ_cfar2);
    %     IQ_cfar_rng = (IQ_cfar_ind+lag(1)-1)*(c/(2*fs))-113;
        [p, ind] = sort(IQ_cfar_val2,'descend');
        m = IQ_cfar_ind2(ind(1:min(20,end)));
        maxinds2 = m;
        %IQ_cfar_rng = (maxinds+lag(1)-1)*(c/(2*fs))-113;
        matching = ismember(maxinds2+maxinds(2)-1,maxinds);
        IQ_cfar_rng2 = range(maxinds2+maxinds(2)-1);
        IQ_cfar_val2 = IQ_cfar2(maxinds2);
        if(sum(matching)==0)
            detection_rng2 = IQ_cfar_rng(min(2,end));
            detection_val2 = IQ_cfar_val(min(2,end));
        else
            detection_rng2 = IQ_cfar_rng2(min(1,end));
            detection_val2 = IQ_cfar_val2(min(1,end));
        end
    else
            IQ_cfar_rng2 = [];
            IQ_cfar_val2 = [];
    
            detection_rng2 = IQ_cfar_rng(min(2,end));
            detection_val2 = IQ_cfar_val(min(2,end));
    end
    
%     figure; area(range(x1:x2),20*log10(abs(acor_filt(x1:x2)))-40); 
    
%     if(logscale)
%         figure(h2); hold on; plot(range(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;     
%     else 
%         figure(h2); hold on; plot(range(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;
%     end
    
    if(strcmp(win_types{i},use_win))
        if(logscale)
            figure(h1); hold on; plot(range(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;
            figure(h3); hold on;
            plot(range(x1:x2),20*log10(abs(acor_filt(x1:x2)))); 
            plot(range(x1:x2),20*log10(abs(IQ_cfar_thresh(x1:x2))));
            scatter(detection_rng,20*log10(detection_val),100,'MarkerEdgeColor','cyan');
            scatter(detection_rng2,20*log10(detection_val2),250,'MarkerEdgeColor','magenta','LineWidth',1.5);
            scatter(IQ_cfar_rng,20*log10(IQ_cfar_val),'MarkerEdgeColor',[0 .5 .7]); 
            scatter(IQ_cfar_rng2,20*log10(IQ_cfar_val2),'MarkerEdgeColor',[0 .5 .7]); 
            hold off; axis tight; grid on;

        else 
            figure(h1); hold on; plot(range(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;
            figure(h3); hold on;
            plot(range(x1:x2),(abs(acor_filt(x1:x2)))); 
            plot(range(x1:x2),(abs(IQ_cfar_thresh(x1:x2))));
            scatter(detection_rng,detection_val,100,'MarkerEdgeColor','cyan');
            scatter(detection_rng2,(detection_val2),250,'MarkerEdgeColor','magenta','LineWidth',1.5);
            scatter(IQ_cfar_rng,IQ_cfar_val); 
            scatter(IQ_cfar_rng2,(IQ_cfar_val2));             
            hold off; axis tight; grid on;
        end
    end
end
% figure(h2); legend(win_types); title(tests{j});
figure(h3); legend({'Acorr','Threshold','Initial Guess','Final Detection','candidates'}); 
title([legend_names{j},' Detection (',use_win,' Window)']);
end
figure(h1); legend(legend_names); 
xlabel('Range(m)'); ylabel('Detection Strength[dB]');
title('Range Measurements: Building with Metal Wall');

% figure;
% subplot(2,1,1);hold on; plot(datai); plot(dataq); axis tight;
% subplot(2,1,2);hold on; plot(I_lin); plot(Q_lin); axis tight;
% 
% figure;
% subplot(2,2,1); obw(datai,fs);
% subplot(2,2,2); obw(dataq,fs);
% subplot(2,2,3); obw(I_lin,fs);
% subplot(2,2,4); obw(Q_lin,fs);

% figure;
% subplot(2,1,1); obw(dataiq,fs);
% subplot(2,1,2); obw(filtiq,fs);
% axis tight;
%% Test 2
%addpath '/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GPR/Software/matlab'
%file = '/Users/sam/Ettus/uhd/host/outputs/usrp_samples.dat';o\
%file = '/Users/sam/Projects/Cpp/complex_test/out.dat';
% tests = {'fpf1','fpf2_yellowline','fpf3_whitecorner','fpf4_centerline','fpf5_yellowarc','fpf_sky'}; 
%tests = {'zchu_1m','zchu_2m','zchu_3m'}; 
%tests = {'p-1','p-2','p-3','p-4','p-6','p-10'}; 
tests = {'test_lin_chirp/x300_samples_none_door_open-20170112T120706.750589','test_lin_chirp/x300_samples_none_door_open-20170112T120652.493730',...
'test_lin_chirp/x300_samples_none_door_closed-20170112T120839.086119-1','test_lin_chirp/x300_samples_plate_door_closed-20170112T121816.735924-1'}; 
%tests = {'test_lin_chirp/x300_samples_none_door_closed-20170112T120839.086119-1','test_lin_chirp/x300_samples_plate_door_closed-20170112T121816.735924-1'}; 
%tests = {'test_fpf/x300_samples_none_door_closed-20170112T121132.004046-1','test_fpf/x300_samples_plate_door_closed-20170112T122012.703511-1'}; 
%tests = {'test_prn/test_prnx300_samples_none_door_closed-20170112T121115.000955-1','test_prn/test_prnx300_samples_plate_door_closed-20170112T121757.262891-1'}; 
%tests = {'test_gaus/x300_samples_none_door_closed-20170112T121231.987587-1','test_gaus/x300_samples_plate_door_closed-20170112T121730.675642-1'};
%tests = {'test_zchu/x300_samples_none_door_closed-20170112T121156.002053-1','test_zchu/x300_samples_plate_door_closed-20170112T121924.638855-1'};
logscale = 1;
h1 = figure;
h2 = figure;
%h3 = figure;
% waveform = {'waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham'};
waveform = {'waveform_data_lin'};
for j=1:numel(tests)
% file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/x300_samples_',tests{j},'.dat'];
file = ['/Users/sam/outputs/',tests{j},'.dat'];

[I,Q] = file2wave(['/Users/sam/outputs/',waveform{1},'.bin']);
[datai,dataq] = readComplexData(file,'int16');

dataiq = datai - 1i*dataq;

n = 4096-512; fs = 2e8; c = 3e8;
f0 = 10e6; f1 = 90e6;


    filtiq = I - 1i*Q;
%    dataiq = [zeros(1,600),filtiq] + [zeros(1,598),filtiq,zeros(1,2)];
%    dataiq = [zeros(1,600),chirp(t,f0,t(end),f1,'linear')-1i*chirp(t,f0,t(end),f1,'linear',90)];

    if (n < numel(dataiq))
        filtiq = [filtiq,zeros(1,numel(dataiq)-n)];
    end

    [acor,lag] = xcorr(dataiq,filtiq);
    
    len = 4096;
    mfilt = conj(fft(filtiq,len));
    mfilt = mfilt.*(fft(dataiq,len));
    mfilt = ifft(mfilt,len);
    
    range = lag*(c/(2*fs));
   % x1 = floor(numel(acor)/2)+100; x2 = x1+600;
    x1 = 1; x2 = numel(range);
    
    if(logscale)
        figure(h1); hold on; plot(range(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight;
        figure(h2); hold on; plot(20*log10(abs(mfilt))); hold off; axis tight;

    else 
        figure(h1); hold on; plot(range(x1:x2),abs(acor(x1:x2))); hold off; axis tight;
        figure(h2); hold on; plot(abs(mfilt)); hold off; axis tight;

    end
    %figure(h3); hold on; plot(dataq); hold off; axis tight;
end
figure(h1); legend(tests); title('acorr'); grid on;
figure(h2); legend(tests); title('fft acorr'); grid on;
%figure(h3); legend(tests); title('Q sig'); grid on;

%% Test 3
% note: waveform: f0 = 1mhz, f1 = 80mhz
tests = {'plate1/x300_samples_1000-20170127T143929.121448-1','plate2/x300_samples_1000-20170127T151323.777079-1','plate3/x300_samples_1000-20170127T152140.507201-1','plate4/x300_samples_1000-20170127T153132.517271-1'}; 
%tests = {'plate1/x300_samples_1000-20170127T144156.571185-1','plate2/x300_samples_1000-20170127T151348.117331-1','plate3/x300_samples_1000-20170127T152220.690657-1','plate4/x300_samples_1000-20170127T153220.549765-1'}; 
logscale = 1;
h1 = figure;
h2 = figure;
%h3 = figure;
% waveform = {'waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham'};
waveform = {'waveform_data_lin_ham'};
for j=1:numel(tests)
% file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/x300_samples_',tests{j},'.dat'];
file = ['/Users/sam/outputs/test2/lin_chirp/',tests{j},'.dat'];

[I,Q] = file2wave(['/Users/sam/outputs/',waveform{1},'.bin']);
[datai,dataq] = readComplexData(file,'int16');

dataiq = datai - 1i*dataq;

n = 4096-512; fs = 2e8; c = 3e8;
f0 = 10e6; f1 = 90e6;


    filtiq = I - 1i*Q;
%    dataiq = [zeros(1,600),filtiq] + [zeros(1,598),filtiq,zeros(1,2)];
%    dataiq = [zeros(1,600),chirp(t,f0,t(end),f1,'linear')-1i*chirp(t,f0,t(end),f1,'linear',90)];

    if (n < numel(dataiq))
        filtiq = [filtiq,zeros(1,numel(dataiq)-n)];
    end

    [acor,lag] = xcorr(dataiq,filtiq);
    
    len = 4096;
    mfilt = conj(fft(filtiq,len));
    mfilt = mfilt.*(fft(dataiq,len));
    mfilt = ifft(mfilt,len);
    
    range = lag*(c/(2*fs));
    x1 = floor(numel(acor)/2)+140; x2 = x1+80;
    %x1 = 1; x2 = numel(range);
    
    if(logscale)
        figure(h1); hold on; plot(range(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight;
        figure(h2); hold on; plot(20*log10(abs(mfilt))); hold off; axis tight;

    else 
        figure(h1); hold on; plot(range(x1:x2),abs(acor(x1:x2))); hold off; axis tight;
        figure(h2); hold on; plot(abs(mfilt)); hold off; axis tight;

    end
    %figure(h3); hold on; plot(dataq); hold off; axis tight;
end
legend_str = {'position 1: + 0.0 ft','position 2: + 1.0 ft','position 3: + 2.0 ft','position 4: + 3.0 ft'};
figure(h1); legend(legend_str); title('Echoes (autocorrelation)'); ylabel('Relative Power [dB]'); xlabel('Range (m)'); grid on;
figure(h2); legend(legend_str); title('fft acorr'); grid on;
%figure(h3); legend(tests); title('Q sig'); grid on;

%% Test 4: Soil Box
% note: waveform: f0 = 1mhz, f1 = 76mhz
er = 12;
tx_wf = 'lin';
freq = '300mhz-1';
tests = {['d1_nospade/x300_samples_',freq],['d2/x300_samples_',freq],['d3/x300_samples_',freq]}; 
%tests = {'plate1/x300_samples_1000-20170127T144156.571185-1','plate2/x300_samples_1000-20170127T151348.117331-1','plate3/x300_samples_1000-20170127T152220.690657-1','plate4/x300_samples_1000-20170127T153220.549765-1'}; 
offsets = [0,0,0];
logscale = 1;
h1 = figure;
h2 = figure;
%h3 = figure;
% waveform = {'waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham'};
waveform = {'waveform_data_lin_ham'};
[I,Q] = file2wave(['/Users/sam/outputs/',waveform{1},'.bin']);
filtiq = I + 1i*Q;
b = fir1(64,[.2 0.8]);
%filtiq = filter(b,1,filtiq);

figure; obw(filtiq,2e8);
for j=1:numel(tests)
% file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/x300_samples_',tests{j},'.dat'];
file = ['/Users/sam/outputs/test_soil/',tx_wf,'/',tests{j},'.dat'];
[datai,dataq] = readComplexData(file,'int16');

dataiq = datai + 1i*dataq;
%dataiq = filter(b,1,dataiq);
n = 4096-512; fs = 2e8; c = 3e8;
f0 = 10e6; f1 = 90e6;

    if (numel(filtiq) < numel(dataiq))
        filtiq = [filtiq,zeros(1,numel(dataiq)-numel(filtiq))];
    end

    [acor,lag] = xcorr(dataiq,filtiq);
    
    len = 4096;
    mfilt = conj(fft(filtiq,len));
    mfilt = mfilt.*(fft(dataiq,len));
    mfilt = ifft(mfilt,len/2);
    
    range = lag*(c/(2*fs*sqrt(er)))-35;
    x1 = floor(numel(acor)/2)+140; x2 = x1+80;
    %x1 = 1; x2 = numel(range);
    
    if(logscale)
        figure(h1); hold on; plot(range(x1:x2),20*log10(abs(acor(x1:x2)))+offsets(j)); hold off; axis tight;
        figure(h2); hold on; plot(20*log10(abs(mfilt))+offsets(j)); hold off; axis tight;

    else 
        figure(h1); hold on; plot(range(x1:x2),abs(acor(x1:x2))); hold off; axis tight;
        figure(h2); hold on; plot(abs(mfilt)); hold off; axis tight;

    end
    %figure(h3); hold on; plot(dataq); hold off; axis tight;
    detections = peak_detect(filtiq,dataiq,fs,er,tests{j},1);
end
legend_str = {'position 1','position 2','position 3'};
figure(h1); legend(legend_str); title('Echoes (autocorrelation)'); ylabel('Relative Power [dB]'); xlabel('Range (m)'); grid on;
figure(h2); legend(legend_str); title('fft acorr'); grid on;
%figure(h3); legend(tests); title('Q sig'); grid on;

%% 
fs = 2e8; er = 12; c = 3e8;
s1 = [conj(file2wave('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_250mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d2/x300_samples_250mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d3/x300_samples_250mhz-1.dat'))];
s2 = [conj(file2wave('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_300mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d2/x300_samples_300mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d3/x300_samples_300mhz-1.dat'))];
s3 = [conj(file2wave('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_400mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d2/x300_samples_400mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d3/x300_samples_400mhz-1.dat'))];
s4 = [conj(file2wave('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_500mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d2/x300_samples_500mhz-1.dat'));
    conj(file2wave('/Users/sam/outputs/test_soil/lin/d3/x300_samples_500mhz-1.dat'))];
%s3 = conj(file2wave('/Users/sam/outputs/test_soil/lin/d3/x300_samples_400mhz-1.dat'));

tests = {'d1','d2','d3'};

fs2 = fs*4; fc = 75e6;
t_u = linspace(0,4*size(s1,2)/fs2,4*size(s1,2));

h1 = file2wave('/Users/sam/outputs/waveform_data_lin.bin');
if (numel(h1) < size(s1,2))
    h1 = [h1,zeros(1,size(s1,2)-numel(h1))];
end
% h_u = interp(h1,4)+interp(h1,4).*exp(1i*2*pi*fc*t_u)+interp(h1,4).*exp(1i*4*pi*fc*t_u);
h_u = [interp(h1,4),interp(h1,4).*exp(1i*2*pi*fc*t_u),interp(h1,4).*exp(1i*4*pi*fc*t_u)];%,interp(h1,4).*exp(1i*6*pi*fc*t_u)];

%figure; obw(h_u,fs2);

w_u = zeros(size(h_u));
win_len = numel(h_u)/4+1024+6*512;
w_u(1:win_len) = chebwin(win_len)';
% figure; plot(abs(fft(h_u))); 
% figure; plot(w_u);
h_u = ifft(w_u.*fft(h_u));
figure; obw(h_u,fs2);

f1 = figure;
f2 = figure;

for i=1:size(s1,1)
%     s_u = interp(s1(i,:),4)+interp(s2(i,:),4).*exp(1i*2*pi*fc*t_u)+interp(s3(i,:),4).*exp(1i*4*pi*fc*t_u);
     s_u = [interp(s1(i,:),4),interp(s2(i,:),4).*exp(1i*2*pi*fc*t_u),interp(s3(i,:),4).*exp(1i*4*pi*fc*t_u)];%,interp(s4(i,:),4).*exp(1i*6*pi*fc*t_u)];

%    s_u = ifft(w_u.*fft(s_u));
    %figure; obw(s_u,fs2);

    trim = 400;
    [s_u_xc, l] = xcorr(s_u,h_u);
    l = l-630;
    rng = find(abs(l)<=trim);
    range_u = l*(c/(2*fs2*sqrt(er)));
    
    [h_u_xc, l_h] = xcorr(h_u,h_u);
    rng_h = find(abs(l_h)<=trim);

    [s1_xc, l1] = xcorr(s1(i,:),h1);
    rng1 = find(abs(l1)<=trim);
    [s2_xc, l2] = xcorr(s2(i,:),h1);
    rng2 = find(abs(l2)<=trim);
    % [s3_xc, l3] = xcorr(s3,h1);
    % rng3 = find(abs(l3)<=trim);

    % figure; obw(s1,fs);
    % figure; obw(s2,fs);
    % figure; obw(h1,fs);
    % figure; obw(h_u,fs2);
    % figure; obw(s_u,fs2);

    figure(f1); hold on;
    plot(range_u(rng),20*log10(abs(s_u_xc(rng))));

    figure(f2); hold on;
    plot(l1(rng1),20*log10(abs(s1_xc(rng1))));
    plot(l2(rng2),20*log10(abs(s2_xc(rng2))));

    %plot(l3(rng3),20*log10(abs(s3_xc(rng3))));
    detections = peak_detect(h_u,s_u,fs2,er,tests{i},1);

end
figure(f1); axis tight; grid on; legend(tests);
title('Spectrum Stitching: Chebyshev Window');
figure;
plot(l_h(rng_h),20*log10(abs(h_u_xc(rng_h))));