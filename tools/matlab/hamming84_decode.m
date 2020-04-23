function [y,err] = hamming84_decode(varargin)

% decode vector of hamming(8,4) bits as int32 values
% usage y = hamming84_decode(x_b,format)
% format = ie. 'int32' (default), 'int64', etc or 'binary' for binary input
% err is an (nbits/4)xN (if x is a row vector) or  Nx(nbits/4) (if x is a
% col. vector) matrix of detected, uncorrectable errors (valid if num bit errors
% is <= 2).

if (nargin == 1)
    x = varargin{1};
    fmt = 'int32';
elseif(nargin>1)
    x = varargin{1};
    fmt = varargin{2};
else
    error('hamming84_encode(x,[format]) requires 1 or 2 inputs');
end

A = [ 1 1 0; 1 0 1;0 1 1;1 1 1;];
n = 7;%# of codeword bits per block
k = 4;%# of message bits per block
H = [eye(n-k),A',];
H = [H(:,1:2),H(:,4),H(:,3),H(:,5:end)];
G = [A,eye(k)];
G = [G(:,1:2),G(:,4),G(:,3),G(:,5:end)];

G8 = [G,[1;1;1;0]];
H8 = [[H,[0;0;0]];ones(1,8)];

R = [zeros(k,n-k),eye(k)];
R = [R(:,1:2),R(:,4),R(:,3),R(:,5:end)];
R8 = [R,zeros(4,1)];

x_b=reshape(x(:),n+1,[]).';

y_b = zeros(size(x_b,1),k);
err = zeros(size(x_b,1),1);

for i=1:size(x_b,1)
    a_enc = x_b(i,:);
    a_syn = mod(a_enc*H8',2);
    c_ind = [1 2 4 0]*a_syn';
    if (c_ind > 0 )
        a_enc(c_ind)= mod(a_enc(c_ind)+1,2); 
    end
    a_dec = a_enc*R8';
    y_b(i,:)=a_dec;
    err(i) = (~a_syn(end) && (c_ind > 0 ));
end
y_b = y_b.';

if(strcmp(fmt,'binary'))
    y = y_b(:);
else
    if (~contains(fmt,'uint'))
        u_format = strrep(fmt,'int','uint');
    else
        u_format = fmt;
    end
    formatfunc = str2func(u_format);
    nbits = str2double(u_format(strfind(u_format,'uint')+length('uint'):end));
    y_b = reshape(y_b,nbits,[]).';
    y = typecast(formatfunc(bin2dec(char(y_b+'0'))),fmt);
    y = double(y);
    err = reshape(err.',nbits/k,[]).';
end

if (size(x,2)>size(x,1))
    y = y.';
    err = err.';
end

end