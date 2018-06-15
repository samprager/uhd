function gpsvec = udar_gps_parse(gpsstr)
%udar_gps_parse - parse string with format: '34.199978 deg -118.168968 deg 348.684000m'
% Syntax:  gpsvec = udar_gps_parse(gpsstr)
%
% Inputs:
%    gpsstr - string with format: '<latitude> deg <longitude> deg
%    <elevation>m'
%
% Outputs:
%    gpsvec - [latitude, longitude, eleveation]
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Samuel Prager
% Microwave Systems, Sensors and Imaging Lab (MiXiL) 
% University of Southern California
% Email: sprager@usc.edu
% Created: 2018/05/25 20:23:28; Last Revised: 2018/05/25 20:23:28
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------

[a,b,c]=strread(gpsstr,'%f deg %f deg %fm');
gpsvec = [a,b,c];

%------------- END OF CODE --------------
