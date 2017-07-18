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
%         ref
%         fs
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
%         dataiq = conj(file2wave([outdir,dataf(j).name]));
         dataiq = (file2wave([outdir,dataf(j).name]));
 
        data = (data*(j-1)+(dataiq))/j;
    end
    reff = dir([outdir,base,'*.ref']);
    ref = 0;
    for j=1:numel(reff)
         refiq = (file2wave([outdir,reff(j).name]));
         ref = (ref*(j-1)+(refiq))/j;
    end
    fid = fopen([outdir,trials(i).name]);
    s = textscan(fid,'%s %s','Delimiter',':','CommentStyle','--');
    fclose(fid);
    
    indC = strfind(s{1},'AWG Waveform Len');
    ind = find(not(cellfun('isempty', indC)));
    awglen = str2double(s{2}{ind(1)});
    
    indC = strfind(s{1},'Freq');
    ind = find(not(cellfun('isempty', indC)));
    freq = str2double(s{2}{ind(1)});
    
    indC = strfind(s{1},'RX power dBm');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        rxpower = str2double(s{2}{ind(1)});
    else
        rxpower = 0;
    end
    indC = strfind(s{1},'TX power dBm');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>9)
        txpower = str2double(s{2}{ind(1)});
    else
        txpower = 0;
    end
    
    indC = strfind(s{1},'Sample Rate');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>9)
        fs = str2double(s{2}{ind(1)});
    else
        fs = 0;
    end
    
    trials(i).freq = freq;
    trials(i).rxpower = rxpower;
    trials(i).txpower = txpower;
    trials(i).data = data;
    trials(i).ref = ref;
    trials(i).awglen = awglen;
    trials(i).fs = fs;
end
end
%------------- END OF CODE --------------
