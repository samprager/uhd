function r = rect(varargin)
% Unit energy rect pulse either from -T/2 to T/2 with height 1/sqrt(T)
% or from t1 to t2 with height 1/sqrt(t2-t1)
if (nargin<1)
    err = 'rect(timevec,width), rect(timevec,t_start,t_stop), rect(timevec,t_start,t_stop,height)';
    error('Insufficint arguments. Usage:\n%s',err);
end
t = varargin{1};
if(nargin>2)
    t1 = varargin{2};
    t2 = varargin{3};
elseif(nargin>1)
    t1 = -varargin{2}/2;
    t2 = varargin{2}/2;
else
    t1 = -1/2;
    t2 = 1/2;
end
t1 = max(t(1),t1);
t2 = min(t(end),t2);
T = abs(t2-t1);

if(nargin>3)
    height = varargin{4};
else 
    height = 1/sqrt(T);
end

delta = (t(end)-t(1))/(numel(t));
ind1 = floor((t1-t(1))/delta)+1;
ind2 = floor((t2-t(1))/delta);
r = zeros(1,numel(t));
r(ind1:ind2) = height*ones(1,ind2-ind1+1);
end