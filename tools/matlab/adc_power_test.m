[I,Q] = file2wave('~/outputs/waveform_data.bin');
figure; plot(I);
scale = double(intmax('int16'))
E = sum((I/scale).^2+(Q/scale).^2)
Z = 50;
Es = E/Z;
P_db = 10*log10(1000*Es/numel(I))



adc_snr_db = (1.763 + 6.02*14)

vpp = 2;
vrms = vpp/sqrt(2)
r_in = 50;
norm_fsamp = 10*log10(2.1e8/2);
ktb_1hz = 290*1*1.381e-23;
snr_spec = 72;
eff_bits = 11.4;
db_fs = 1;
adc_sig_pwr = 10 *log10(((vrms^2) / r_in)*1000)

adc_int_noise_pwr = adc_sig_pwr-snr_spec-db_fs;
adc_norm_noise_pwr = adc_int_noise_pwr-norm_fsamp

adc_eff_nf = adc_norm_noise_pwr - 10*log10(1000*ktb_1hz)

x = (I+1i*Q)/scale;
figure; obw(x,2e8);
X = sqrt(1/4096)*fft(x,4096);
E_fft = sum(abs(X).^2)
Es_fft = E_fft/Z;
P_fft = 10*log10(1000*Es_fft/numel(X))
figure; plot(20*log10(abs(X)));