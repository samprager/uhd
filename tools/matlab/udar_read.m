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
%     for j=1:size(s{1},1)
%         s{1}{j}
%         s{2}{j}
%         key = strrep(s{1}{j},' ','_');
%         key = strrep(key,'(%)','');
%         v = str2double(s{2}{j});
%         if(isfinite(v))
%             trials(i).(key) = v;
%         else
%             trials(i).(key) = s{2}{j};
%         end
%     end
    
    
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
    if (ind>0)
        txpower = str2double(s{2}{ind(1)});
    else
        txpower = 0;
    end
    
    indC = strfind(s{1},'RX Gain');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        rxgain = str2double(s{2}{ind(1)});
    else
        rxgain = 0;
    end
    indC = strfind(s{1},'TX Gain');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        txgain = str2double(s{2}{ind(1)});
    else
        txgain = 0;
    end
    indC = strfind(s{1},'Sample Rate');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        fs = str2double(s{2}{ind(1)});
        trials(i).fs = fs;
    else
        fs = 0;
    end
    
    indC = strfind(s{1},'AWG file');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        awgfile = s{2}{ind(1)};
        trials(i).awgfile = awgfile;
    end

    indC = strfind(s{1},' Wavegen Real Sec');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        wavegentime = str2double(s{2}{ind(1)});
        trials(i).wavegentime = wavegentime;
    end
    
    indC = strfind(s{1},'Radio Real Sec');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        radiotime = str2double(s{2}{ind(1)});
        trials(i).radiotime = radiotime;
    end
    
    indC = strfind(s{1},'Timestamp');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        armtime = s{2}{ind(1)};
        trials(i).armtime = armtime;
    end

    indC = strfind(s{1},'gps_time');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        gpstime = str2double(s{2}{ind(1)});
        trials(i).gps_time = gpstime;
    end
    
    indC = strfind(s{1},'gps_position');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        gps_position = s{2}{ind(1)};
        v = textscan(gps_position,'%f deg %f deg %fm)');
        trials(i).gps_position = gps_position;
        trials(i).gps_vec = [v{:}];
    end
    
    indC = strfind(s{1},'IMU');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        imu = s{2}{ind(1)};
        trials(i).imu = imu;
    end
    
    indC = strfind(s{1},'Device');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        device = s{2}{ind(1)};
        trials(i).device = device;
    end
    
    trials(i).freq = freq;
    trials(i).rxpower = rxpower;
    trials(i).txpower = txpower;
    trials(i).rxgain = rxgain;
    trials(i).txgain = txgain;
    trials(i).data = data;
    trials(i).ref = ref;
    trials(i).awglen = awglen;
end

[~,inds] = sort([trials.freq]);
trials = trials(inds);
end
%------------- END OF CODE --------------
