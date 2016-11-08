file = '/Users/sam/Ettus/uhd/host/outputs/usrp_samples.dat';
%file = '/Users/sam/Projects/Cpp/complex_test/out.dat';
[datai dataq] = readComplexData(file,'int16');
figure; subplot(2,1,1); plot(datai);
subplot(2,1,2); plot(dataq);

