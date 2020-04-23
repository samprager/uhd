function y = binary_decode(varargin)

% decode vector of bits as int32 values
% usage y = binary_decode(x_b,format)
% format = 'int32', 'int64', etc

if (nargin == 1)
    x = varargin{1};
    fmt = 'int32';
elseif(nargin>1)
    x = varargin{1};
    fmt = varargin{2};
else
    error('binary_decode(x,[format]) requires 1 or 2 inputs');
end

y_b = x(:);

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

if (size(x,2)>size(x,1))
    y = y.';
end

end