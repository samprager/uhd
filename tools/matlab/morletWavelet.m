function s = morletWavelet(N,sig_m,c_support)
    if (mod(N,2)==0)
        n = [(-N/2) : 1: (N/2-1)];
    else
        n = [(-(N-1)/2) : 1: ((N-1)/2)];
    end
    n_morlet = n.*(abs(c_support/n(1)));
    s = exp(-.5*((n_morlet).^2)).*exp(1i*sig_m*n_morlet);
end
