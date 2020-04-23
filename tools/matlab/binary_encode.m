function y = binary_encode(varargin)

% encode vector of int32 values as bits
% usage y = binary_encode(x,format)
% format = 'int32', 'int64', etc

if (nargin == 1)
    x = varargin{1};
    fmt = 'int32';
elseif(nargin>1)
    x = varargin{1};
    fmt = varargin{2};
else
    error('binary_encode(x,[format]) requires 1 or 2 inputs');
end


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

y = x_b;
if (size(x,2)>size(x,1))
    y = y.';
end

end