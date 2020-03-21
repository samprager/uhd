function z= zadoffChu(N)
 m = 0:(N-1);
 if(mod(N,2)==0)
     phi = (pi/N)*(m.^2);
 else
     phi = (pi/N)*(m+1).*m;
 end
 z = exp(1i*phi);
end