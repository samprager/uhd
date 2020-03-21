%% configfile_autoprocess.m
%  Author: Samuel Prager
%  University of Southern California
%  email: sprager@usc.edu
%  Created: 2017/04/05

outdir = '/Users/sam/outputs/vivaldi_s_2ref/';
trials = udar_read(outdir);

filt = file2wave('/Users/sam/outputs/waveform_data_lindsb.bin');
fs = 2e8;
upfac = max(numel(trials),10);
fs2 = fs*upfac; fc = 160e6;
plotrng = 80000;

ntrials = min(numel(trials),5);

[data_u,filt_u] = freqstack(trials(1:ntrials),filt,upfac,fs,fc);

[mf_u,l_u] = xcorr(data_u,filt_u);
[pval,ploc] = max(abs(mf_u));
x1 = ploc-plotrng/2; x2 = ploc+plotrng/2;

h1 = figure;

figure(h1); hold on;
plot(l_u(x1:x2),db(abs(mf_u(x1:x2)),'power'),'r'); axis tight;

[mf_int,l_int] = xcorr(interp(trials(1).data,upfac),interp(filt,upfac));
[pval,ploc] = max(abs(mf_int));
x1 = ploc-plotrng/2; x2 = ploc+plotrng/2;

figure(h1); hold on;
plot(l_int(x1:x2),db(abs(mf_int(x1:x2)),'power'),'c'); axis tight;

h2 = figure; 

figure(h2); hold on;
legstr = {}; lind = 1;
for i=1:ntrials
%     if trials(i).freq == 2e9
        [cprs,lc] = xcorr(trials(i).data,filt);
        plot(lc,db(abs(cprs),'power'));
        legstr{lind} = trials(i).name;
        lind = lind+1;
%     end
end
legend(legstr);


%%
figure; hold on;
plot(real(filt_u));
plot(real(data_u));

% figure;
% subplot(2,1,1); plot(real(filt_u));
% subplot(2,1,2); plot(real(data_u));


figure; obw(filt_u,fs2);
figure; obw(data_u,fs2);

%%

trials2 = udar_read('/Users/sam/outputs/vivaldi_s_2ref/');
for i=1:ntrials
        figure; hold on;
        [cprs,lc] = xcorr(trials(i).data,filt);
        [cprs2,lc2] = xcorr(trials2(i).data,filt);
        plot(lc,db(abs(cprs),'power'));
        plot(lc2,db(abs(cprs2),'power'));
        title(sprintf('1: %f, 2: %f',trials(i).freq,trials2(i).freq));
end
%%
fu = [];
du = 0;
t_u = linspace(0,upfac*size(filt,2)/fs2,upfac*size(filt,2));
t_u1 = linspace(0,upfac*size(trials(1).data,2)/fs2,upfac*size(trials(1).data,2));

ntrials = 3;
figure; hold on;
predelay = 1;
lastind = 1;
for i=1:ntrials
%     predelay = [zeros(1,numel(fu)+(numel(trials(i).data)-numel(filt))*upfac) 1];
%     predelay = [zeros(1,numel(fu)) 1];
    fu = [fu,interp(filt,upfac).*exp(1i*(i-1)*2*pi*fc*t_u)];
    data_utemp = interp(trials(i).data,upfac).*exp(1i*(i-1)*2*pi*fc*t_u1);
    firstind = 1;
    if(i>1)
    for j=1:numel(data_utemp)
        if(abs(data_utemp(j))>(max(abs(data_utemp))/10))
            firstind = j;
            break;
        end
    end
    end

    %plot(real(data_utemp(firstind:end)));
%     data_utemp = conv(data_utemp(firstind:lastind),predelay);
    predelay = [zeros(1,max(0,lastind-firstind)) 1];
    data_utemp = conv(data_utemp,predelay);

    plot(real(data_utemp));
    postdelay = [1 zeros(1,numel(data_utemp)-numel(du))];
    du = conv(du,postdelay)+data_utemp;
    
    lastind = numel(du);
    for j=numel(du):-1:1
        if(abs(du(j))>(max(abs(du))/10))
            lastind = j;
            break;
        end
    end

end

figure; obw(du);

%%
% outdir = '/Users/sam/outputs/vivaldi_s_2ref/';
outdir = '/Users/sam/outputs/loopback/no_zp/50/';

trials = udar_read(outdir);

N = 4; %numel(trials);
fs = 2e8; upfac = 4; dfc = 50e6; Bs = 50e6;

filt = file2wave('/Users/sam/outputs/waveform_data_lin50.bin');

[z,x,xtx]=freqstack3(trials(1:N),filt,fs,dfc,Bs,upfac);
%z =freqstack2(trials(1:N),fs,dfc,Bs,upfac);
%[x,xtx] =freqstack2(repmat([filt,zeros(1,size(trials(1).data,2)-size(filt,2))],N,1),fs,dfc,Bs,upfac);

%x = x.*chebwin(numel(x))';
%xtx = xtx.*chebwin(numel(xtx))';


% figure; hold on; plot(real(x)); plot(imag(x)); title('x');
% figure; hold on; plot(real(z)); plot(imag(z)); title('z');
figure; obw(x,fs*upfac);
figure; obw(z,fs*upfac); 

figure; plot(real(z));

[wu,lu]=xcorr(interp(filt,upfac),interp(filt,upfac));
[wd,ld]=xcorr(interp(trials(1).data,upfac),interp(filt,upfac));
[wz,lz]=xcorr(z,z);
[wx,lx]=xcorr(x,x);
[wxz,lxz]=xcorr(z,x);
[wt,lt]=xcorr(z,xtx);
[wxt,lxt]=xcorr(x,xtx);

% figure; hold on; plot(real(x)); plot(imag(x)); title('x');
% 
% figure;hold on;
% plot(lu,db(abs(wu),'power'));
% plot(lx,db(abs(wx),'power'));
% plot(lz,db(abs(wz),'power'));
% plot(lxz,db(abs(wxz),'power'));
% legend('wu','wx','wz','wxz');
% grid on;

%%
[~,ind] = max(abs(wxz));
figure(24); hold on; plot(lxz-lxz(ind),db(abs(wxz),'power')); grid on;
[~,ind] = max(abs(wt));
figure(24); hold on; plot(lt-lt(ind),db(abs(wt),'power')); grid on;
[~,ind] = max(abs(wxt));
figure(24); hold on; plot(lxt-lxt(ind),db(abs(wxt),'power')); grid on;
[~,ind] = max(abs(wd));
figure(24); hold on; plot(ld-ld(ind),db(abs(wd),'power')); grid on;
legend('xz','z w/ xtx','x w/ xtx','non stacked');

[~,ind] = max(abs(wxz));
figure(25); hold on; plot(lxz-lxz(ind),db(abs(wxz),'power')); grid on;
[~,ind] = max(abs(wz));
figure(25); hold on; plot(lz-lz(ind),db(abs(wz),'power')); grid on;
[~,ind] = max(abs(wx));
figure(25); hold on; plot(lx-lx(ind),db(abs(wx),'power')); grid on;
legend('wxz','z w/ z','x w/ x');

figure(26); hold on;
legstr = {}; lind = 1;
[cprs,lc] = xcorr(trials(1).data,filt);
plot(lc,db(abs(cprs),'power'));

figure; hold on;
legstr = {}; lind = 1;
for i=1:N
%     if trials(i).freq == 2e9
        [cprs,lc] = xcorr(trials(i).data,filt);
        plot(lc,db(abs(cprs),'power'));
        legstr{lind} = num2str(trials(i).freq);
        lind = lind+1;
%     end
end
legend(legstr);
title(outdir);


%%
fs  = 2e8;

outdir = '/Users/sam/outputs/loopback/zp/80/';
trials = udar_read(outdir);
tx = file2wave('/Users/sam/outputs/waveform_zeropad80.bin');
rx = trials(1).data;
fc = trials(1).freq;
tau=1024/fs;

n = numel(rx);
H = fft(rx)./fft(tx,n);


% figure; 
% subplot(2,1,1); plot(abs(H));
% subplot(2,1,2); plot(angle(H));


Z = fft(tx,n)./H;

% figure; 
% subplot(2,1,1); plot(abs(Z));
% subplot(2,1,2); plot(angle(Z));


z = ifft(Z);

% figure; 
% subplot(2,1,1); plot(real(z));
% subplot(2,1,2); plot(imag(z));

figure; 
subplot(2,1,1); plot(real(rx));
subplot(2,1,2); plot(imag(rx));

figure; 
subplot(2,1,1); plot(real(tx));
subplot(2,1,2); plot(imag(tx));

zp = ifft(H.*Z);
figure; 
subplot(2,1,1); plot(real(zp));
subplot(2,1,2); plot(imag(zp));
figure;obw(tx,fs);
figure;obw(rx,fs);

[wx,lx]=xcorr(rx,tx);
[~,ind] = max(abs(wx));
rng = (ind-100):(ind+100);
figure(22); hold on; plot(lx(rng)-lx(ind),db(abs(wx(rng)),'power')); grid on;

t = linspace(0,n/fs,n);
[a,b,c] = obw(rx,fs);
ferr = -1*(b+c)/2;
rx=rx.*exp(1i*2*pi*ferr*t)*exp(1i*pi);
figure;obw(rx,fs);
figure; 
subplot(2,1,1); plot(real(rx));
subplot(2,1,2); plot(imag(rx));

[wx,lx]=xcorr(rx,tx);
[~,ind] = max(abs(wx));
rng = (ind-100):(ind+100);
figure(22); hold on; plot(lx(rng)-lx(ind),db(abs(wx(rng)),'power')); grid on;

%%
z1=freqstack2(repmat([zeros(1,256),filt],4,1),fs,dfc,Bs,upfac);
z2=freqstack2(repmat([filt],4,1),fs,dfc,Bs,upfac);

[wx,lx]=xcorr(z1,z2);
[~,ind] = max(abs(wx));
figure; hold on; 
plot(lx-lx(ind),db(abs(wx),'power')); grid on;
[wu,lu]=xcorr(interp(filt,upfac),interp(filt,upfac));
[~,ind] = max(abs(wu));
plot(lu-lu(ind),db(abs(wu),'power')); grid on;

%%
%z3=freqstack2(repmat([filt],4,1),fs);
z4=freqstack2(trials(1:N),filt,fs,dfc,Bs,upfac);

%%
%%
% outdir = '/Users/sam/outputs/vivaldi_s_2ref/';
outdir = '/Users/sam/outputs/loopback/zp/50/';

trials = udar_read(outdir);

N = 4;%numel(trials);
fs = 2e8; upfac = 8; dfc = 50e6; Bs = 50e6;

filt = file2wave('/Users/sam/outputs/waveform_zeropad50.bin');

zp_pre = 512;
for i=1:N
    trials(i).data = trials(i).data(zp_pre:end);
end
filt = filt(zp_pre:end);


[z,x,xtx]=freqstack3(trials(1:N),filt,fs,dfc,Bs,upfac);

%x = x.*chebwin(numel(x))';
%xtx = xtx.*chebwin(numel(xtx))';


% figure; hold on; plot(real(x)); plot(imag(x)); title('x');
% figure; hold on; plot(real(z)); plot(imag(z)); title('z');
figure; obw(x,fs*upfac);
figure; obw(z,fs*upfac); 

figure; plot(real(z));

[wu,lu]=xcorr(interp(filt,upfac),interp(filt,upfac));
[wd,ld]=xcorr(interp(trials(1).data,upfac),interp(filt,upfac));
[wz,lz]=xcorr(z,z);
[wx,lx]=xcorr(x,x);
[wxz,lxz]=xcorr(z,x);
[wt,lt]=xcorr(z,xtx);
[wxt,lxt]=xcorr(x,xtx);


% [~,ind] = max(abs(wxz));
% figure(24); hold on; plot(lxz-lxz(ind),db(abs(wxz),'power')); grid on;
% [~,ind] = max(abs(wt));
% figure(24); hold on; plot(lt-lt(ind),db(abs(wt),'power')); grid on;
% [~,ind] = max(abs(wxt));
% figure(24); hold on; plot(lxt-lxt(ind),db(abs(wxt),'power')); grid on;
% [~,ind] = max(abs(wd));
% figure(24); hold on; plot(ld-ld(ind),db(abs(wd),'power')); grid on;
% legend('xz','z w/ xtx','x w/ xtx','non stacked');

% [~,ind] = max(abs(wxz));
% figure(25); hold on; plot(lxz-lxz(ind),db(abs(wxz),'power')); grid on;
% [~,ind] = max(abs(wz));
% figure(25); hold on; plot(lz-lz(ind),db(abs(wz),'power')); grid on;
% [~,ind] = max(abs(wx));
% figure(25); hold on; plot(lx-lx(ind),db(abs(wx),'power')); grid on;
% legend('wxz','z w/ z','x w/ x');

[~,ind] = max(abs(wxz));
figure(26); hold on; plot(lxz-lxz(ind),db(abs(wxz),'power')); grid on;

[~,ind] = max(abs(wxz));
figure(27); hold on; plot(lxz-lxz(ind),db(abs(wxz),'power')); grid on;
[~,ind] = max(abs(wd));
figure(27); hold on; plot(ld-ld(ind),db(abs(wd),'power')); grid on;
legend('xz','non stacked');
