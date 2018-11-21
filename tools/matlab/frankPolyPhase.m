function f = frankPolyPhase(n)
    l = floor(sqrt(n));
    x = 0:(l-1);
    dphi = 2*pi/l;
    F = x'*x;
    phi = (F(:)')*dphi;
    f = [exp(1i*phi),zeros(1,n-l^2)];
end