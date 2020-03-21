function varargout = motiondata(varargin)
%udar_read - parses config.txt outputs from UDAR usrp and averages data
%from multiple trials
%
% Usage:
%   [gpspos,gpstime,imudata,kused] = motiondata(tmap,'mykeyfilter','sort')
%
% Inputs:
%    tmap - containers.Map object with values that are structs created with
%    udar_read function
%    filter [optional] - search term to filter input map keys
%    mode [optional] - will sort vectors by gpstime if mode = 'sort'
%
% Outputs:
%    gpspos     - Nx3 [lat,lon,elev] vector
%    gpstime    - Nx1 vector
%    imudata    - Nx3 [roll,pitch,yaw] vector
%    kused      - N length struct of keys used in order
%    clrs       - Nx3 generated colors for each trial -- for plotting
%
% See also: udar_read,  udar_map

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:03:52; Last Revised: 2017/04/06 01:03:52

%------------- BEGIN CODE --------------
if(nargin>=1)
    tmap = varargin{1};
end
if(nargin>=2)
    filter = varargin{2};
else
    filter = '';
end

if (~isstr(filter))
    filter='';
end

gpspos = [];
gpstime = [];
imudata = [];
k = keys(tmap);
kused = {};
for i=1:numel(k)
    if ((numel(strfind(k{i},filter))==0) && (~strcmp(filter,'')))
        continue;
    end
    trial = tmap(k{i});
    if(isstruct(trial))
        gpspos = [gpspos;reshape([trial.gps_vec],3,numel(trial))'];
        gpstime = [gpstime;[trial.gps_time]'];
        imu = textscan([trial.imu],'(%f,%f,%f)');
        imudata = [imudata;imu{:}];
        kused = [kused,{k{i}}];
     end
end

if (numel(kused)==0)
    error('No valid trials found in given map');
end

if(nargin>=3)
    mode = varargin{3};
    if (strcmp(mode,'sort'))
        [~,inds]=sort(gpstime);
        gpstime = gpstime(inds);
        gpspos = gpspos(inds,1:3);
        imudata = imudata(inds,1:3);
    end
end

cmtx = get(gca,'ColorOrder');
vprev = strsplit(kused{1},filesep);
ind = 1;
clrs =repmat(cmtx(1,:),numel(tmap(kused{1})),1);
for i=2:numel(kused)
    v = strsplit(kused{i},filesep);
    if ((strcmp(v{1},vprev{1})) && (numel(v)>1))
        ind = ind;
    else
        ind = mod(ind,size(cmtx,1))+1;
    end
    clrs = [clrs;repmat(cmtx(ind,:),numel(tmap(kused{i})),1)];
    vprev = v;
end

if(nargout==0)
    gpslat = gpspos(:,1);
    gpslon = gpspos(:,2); 
    gpsel = gpspos(:,3);
    plot3(gpslon,gpslat,gpsel); grid on; axis tight;
    hold on; scatter3(gpslon,gpslat,gpsel,10*ones(numel(gpslat,1),1),clrs,'filled'); hold off;
    xlabel('lat');ylabel('lon');zlabel('elev');
end
if(nargout>=1)
    varargout{1}=gpspos;
end
 
if(nargout>=2)
    varargout{2}=gpstime;
end

if(nargout>=3)
    varargout{3}=imudata;
end

if(nargout>=4)
    varargout{4}=kused;
end

if(nargout>=5)
    varargout{5}=clrs;
end
        
%------------- END OF CODE --------------
