%% 
fs = 2e8; er = 12; c = 3e8;BW = 75e6;

s1 = [conj(file2waveform('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_250mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d2/x300_samples_250mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d3/x300_samples_250mhz-1.dat'))];
s2 = [conj(file2waveform('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_300mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d2/x300_samples_300mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d3/x300_samples_300mhz-1.dat'))];
s3 = [conj(file2waveform('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_400mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d2/x300_samples_400mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d3/x300_samples_400mhz-1.dat'))];
s4 = [conj(file2waveform('/Users/sam/outputs/test_soil/lin/d1_nospade/x300_samples_500mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d2/x300_samples_500mhz-1.dat'));
    conj(file2waveform('/Users/sam/outputs/test_soil/lin/d3/x300_samples_500mhz-1.dat'))];
%s3 = conj(file2waveform('/Users/sam/outputs/test_soil/lin/d3/x300_samples_400mhz-1.dat'));

tests = {'d1','d2','d3'};
freqs = {'250mhz','300mhz','400mhz'};

T_crb = 1/fs; dR_crb = c/(sqrt(er)*2*fs);
delta_tau = size(s1,2)/fs; deltaR = delta_tau*c/(2*sqrt(er));

Nzp = 2^(ceil(log2(size(s1,1))));
d_fc = 50e6;
d_Rc = c/(sqrt(er)*2*d_fc);
dr_crp = d_Rc/Nzp;

fs2 = fs*4; fc = 750e6;
t_u = linspace(0,4*size(s1,2)/fs2,4*size(s1,2));

h1 = file2waveform('/Users/sam/outputs/waveform_data_lin.bin'); 
if (numel(h1) < size(s1,2))
    h1 = [h1,zeros(1,size(s1,2)-numel(h1))];
end

% f1 = figure;
% f2 = figure;

for i=1:size(s1,1)
    s_crb = [xcorr(s1(i,:),h1);xcorr(s2(i,:),h1);xcorr(s3(i,:),h1)];
    s_crp = zeros(Nzp,size(s_crb,2));
    for j = 1:size(s_crb,2)
        s_crp(:,j) = ifft(s_crb(:,j),Nzp);
        R_j = dR_crb*j;
        R_interval = [-dR_crb/2+R_j,dR_crb/2+R_j];
        R_crp = R_j+([dr_crp:dr_crp:Nzp*dr_crp]-(Nzp+1)*dr_crp/2);
    end
    figure;
    for j = 1:size(s_crp,1)
        plotrng = ceil(size(s_crp,2)/2)*[1,1]+[100,250];
        subplot(size(s_crp,1),1,j); plot(20*log10(abs(s_crp(j,plotrng(1):plotrng(2)))));
        title(sprintf('%s complex range profile: %g',tests{i},j));
    end
    
  
end
