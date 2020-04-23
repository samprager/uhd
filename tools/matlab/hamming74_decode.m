function y = hamming74_decode(varargin)

% decode vector of hamming(7,4) bits as int32 values
% usage y = hamming74_decode(x_b,format)
% format = 'int32' or 'binary'

if (nargin == 1)
    x = varargin{1};
    fmt = 'int32';
elseif(nargin>1)
    x = varargin{1};
    fmt = varargin{2};
else
    error('hamming74_encode(x,[format]) requires 1 or 2 inputs');
end

A = [ 1 1 0; 1 0 1;0 1 1;1 1 1;];
n = 7;%# of codeword bits per block
k = 4;%# of message bits per block
H = [eye(n-k),A',];
H = [H(:,1:2),H(:,4),H(:,3),H(:,5:end)];
G = [A,eye(k)];
G = [G(:,1:2),G(:,4),G(:,3),G(:,5:end)];

R = [zeros(k,n-k),eye(k)];
R = [R(:,1:2),R(:,4),R(:,3),R(:,5:end)];

x_b=reshape(x(:),n,[]).';

y_b = zeros(size(x_b,1),k);
for i=1:size(x_b,1)
    a_enc = x_b(i,:);
    a_syn = mod(a_enc*H',2);
    c_ind = [1 2 4]*a_syn';
    if (c_ind > 0 )
        a_enc(c_ind)= mod(a_enc(c_ind)+1,2); 
    end
    a_dec = a_enc*R';
    y_b(i,:)=a_dec;
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
end

if (size(x,2)>size(x,1))
    y = y.';
end

end