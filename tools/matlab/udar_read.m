function trials = udar_read(outdir)
%udar_read - parses config.txt outputs from UDAR usrp and averages data
%from multiple trials
%
% Inputs:
%    outdir - directory or folder containing test outputs with config.txt
%    descriptor files
%
% Outputs:
%    trials - struct array containing fields:
%         name
%         date
%         bytes
%         isdir
%         datenum
%         freq
%         data
%
%
% Other m-files required: file2wave.m
%
% See also: file2wave,  wave2file

% Author: Samuel Prager
% University of Southern California
% email: sprager@usc.edu
% Created: 2017/04/06 01:03:52; Last Revised: 2017/04/06 01:03:52

%------------- BEGIN CODE --------------
if (~strcmp(outdir(end),'/')&&(isunix))
    outdir = [outdir,'/'];
elseif (~strcmp(outdir(end),'\')&&(ispc))
    outdir = [outdir,'\'];
end

trials = dir([outdir,'*-config.txt']);
for i=1:numel(trials)
    [d, base, ext] = fileparts(trials(i).name);
    base = strrep(base,'-config','');
    dataf = dir([outdir,base,'*.dat']);
    data = 0;
    for j=1:numel(dataf)
        dataiq = conj(file2wave([outdir,dataf(j).name]));
        data = (data*(j-1)+(dataiq))/j;
    end
    fid = fopen([outdir,trials(i).name]);
    s = textscan(fid,'%s %s','Delimiter',':','CommentStyle','--');
    fclose(fid);
    indC = strfind(s{1},'Freq');
    ind = find(not(cellfun('isempty', indC)));
    freq = str2double(s{2}{ind(1)});
    indC = strfind(s{1},'RX power dBm');
    ind = find(not(cellfun('isempty', indC)));
    rxpower = str2double(s{2}{ind(1)});
    indC = strfind(s{1},'TX power dBm');
    ind = find(not(cellfun('isempty', indC)));
    txpower = str2double(s{2}{ind(1)});
    trials(i).freq = freq;
    trials(i).rxpower = rxpower;
    trials(i).txpower = txpower;
    trials(i).data = data;
end
end
%------------- END OF CODE --------------
