function data = maximal_prn(N)
nbits = ceil(log2(N));
taps = [12,11,8,6];
reg = ones(1,12);
seq = zeros(1,2^nbits);
for i=1:(2^nbits)
    seq(i) = reg(end);
    reg0 = mod(sum(reg(taps)),2);
    reg(2:end) = reg(1:end-1);
    reg(1) = reg0;
end
seq = (2*seq-1);
data = seq(1:N);

end
