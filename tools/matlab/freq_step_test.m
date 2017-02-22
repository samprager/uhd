fs = 2e8;
t1 = linspace(0,4096/fs,4096);
f0 = 1e6; f1 = 51e6; k1 = (f1-f0)/t1(end);
s1 = exp(1i*2*pi*(f0*t1+.5*k1*t1.^2));
figure; obw(s1,fs*4);

fc = 50e6; fs2 = fs*4;
s1u = interp(s1,4);
t2 = linspace(0,numel(s1u)/fs2,numel(s1u));
s2 = .5*(s1u + s1u.*exp(1i*2*pi*fc*t2) + s1u.*exp(1i*4*pi*fc*t2) + s1u.*exp(1i*6*pi*fc*t2) +...
    s1u.*exp(1i*8*pi*fc*t2) + s1u.*exp(1i*10*pi*fc*t2) + s1u.*exp(1i*12*pi*fc*t2)+s1u.*exp(1i*14*pi*fc*t2));
figure; obw(s2,fs2);

w2 = zeros(size(s2));
w2(1:numel(s2)/2) = getHamming(numel(s2)/2)';
s2 = ifft(w2.*fft(s2));
figure; obw(s2,fs2);

f0 = 1e6; f1 = 51e6;
k2 = (3*fc+f1-f0)/t2(end); 
s3 = exp(1i*2*pi*(f0*t2+.5*k2*t2.^2));
figure; obw(s3,fs2);

trim = 8000;
[s1u_xc, l1_u] = xcorr(s1u,s1u);
r1_u = find(abs(l1_u)<= trim);
[s2_xc, l2] = xcorr(s2,s2);
r2 = find(abs(l2)<= trim);
[s3_xc, l3] = xcorr(s3,s3);
r3 = find(abs(l3)<= trim);

figure; hold on;
plot(l1_u(r1_u),20*log10(abs(s1u_xc(r1_u))));
plot(l2(r2),20*log10(abs(s2_xc(r2))));
plot(l3(r3),20*log10(abs(s3_xc(r3))));

%%
fs = 2e8;
n = 4096;
t1 = linspace(-n/(2*fs),n/(2*fs),4096);
f0 = 0; f1 = 50e6; k1 = (f1-f0)/t1(end);
s1 = exp(1i*2*pi*(f0*t1+.5*k1*t1.^2));

fc = 50e6;
s2 = [s1, s1.*exp(1i*4*pi*fc*t1)];
figure; obw(s2,fs);

figure; plot(20*log10(abs(xcorr(s2,s2)))); title('s2');
figure; plot(20*log10(abs(xcorr(s1,s1)))); title('s1');
s_R1 = .4*[zeros(1,10),s1, zeros(1,10)] + .7*[zeros(1,15),s1,zeros(1,5)];
s_R2 = .6*[zeros(1,10),s1, zeros(1,10)] + .3*[zeros(1,15),s1,zeros(1,5)];
s3 = [xcorr(s_R1,s1);xcorr(s_R2,s1)];
s4 = zeros(16,size(s3,2));
for i = 1:size(s3,2)
    s4(:,i) = ifft(s3(:,i),16);
end
s4 = s4(4:8:12,:);
s4 = s4(:);

su_R = [zeros(1,10),.4*s1,.6*s1.*exp(1i*4*pi*fc*t1),zeros(1,10)] + ...
       [zeros(1,15),.7*s1,.3*s1.*exp(1i*4*pi*fc*t1),zeros(1,5)];
s3u = xcorr(su_R,s2);

figure; obw(s1,fs);
figure; obw(real(s1),fs);
figure; obw(imag(s1),fs);

figure;
for i = 1:size(s3,1)
    subplot(size(s3,1),1,i);
    plot(20*log10(abs(s3(i,:))));grid on; title(sprintf('s3 %g',i));
end
figure; obw(s4,fs);
figure; plot(20*log10(abs(s4))); grid on; title('s4');

figure; obw(s3u,fs);
figure; plot(20*log10(abs(s3u))); grid on; title('s3u');