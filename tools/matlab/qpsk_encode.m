function y = qpsk_encode(x,nsps)

    xI = x(1:2:end);
    xQ = x(2:2:end);
    yIQ = (xI(:)*2-1)+1i*(xQ(:)*2-1);
    y = repmat(yIQ,1,nsps).';
    y = y(:);
    if (size(x,2)>size(x,1))
        y = y.';
    end
end