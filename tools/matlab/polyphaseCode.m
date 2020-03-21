function p = polyphaseCode(n)
l = floor(sqrt(n));
if (mod(l,2)==1)
    %P1 code
    P1 = zeros(l,l);
    dphi = -1*(pi/l);
    for i = 1:l
        for j = 1:l
            P1(i,j)=(l-(2*j-1))*((j-1)*l+(i-1));
        end
    end
    phi = (P1(:)')*dphi;
else 
   %P2 code
    P2 = zeros(l,l);
    dphi = pi/l;
    for i = 1:l
        for j = 1:l
            P2(i,j)=((l-1)/2-(i-1))*(l+1-2*j);
        end
    end 
    phi = (P2(:)')*dphi;
end
p = [exp(1i*phi),zeros(1,n-l^2)];
end
