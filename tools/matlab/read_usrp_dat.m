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
%%
%addpath '/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GPR/Software/matlab'
%file = '/Users/sam/Ettus/uhd/host/outputs/usrp_samples.dat';o\
%file = '/Users/sam/Projects/Cpp/complex_test/out.dat';
% tests = {'fpf1','fpf2_yellowline','fpf3_whitecorner','fpf4_centerline','fpf5_yellowarc','fpf_sky'}; 
%tests = {'zchu_1m','zchu_2m','zchu_3m'}; 
tests = {'p-1','p-2','p-3','p-4','p-6','p-10'}; 
logscale = 1;
h1 = figure;
h2 = figure;
% waveform = {'waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham'};
waveform = {'waveform_data_p_ham'};
for j=1:numel(tests)
% file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/x300_samples_',tests{j},'.dat'];
file = ['/Users/sam/outputs/x300_samples_',tests{j},'.dat'];

[I,Q] = file2waveform(['/Users/sam/outputs/',waveform{1},'.bin']);
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
    mfilt = ifft(mfilt,len/4);
    
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
end
figure(h1); legend(tests); title('acorr');
figure(h2); legend(tests); title('fft acorr');


