function data_iq = waveform2file(varargin)

if (nargin ==2)
    I = real(varargin{1});
    Q = imag(varargin{1});
    fname = varargin{2};
    n = numel(I);
    format = 'int16';
    scale = double(intmax(format));
else if (nargin ==3)
    I = varargin{1};
    Q = varargin{2};
    fname = varargin{3};
    n = numel(I);
    format = 'int16';
    scale = double(intmax(format));
elseif (nargin ==4)
    I = varargin{1};
    Q = varargin{2};
    fname = varargin{3};
    n = varargin{4};
    format = 'int16';
    scale = double(intmax(format));
elseif (nargin ==5)
    I = varargin{1};
    Q = varargin{2};
    fname = varargin{3};
    n = varargin{4};
    format = varargin{5};
    scale = double(intmax(format));
elseif (nargin ==6)
    I = varargin{1};
    Q = varargin{2};
    fname = varargin{3};
    n = varargin{4};
    format = varargin{5};
    scale = varargin{6};
else    
    error('waveform2file(): Unrecognized argument list. Usage: waveform2file(I,Q,fname,(length),(format),(scale))');
end

maxval = max(abs([I(:);Q(:)]));

I = [I(:)',zeros(1,n-numel(I))];
Q = [Q(:)',zeros(1,n-numel(Q))];

formatfunc = str2func(format);
data_i = formatfunc((scale/maxval)*I);
data_q = formatfunc((scale/maxval)*Q);

data_iq = reshape([data_q;data_i],1,2*n);
fileID = fopen(fname,'w');
frewind(fileID);
fwrite(fileID,data_iq,format);
fclose(fileID);

end