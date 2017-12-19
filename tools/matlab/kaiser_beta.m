function beta = kaiser_beta(alpha)
%kaiser_beta - Compute kaiser beta parameter from desired sidelobe
% attenuation alpha dB

% Syntax:  beta = kaiser_beta(alpha)
%
% Inputs:
%    alpha - sidelobe attenuation rate in dB
%
% Outputs:
%    beta - kaiser parameter
%
% Example: 
%    Line 1 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/12/19 13:02:59; Last Revised: 2017/12/19 13:02:59

%------------- BEGIN CODE --------------

if (alpha>50)
    beta = .1102*(alpha-8.7);
elseif(alpha >= 21)
    beta = .5842*(alpha-21)^.4+.07886*(alpha-21);
else
    beta = 0;
end

%------------- END OF CODE --------------
