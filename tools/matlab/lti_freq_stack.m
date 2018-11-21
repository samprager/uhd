
%%
fs = 4e8;
N = 4; n = 4096; ntau = 128;
Tp = n/fs;
fs2 = fs*N; 
dfc = 50e6; fc0 = 0e6; fc = fc0+(N-1)*dfc/2;
Bs = 80e6; fnq = N*Bs*2;
K = Bs/Tp;
fn = fc0+(0:(N-1))*dfc;
dfn = fn-fc;
dTn = dfn/K;

tau=ntau/fs;
t = linspace(-Tp/2,Tp/2+tau,n+ntau);
t2 = linspace(-N*Tp/2,N*Tp/2+tau,N*n+ntau);
f = linspace(0,fs,N*n+ntau);

x_tx = exp(1i*pi*K*t2.^2).*rect(t2,t2(1),t2(end-ntau),1);

x_rx = exp(1i*pi*K*(t2-tau).^2).*exp(-1i*2*pi*fc*tau).*rect(t2,t2(1)+tau,t2(end),1);

sn = []; rn = [];
for i=1:N
    sn = [sn;exp(1i*2*pi*fn(i)*t).*exp(1i*pi*K*t.^2).*rect(t,t(1),t(end-ntau),1)];
    rn = [rn;exp(-1i*2*pi*fn(i)*tau).*exp(1i*pi*K*(t-tau).^2).*rect(t,t(1)+tau,t(end),1)];
end

Hn = [];
for i = 1:N
    Hn = [Hn;rect(f,dfn(i),dfc+dfn(i),1).*exp(j*2*pi*dTn(i)*f)*exp(-1i*pi*dTn(i)*dfn(i))];
end

xn = [];
for i=1:N
    %xn = [xn;exp(-1i*2*pi*fn(i)*tau).*exp(1i*pi*K*(t-tau).^2).*exp(1i*2*pi*dfn(i)*t).*rect(t,tau,Tp+tau,1)];
    xn = [xn;rn(i,:).*exp(1i*2*pi*dfn(i)*t)];
end


gn = [];

tfilt = t2;
for i=1:N
    gn = [gn;(1/(2*pi*dfc))*(sin(pi*Bs*(tfilt-dTn(i)))./(pi*(tfilt-dTn(i)))).* ...
        exp(1i*pi*dTn(i)*fn(i)).*exp(1i*2*pi*(tfilt-dTn(i))*dfn(i))];
end

dtu = 1/(N*fnq);
zn = [];
for i=1:N
    zn = [zn;conv(xn(i,:),gn(i,:))];
end
figure;
for i=1:N
    subplot(N,1,i);
    obw(zn(i,:),fs);
    title('zn');
end
z = sum(zn);
figure; hold on; plot(real(z)); plot(imag(z)); title('z');
figure; obw(z,fs);

bbwave = exp(1i*pi*K*t.^2).*rect(t,t(1),t(end-ntau),1);
[wu,lu]=xcorr(rn(1,:),rn(1,:));
[w,l]=xcorr(x_tx,x_tx);
[wr,lr]=xcorr(z,x_tx);
[wz,lz]=xcorr(z,z);

figure;hold on;
plot(l,db(abs(w),'power'));
plot(lu,db(abs(wu),'power'));
plot(lr,db(abs(wr),'power'));
plot(lz,db(abs(wz),'power'));
grid on;
%%
figure; obw(x_tx,fs);
figure; hold on; plot(real(x_tx)); plot(rect(t2,t2(1),t2(end-ntau),1));

figure; obw(x_rx,fs);
figure; hold on; plot(real(x_rx)); plot(rect(t2,t2(1)+tau,t2(end),1));


figure;
for i=1:N
    subplot(N,1,i);
    plot(real(sn(i,:)));
end
title('sn');

figure;
for i=1:N
    subplot(N,1,i);
    obw(sn(i,:),fs);
    title('sn');
end

figure;
for i=1:N
    subplot(N,1,i);
    plot(real(rn(i,:)));
    title('rn');
end

figure;
for i=1:N
    subplot(N,1,i);
    plot(real(xn(i,:)));
end
title('xn');

figure;
for i=1:N
    subplot(N,1,i);
    obw(xn(i,:),fs);
end
title('xn');
       
figure;
for i=1:N
    subplot(N,1,i);
    plot(real(Hn(i,:)));
end
title('Hn');
       