function varargout = file2waveform(varargin)

if (nargin ==1)
    fname = varargin{1};
    format = 'int16';
    scale_out = double(intmax(format));
elseif (nargin ==2)
    fname = varargin{1};
    format = varargin{2};
    scale_out = double(intmax(format));
elseif (nargin ==3)
    fname = varargin{1};
    format = varargin{2};
    scale_out = varargin{3};
else   
    error('file2waveform(): Unrecognized argument list. Usage: file2waveform(fname,(format),(scale))');
end

fileID = fopen(fname,'r');
data=fread(fileID,format);
fclose(fileID);
I = data(2:2:end)';
Q = data(1:2:end)';

scale = scale_out/double(intmax(format));

I = scale*I;
Q = scale*Q;

if (nargout == 0)
    hold on; plot(I); plot(Q); legend('I','Q'); hold off;
    return;
elseif (nargout == 1)
    varargout{1} = I-1i*Q;
    return;
elseif (nargout == 2)
    varargout{1} = I;
    varargout{2} = Q;
    return;
else 
    error('file2waveform(): Unrecognized output type. Output formats: [],[IQ],[I,Q]');
end