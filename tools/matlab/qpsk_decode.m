function y = qpsk_decode(x,nsps)
    xIQ = x(:);
    xIQ = reshape(xIQ,nsps,[]);
    y = sum(xIQ,1);
    yI = real(y);
    yQ = imag(y);
    yI(yI>0)=1;
    yI(yI<0)=0;
    yQ(yQ>0)=1;
    yQ(yQ<0)=0;
    y = [yI;yQ];
    y = y(:);
    if (size(x,2)>size(x,1))
        y = y.';
    end
end