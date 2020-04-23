function y = hamming74_encode(varargin)

% encode vector of int32 values as hamming(7,4) bits
% usage y = hamming74_encode(x,format)
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

if(strcmp(fmt,'binary'))
    x_b = x(:);
else
    if (~contains(fmt,'uint'))
        u_format = strrep(fmt,'int','uint');
    else
        u_format = fmt;
    end
    nbits = str2double(u_format(strfind(u_format,'uint')+length('uint'):end));
    formatfunc = str2func(fmt);
    x_b = dec2bin(typecast(formatfunc(x(:).'),u_format),nbits)-'0';
    % put in format [x1_n, x1_n-1,...,x1_1,x2_n,...,x2_1,...]'
    x_b = x_b.';
    x_b = x_b(:);
end
% put in format [x1_n, x1_n-1,...,x1_n-3;x1_n-4,...,x1_n-7;...'x1_4,...x1_1;...]'
x_b=reshape(x_b(:),4,[]).';

A = [ 1 1 0; 1 0 1;0 1 1;1 1 1;];
n = 7;%# of codeword bits per block
k = 4;%# of message bits per block
H = [eye(n-k),A',];
H = [H(:,1:2),H(:,4),H(:,3),H(:,5:end)];
G = [A,eye(k)];
G = [G(:,1:2),G(:,4),G(:,3),G(:,5:end)];

y_b = zeros(size(x_b,1),n);
for i=1:size(x_b,1)
    a = x_b(i,:);
    a_enc = mod(a*G,2);
    y_b(i,:)=a_enc;
end
y_b = y_b.';
y = reshape(y_b,1,[]);
if (size(x,1)>size(x,2))
    y = y.';
    y_b = y_b.';
end

end