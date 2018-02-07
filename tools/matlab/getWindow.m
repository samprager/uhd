function win = getWindow(windowstr,Ns)
%FUNCTION_NAME - Get window function from string name
%
% Syntax:  win = getWindow(windowstr,Ns)
%
% Inputs:
%    windowstr - window type:
%       'hamming,'hann','blackman-harris','chebyshev','root-raised-cosine','kaiser<alpha>'
%    Ns - length of window
%
% Outputs:
%    win - window function
%
% Example: 
%    win = getWindow('hamming',Ns)
%    win = getWindow('kaiser100',Ns)
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
% Created: 2018/01/19 14:37:18; Last Revised: 2018/01/19 14:37:18
%
% Copyright 2012-2018 University of Southern California
%------------- BEGIN CODE --------------

    if(strcmp(windowstr,'tukey'))
    % tukey window
        win = tukeywin(Ns,0.2).';
    elseif(strcmp(windowstr,'hamming'))
    % hamming window
        k_win = .54;
        win = k_win-(1-k_win)*cos(2*pi*(0:(Ns-1))/(Ns-1));
    elseif(strcmp(windowstr,'hann'))
    % hann window
        k_win = .5;
        win = k_win-(1-k_win)*cos(2*pi*(0:(Ns-1))/(Ns-1));
    elseif(strcmp(windowstr,'blackman-harris'))
    % blackman-harris window
        a_0=0.35875;a_1=0.48829; a_2=0.14128;a_3=0.01168;
        win = a_0-a_1*cos(2*pi*(0:(Ns-1))/(Ns-1))+a_2*cos(4*pi*(0:(Ns-1))/(Ns-1))-a_3*cos(6*pi*(0:(Ns-1))/(Ns-1));
    elseif(strcmp(windowstr,'root-raised-cosine'))
    % root raised cosine window
        k_win = .54;
        win = k_win-(1-k_win)*cos(pi*n/(Ns-1)).^2;
    elseif(strcmp(windowstr,'chebyshev'))
    % dolph-chebyshev window
        win = chebwin(Ns).';
    elseif(contains(windowstr,'kaiser'))
        alpha=sscanf(windowstr,'kaiser%g');
        beta = kaiser_beta(alpha);
        win = kaiser(Ns,beta).';
    else
        win = 1;
    end

%------------- END OF CODE --------------
