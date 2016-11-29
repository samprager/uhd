%file = '/Users/sam/Ettus/uhd/host/outputs/usrp_samples.dat';
%file = '/Users/sam/Projects/Cpp/complex_test/out.dat';
file = '/Users/sam/VMLinux/Projects/UndergroundRadar/x300_GUI/usrp_x300_samples_debug.dat';
[datai dataq] = readComplexData(file,'int16');
figure; subplot(2,1,1); plot(datai);
subplot(2,1,2); plot(dataq);

fs = 2e8;
figure; subplot(2,1,1); obw(datai,fs);
subplot(2,1,2); obw(dataq,fs);

size(datai)

