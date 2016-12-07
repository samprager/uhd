%%
waveform = {'lin','fpf','prn'};

nvar = 3;
h1 = figure; 
h2 = figure; 
h3 = figure;
h4 = figure;
for i=1:numel(waveform)
    [I,Q] = file2waveform(['/Users/sam/outputs/waveform_data_',waveform{i},'.bin']);
%     I = I/max(abs(I));
%     Q = Q/max(abs(Q));
    filtiq = I- 1i*Q;
    dataiq = [zeros(1,20),filtiq,zeros(1,20)]; 
    dataiq = dataiq+sqrt(nvar)*randn(size(dataiq));

    [acor,lag] = xcorr(dataiq,filtiq);
    x1 = 1; x2 = numel(lag);
    figure(h1); hold on; plot(lag(x1:x2),10*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;
    %figure; hold on; plot(lag(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;

   dataiq = [zeros(1,20),filtiq,zeros(1,20)] + [zeros(1,18),filtiq,zeros(1,22)] + [zeros(1,23),filtiq,zeros(1,17)]+[zeros(1,30),filtiq,zeros(1,10)];
   dataiq = dataiq+sqrt(nvar)*randn(size(dataiq));

    [acor,lag] = xcorr(dataiq,filtiq);
    x1 = 1; x2 = numel(lag);
    figure(h2); hold on; plot(lag(x1:x2),10*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;
    %figure; hold on; plot(lag(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;
    
    len = 8192;
    mfilt = conj(fft(filtiq,len));
    mfilt = mfilt.*(fft(dataiq,len));
    mfilt_all = ifft(mfilt,len);
    mfilt_lpf = ifft(mfilt,len/2);
    figure(h3); hold on; plot(20*log10(abs(mfilt_lpf))); hold off; axis tight;
    figure(h4); hold on; plot(20*log10(abs(mfilt_all))); hold off; axis tight;
    
    %figure(h3); hold on; plot(abs(mfilt)); hold off; axis tight;
end
figure(h1); legend(waveform); title('acorr');
figure(h2); legend(waveform); title('multiple reflectors');
figure(h3); legend(waveform); title('fft with lpf');
figure(h4); legend(waveform); title('fft no lpf');
%%
n = 4096-512; fs = 2e8; c = 3e8;

[I,Q] = file2waveform('/Users/sam/outputs/waveform_data_fpf.bin');

figure; hold on; plot(I);plot(Q); legend('I','Q');
filtiq = I - 1i*Q;
dataiq = filtiq; 
[acor,lag] = xcorr(dataiq,filtiq);
x1 = 1; x2 = numel(lag);
figure; hold on; plot(lag(x1:x2),10*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;



[I1,Q1] = file2waveform('/Users/sam/outputs/waveform_data_fpf1.bin');
[I2,Q2] = file2waveform('/Users/sam/outputs/waveform_data_fpf2.bin');

filtiq = I1;
dataiq = I2;
len = 8192/2;
mfilt = conj(fft(filtiq,len));
mfilt = mfilt.*(fft(dataiq,len));
mfilt = abs(ifft(mfilt,len));
h1=figure;
h2=figure;

figure(h1); hold on; plot(20*log10(abs(real(mfilt))));
figure(h2); hold on; plot(20*log10((mfilt)));

filtiq = Q1;
dataiq = Q2;

len = 8192/2;
mfilt = conj(fft(filtiq,len));
mfilt = mfilt.*(fft(dataiq,len));
mfilt = abs(ifft(mfilt,len));
figure(h1); hold on; plot(20*log10(abs(real(mfilt)))); 
figure(h2); hold on; plot(20*log10((mfilt)));


filtiq = I1-1i*Q1;
dataiq = I2-1i*Q2;

figure; obw(filtiq);

len = 8192/2;
mfilt = conj(fft(filtiq,len));
mfilt = mfilt.*(fft(dataiq,len));
%mfilt = imag(mfilt)-1i*real(mfilt);
mfilt = (ifft(mfilt,len));
mfilt = sqrt(real(mfilt).*real(mfilt)+imag(mfilt).*imag(mfilt));
figure; hold on; plot(20*log10((mfilt)));

% figure; obw(filtiq,fs);
% mfilt = conj(fft(filtiq));
% mfilt = mfilt.*(fft(dataiq));
% mfilt = abs(ifft(mfilt(1:end/4)));
% figure; hold on; plot(20*log10(abs(mfilt)));

%%
n = 33^2;
x = polyphaseCode(n);
y = polyphaseCode(n);

h1 = figure;
h2 = figure;
b = fir1(64, 0.75);
figure; impz(b,1);
win = getHamming(n)';


fs = 2e8;

[acor,lag] = xcorr(x,y);
figure(h1); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

x_win = x.*win;
[acor,lag] = xcorr(x_win,y);
figure(h1); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

% bandlimited code
yfilt = filter(b,1,y);
figure; obw(yfilt,fs);
[acor,lag] = xcorr(x,yfilt);
figure(h2); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

% bandlimited code
y = y.*win;
yfilt = filter(b,1,y);
[acor,lag] = xcorr(x_win,yfilt);
figure(h2); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

x = frankPolyPhase(n);
y = frankPolyPhase(n);

[acor,lag] = xcorr(x,y);
figure(h1); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

x_win = x.*win;
[acor,lag] = xcorr(x_win,y);
figure(h1); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

% bandlimited code
yfilt = filter(b,1,y);
figure; obw(yfilt,fs);
[acor,lag] = xcorr(x,yfilt);
figure(h2); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

% bandlimited code
y = y.*win;
yfilt = filter(b,1,y);
[acor,lag] = xcorr(x_win,yfilt);
figure(h2); hold on; plot(lag,10*log10(abs(acor))); hold off; axis tight; grid on;

figure(h1); legend('p1','p1 win','fpf','fpf win');
figure(h2); legend('p1 filt','p1 win','fpf filt','fpf win');


