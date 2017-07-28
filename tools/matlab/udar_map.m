function tmap = udar_map(testdir)
% udar_map - Create a containers.Map object from a test parent directory 
% with values that are data structs for each trial. For trials with
% multiple sweeps, keys are formatted as:
%   '<parent_trial> / <sweep>'
% ie: 
%   'mytrial/sweep-0'
%
% Inputs:
%    testdir - name of parent directory containing the trials%
% Outputs:
%    tmap     - containers.Map object containing data structs.
%
% Required: udar_read

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:03:52; Last Revised: 2017/04/06 01:03:52

%------------- BEGIN CODE --------------
tests = dir(testdir);
tmap = containers.Map;
for i=1:numel(tests)
    [d,f,e] = fileparts(tests(i).name);
    if((numel(f)>0)&&(strcmp(e,''))&&tests(i).isdir)
        sweeps = dir([testdir,f,filesep,'sweep*']);
        if(numel(sweeps)==0)
            tmap(f)=udar_read([testdir,f]);
        else
            for j=1:numel(sweeps)
                if(sweeps(j).isdir)
                    tmap([f,filesep,sweeps(j).name]) = udar_read([testdir,f,filesep,sweeps(j).name]);
                end
            end
        end
    end
end
%------------- END OF CODE --------------
