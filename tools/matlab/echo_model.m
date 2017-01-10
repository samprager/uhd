%%
rng(1);
[I1,Q1] = file2waveform('/Users/sam/outputs/waveform_data_lin.bin');
[I2,Q2] = file2waveform('/Users/sam/outputs/waveform_data_lin.bin');

nvar = 10^10;
filtiq = I1 - 1i*Q1;
dataiq = I2 - 1i*Q2; 
noise = sqrt(nvar)*randn(size(dataiq));

% b = fir1(64, 0.75);
b_flen = 32; b_fcut = .75;
b = fir1(b_flen, b_fcut);
datafilt = filter(b,1,dataiq);

% b_flen = 0;
% datafilt = dataiq;

%figure; hold on; plot(real(dataiq)); plot(real(datafilt));

b_delay = {[zeros(1,9) 1],[zeros(1,11) 1],[zeros(1,19) 1]};

amplitude = {.5,1,.2}; 

echo = noise;
scene = 0;
for i = 1:numel(b_delay)
   echo = echo + amplitude{i}*filter(b_delay{i},1,datafilt);
   scene = scene + amplitude{i}*filter(b_delay{i},1,dataiq);
end

h1 = figure;
[acor,lag] = xcorr(echo,filtiq);
x1 = floor(numel(lag)/2)-100+b_flen/2; x2 = floor(numel(lag)/2)+100+b_flen/2;
%x1 = 1; x2 = numel(lag);
figure(h1); hold on; plot(lag(x1:x2)-b_flen/2,20*log10(abs(acor(x1:x2))));

[acor,lag] = xcorr(scene,filtiq);
x1 = floor(numel(lag)/2)-100; x2 = floor(numel(lag)/2)+100;
%x1 = 1; x2 = numel(lag);
figure(h1); hold on; plot(lag(x1:x2),20*log10(abs(acor(x1:x2)))); 
legend({'echo','scene'}); xlabel('sample delay'); ylabel('Detection Strength [dB]');
title('Autocorrelation: Linear Chirp Side-lobes');hold off; axis tight; grid on;

% mixr = fft(real(scene).*real(filtiq),8192);
% mixi = fft(imag(scene).*imag(filtiq),8192);
% figure; hold on; plot(20*log10(abs(mixr(1:100))));plot(20*log10(abs(mixi(1:100))));

%% 
rng(1);
N = 4092;
n = 0:1:(N-1);
k0 = 10;
w0 = 2*pi*k0/N;
s0 = 1;
nvar = 10;

s = s0; % amplitude
a0 = exp(1i*n*w0)';
noise = sqrt(nvar)*randn(N,1);

z = s0*a0 + noise;

figure; plot(abs(ifft(z)));
Rn_inv = (1/nvar)*eye(N);

% log likelihood function
% ln L = -1*((x-s*a)')*Rn_inv*(z-s*a);

% s_hat = argmax ln L(z|s,w)
a = a0;
s_hat = (a'*Rn_inv*z)/(a'*Rn_inv*a);

k1 = 20;
wc = 2*pi*k1/N;
w_est = [];
for k = 1:100

%noise = sqrt(nvar)*randn(N,1);
%z = s0*a0 + noise;

a = exp(1i*n*wc)';

% S = ln L(z|w) = |c'*z|^2
c = (Rn_inv*a)/(sqrt(a'*Rn_inv*a));
S = norm(c'*z);

% f(w) = d/dw F(W) = 0, F() = ln S(w)
% One step Netwons Method:
% w_hat = w_c - f(w)/(f_w(w)) |w_c

% f(w) = S_w(w)/S(w)
% fw(w) = df/dw
% aw = d/dw a = [0,jexp(jw),...,j*(N-1)exp(j(N-1)w)]'


aw = 1i*2*pi*n(:).*a;
d = (Rn_inv*aw)/(a'*Rn_inv*a);
mu = real((aw'*Rn_inv*a)/(a'*Rn_inv*a));
cw = d - mu*c;

%fw = (cw'*(z*z')*c + c'*(z*z')*cw)/(c'*(z*z')*c);% or
fw = 2*(real((d'*z)/(c'*z))-mu);
% f_ww = 2*mu^2 - 2*((d'*aw)/(c'*a));
f_ww = 2*mu^2 - 2*((aw'*Rn_inv*aw)/(a'*Rn_inv*a));

w_hat = wc - fw/f_ww;
wc = w_hat;
w_est = [w_est, w_hat];
end

figure; plot(abs(w_est));
%%
    %figure; area([randn(1,100)+10,100]);
    rng(1);
    
    L = 1000;
    N = 4000;
    c = 3e8;
    f0 = 100e6; BW = 50e6;
    f = linspace(f0,f0+BW,N)';
    fs = 2e8;
    nvar = 1;
   
    
    r_center = 4;              % wall center range distance
    tx_x = 1; rx_x = -1;
    target_x = linspace(-100,100,L-1);  % wall scatterer x location
    r_tx = sqrt((target_x-tx_x).^2+r_center^2); % scatter range
    r_rx = sqrt((target_x-rx_x).^2+r_center^2); % scatter range
    r = (r_tx+r_rx);
    
    r = [r,abs(tx_x-rx_x)]';

    % scattering amplitude
    % Projection of a_0 on vector towards antenna:
    % a_i = cos(theta_i)*a_0 = (r_center/r_i)*a_0
    a_0 = 5000;
    a1 = a_0*(r_center./r)';  % projection from norm in r direction direction scattering amplitude
    a2 = a_0*(r_center./r_tx)';  % projection from norm in tx direction direction scattering amplitude
    a3 = a_0*(r_center./r_rx)';  % projection from norm in rx direction scattering amplitude    
%    a = (a_0*((target_x-tx_x).*(-1*target_x+rx_x)+r_center^2)./(r_tx.*r_rx))'; %projectin from reflected tx to rx direction
%    a = a_0*(r_center./r_rx)';  % projection from norm in rx direction scattering amplitude
    
%a = [a1;a_0*4];
a = [a_0*ones(L-1,1);a_0];
a = a./(4*pi*r.^2);
% 
%      a(end) = 5;
%      r(end) = 5;
    
    E = zeros(N,L);
    for i = 1:L
        E(:,i) = exp(-1i*(4*pi/c)*r(i)*f);
    end
    n = sqrt(nvar)*randn(N,1);
    
    y = E*a + n;
    
    range = ([0:N-1])*c/(fs);
    %figure; plot(range',abs(ifft(y))); grid on;
    figure; plot(range',20*log10(abs(ifft(y)))); grid on;
    figure; hold on;
    scatter([tx_x,rx_x],[0,0]);
    scatter(target_x,r_center*ones(size(target_x)));
    plot(target_x,r_center-a(1:numel(target_x)));
    hold off;
    
%     figure; plot(target_x,a(1:numel(target_x)));
    % figure; hold on; plot(r(1:numel(target_x)));plot(r_tx); plot(r_rx); legend('r','r_tx','r_rx');
%     figure; hold on; plot(a1);plot(a2);plot(a3); legend({'a1','a2','a3'});

%% MUSIC Test
    %figure; area([randn(1,100)+10,100]);
    rng(1);
    
    L = 4;
    N = 4096;
    c = 3e8;
    f0 = 100e6; BW = 50e6;
    f = linspace(f0,f0+BW,N)';
    fs = 2e8;
    nvar = 1;
   
    
    r = 20*rand(L,1)+1;
    a_0 = 5000;    
    %a = a_0*ones(L,1)./(4*pi*r.^2);
    a = a_0*ones(L,1);
    
    E = zeros(N,L);
    for i = 1:L
        E(:,i) = exp(-1i*(4*pi/c)*r(i)*f);
    end
    n = sqrt(nvar)*randn(N,1);
    
    y = E*a + n;
    
    % sub arrays
    M = sqrt(N);
    J = fliplr(eye(M));
    Ry = zeros(M,M);
   for i = 1:M:(N-M)
       yk = y(i:i+M-1);
       Rk = yk*yk';
       Ry = Ry + Rk + J*(Rk')*J;
   end
   Ry = (1/(2*M))*Ry;
    
    range = ([0:N-1])*c/(fs);
    %figure; plot(range',abs(ifft(y))); grid on;
    figure; plot(range',20*log10(abs(ifft(y)))); grid on;
    figure; scatter(r,a);
    