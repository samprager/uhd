rng(1);
chirp_type = 'lin';
win_types = {'_blk','_hann','_ham','_bhar',''};

fs = 200e6;
n = 4096-512;
f0 = 10e6; f1 = 90e6; f_ricker =50e6;
t = linspace(0,n/fs,n);
ti  = linspace(-n/(1*fs),n/(1*fs),n);
f = 10;

I_quad =chirp(t,f0,t(end),f1,'q',[],'convex');
Q_quad =chirp(t,f0,t(end),f1,'q',90,'convex');

I_log =chirp(t,f0,t(end),f1,'logarithmic');
Q_log =chirp(t,f0,t(end),f1,'logarithmic',90);

I_lin =chirp(t,f0,t(end),f1,'linear');
Q_lin =chirp(t,f0,t(end),f1,'linear',90);

% data_gaus = gauspuls(ti,50E6,.8);
% data_gaus = (data_gaus)/(max(abs(data_gaus)));
% IQ_gaus = hilbert(data_gaus);
%I_gaus = real(IQ_gaus); Q_gaus = -1*imag(IQ_gaus);
[I_gaus,Q_gaus] = gauspuls(ti,50E6,1);
scale_gaus = max(abs([I_gaus,Q_gaus]));
I_gaus = I_gaus/scale_gaus; Q_gaus = Q_gaus/scale_gaus;

%[I_gaus,Q_gaus] = gauspuls(ti,50E6,.8);

data_rick = rickerWavelet(t,f_ricker,t(end/2));
data_rick = data_rick/(max(abs(data_rick)));
IQ_rick = hilbert(data_rick);
I_rick = real(IQ_rick); Q_rick = -1*imag(IQ_rick);

I_prn = 2*round(rand(1,n))-1;
Q_prn = 2*round(rand(1,n))-1;

data_fpf = frankPolyPhase(n);
data_fpf1 = [data_fpf,zeros(1,200)];
data_fpf2 = [zeros(1,200),data_fpf];
data_fpf3 = ([zeros(1,100),data_fpf,zeros(1,100)] + [zeros(1,98),data_fpf,zeros(1,102)] + [zeros(1,103),data_fpf,zeros(1,97)]+[zeros(1,110),data_fpf,zeros(1,90)]);

data_zchu = zadoffChu(n);

data_p = polyphaseCode(n);

barker_code = barkerCode(13);
data_barker = zeros(1,n);
data_barker(n/2-6:n/2+6) = barker_code;
IQ_barker = hilbert(data_barker);

barker_win = repmat(barker_code,1,ceil(n/numel(barker_code)));
barker_win = barker_win(1:n);
I_linbkr = I_lin.*barker_win;
Q_linbkr = Q_lin.*barker_win;


b = fir1(64, 0.75);
% bandlimited pseudorandom noise
IQ_prn = I_prn - 1i*Q_prn;
IQ_prnb = filter(b,1,IQ_prn);
I_prnb = real(IQ_prnb); Q_prnb = -1*imag(IQ_prnb);

%IQ_fpfb = filter(b,1,data_fpf);
IQ_fpfb = filter(b,1,IQ_fpf);
I_fpfb = real(IQ_fpfb); Q_fpfb = -1*imag(IQ_fpfb);

IQ_zchu = real(data_zchu)-1i*imag(data_zchu);
%IQ_zchub = filter(b,1,data_zchu);
IQ_zchub = filter(b,1,IQ_zchu);
I_zchub = real(IQ_zchub); Q_zchub = -1*imag(IQ_zchub);


fname = '/Users/sam/outputs/waveform_data.bin';
waveform2file(I_lin,Q_lin,fname);

fname = '/Users/sam/outputs/waveform_data_i.bin';
waveform2file(I_lin,zeros(size(Q_lin)),fname);
fname = '/Users/sam/outputs/waveform_data_q.bin';
waveform2file(zeros(size(I_lin)),Q_lin,fname);
fname = '/Users/sam/outputs/waveform_data_ii.bin';
waveform2file(I_lin,I_lin,fname);
fname = '/Users/sam/outputs/waveform_data_qq.bin';
waveform2file(Q_lin,Q_lin,fname);

fname = '/Users/sam/outputs/waveform_data_gaus.bin';
waveform2file(I_gaus,Q_gaus,fname);

fname = '/Users/sam/outputs/waveform_data_rick.bin';
waveform2file(I_rick,Q_rick,fname);

fname = '/Users/sam/outputs/waveform_data_prn.bin';
waveform2file(I_prn,Q_prn,fname);
fname = '/Users/sam/outputs/waveform_data_prnb.bin';
waveform2file(I_prnb,Q_prnb,fname);

% fname = '/Users/sam/outputs/waveform_data_fpf.bin';
% waveform2file(real(data_fpf),imag(data_fpf),fname);
fname = '/Users/sam/outputs/waveform_data_fpf1.bin';
waveform2file(real(data_fpf1),imag(data_fpf1),fname);
fname = '/Users/sam/outputs/waveform_data_fpf2.bin';
waveform2file(real(data_fpf2),imag(data_fpf2),fname);
fname = '/Users/sam/outputs/waveform_data_fpf3.bin';
waveform2file(real(data_fpf3),imag(data_fpf3),fname);
fname = '/Users/sam/outputs/waveform_data_fpfb.bin';
waveform2file(I_fpfb,Q_fpfb,fname);

% fname = '/Users/sam/outputs/waveform_data_zchu.bin';
% waveform2file(real(data_zchu),imag(data_zchu),fname);
fname = '/Users/sam/outputs/waveform_data_zchub.bin';
waveform2file(I_zchub,Q_zchub,fname);

fname = '/Users/sam/outputs/waveform_data_barker.bin';
waveform2file(real(IQ_barker),-1*imag(IQ_barker),fname,n);
fname = '/Users/sam/outputs/waveform_data_barker_i.bin';
waveform2file(data_barker,zeros(size(data_barker)),fname,n);
fname = '/Users/sam/outputs/waveform_data_barker_ii.bin';
waveform2file(data_barker,data_barker,fname,n);

fname = '/Users/sam/outputs/waveform_data_linbarker.bin';
waveform2file(I_linbkr,Q_linbkr,fname,n);

for types = win_types
    win_type = char(types);

    switch win_type
        case '_blk'
            win = getBlackman(n)';
        case '_bhar'
            win = getBlackmanHarris(n)';
        case '_ham'
            win = getHamming(n)';
        case '_hann'
            win = getHann(n)';
        otherwise
            win = 1;
    end

    fname = sprintf('/Users/sam/outputs/waveform_data_lin%s.bin',win_type);
    waveform2file(I_lin.*win,Q_lin.*win,fname);
    fname = sprintf('/Users/sam/outputs/waveform_data_log%s.bin',win_type);
    waveform2file(I_log.*win,Q_log.*win,fname);
    fname = sprintf('/Users/sam/outputs/waveform_data_quad%s.bin',win_type);
    waveform2file(I_quad.*win,Q_quad.*win,fname);
    fname = sprintf('/Users/sam/outputs/waveform_data_fpf%s.bin',win_type);
    waveform2file(real(data_fpf).*win,imag(data_fpf).*win,fname);
    fname = sprintf('/Users/sam/outputs/waveform_data_zchu%s.bin',win_type);
    waveform2file(real(data_zchu).*win,imag(data_zchu).*win,fname);
    fname = sprintf('/Users/sam/outputs/waveform_data_p%s.bin',win_type);
    waveform2file(real(data_p).*win,imag(data_p).*win,fname);
end

%%
figure; hold on; plot(I_gaus);plot(Q_gaus);
figure; obw(I_gaus+1i*I_gaus,fs);

figure; hold on; plot(real(IQ_rick));plot(imag(IQ_rick));
figure; obw(IQ_rick,fs);


% figure; obw(IQ_prnb,fs);
% figure; obw(IQ_prn,fs);
% figure; obw(IQ_fpf,fs);
% figure; obw(IQ_fpfb,fs);
% figure; obw(IQ_zchu,fs);
% figure; obw(IQ_zchub,fs);
% 
% figure; hold on; plot(I_lin); plot(Q_lin);
% figure; hold on; plot(real(IQ_zchu)); plot(imag(IQ_zchu));




% figure; plot(I);title('I');
% figure; plot(Q);title('Q');
% figure; obw(Q_lin,fs);