addpath '/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GPR/Software/matlab'
%file = '/Users/sam/Ettus/uhd/host/outputs/usrp_samples.dat';
%file = '/Users/sam/Projects/Cpp/complex_test/out.dat';
tests = {'box11','box10','box9','box8','box7','box6','box5'}; 
logscale = 1;
use_win = 'blackman';
h1 = figure;
for j=1:numel(tests)
file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/usrp_x300_samples_lin_',tests{j},'.dat'];
[datai,dataq] = readComplexData(file,'int16');

dataiq = datai - 1i*dataq;

n = 4096-512; fs = 2e8; c = 3e8;
f0 = 10e6; f1 = 90e6; f_ricker =122e6;
t = linspace(0,n/fs,n);
win_types = {'','hamming','blackman','blackman-harris'};
win = [ones(1,n); getHamming(n)'; getBlackman(n)';getBlackmanHarris(n)'];
h2 = figure;
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
    rng = lag*(c/(2*fs))-113;
    x1 = floor(numel(acor)/2)+130; x2 = x1+60;
   % x1 = 1; x2 = numel(rng);
    
    if(logscale)
        figure(h2); hold on; plot(rng(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;
    else 
        figure(h2); hold on; plot(rng(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;
    end
    
    if(strcmp(win_types{i},use_win))
        if(logscale)
            if(strcmp(tests{j},'box5'))
            figure(h1); hold on; plot(rng(x1:x2),20*log10(abs(acor(x1:x2)))-27); hold off; axis tight;  grid on;
            else
            figure(h1); hold on; plot(rng(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;
            end
        else 
            if(strcmp(tests{j},'box5'))
            figure(h1); hold on; plot(rng(x1:x2),abs(acor(x1:x2))/(10^(27/20))); hold off; axis tight; grid on;
            else
            figure(h1); hold on; plot(rng(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;
            end
        end
    end
end
figure(h2); legend(win_types); title(tests{j});
end
figure(h1); legend({'distance 1','distance 2','distance 3','distance 4','distance 5','distance 6','distance 7'}); 
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
tests = {'fpf1','fpf2_yellowline','fpf3_whitecorner','fpf4_centerline','fpf5_yellowarc','fpf_sky'}; 
%tests = {'zchu_1m','zchu_2m','zchu_3m'}; 
logscale = 1;
h1 = figure;
h2 = figure;
% waveform = {'waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham','waveform_data_fpf_ham'};
waveform = {'waveform_data_fpf_ham'};
for j=1:numel(tests)
file = ['/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/outputs/usrp_x300_samples_',tests{j},'.dat'];
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
    
    rng = lag*(c/(2*fs));
   % x1 = floor(numel(acor)/2)+100; x2 = x1+600;
    x1 = 1; x2 = numel(rng);
    
    if(logscale)
        figure(h1); hold on; plot(rng(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight;
        figure(h2); hold on; plot(20*log10(abs(mfilt))); hold off; axis tight;

    else 
        figure(h1); hold on; plot(rng(x1:x2),abs(acor(x1:x2))); hold off; axis tight;
        figure(h2); hold on; plot(abs(mfilt)); hold off; axis tight;

    end
end
figure(h1); legend(tests); title('acorr');
figure(h2); legend(tests); title('fft acorr');


