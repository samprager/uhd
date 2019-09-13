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
    bidata = 0;
    dcnt = 1;
    bdcnt = 1;
    for j=1:numel(dataf)
%         dataiq = conj(file2wave([outdir,dataf(j).name]));
         dataiq = (file2wave([outdir,dataf(j).name]));
        if (strfind(dataf(j).name,'-bistatic.dat'))
%            fprintf('bistatic data: %s\n',dataf(j).name);
           bidata = (bidata*(bdcnt-1)+(dataiq))/bdcnt;
           bdcnt = bdcnt+1;
        else
            data = (data*(dcnt-1)+(dataiq))/dcnt;
            dcnt = dcnt + 1;
        end
     end
    reff = dir([outdir,base,'*.ref']);
    ref = 0;
    biref = 0;
    dcnt = 1;
    bdcnt = 1;
    for j=1:numel(reff)
        refiq = (file2wave([outdir,reff(j).name]));
        if (strfind(reff(j).name,'-bistaticloopback.ref'))
%            fprintf('bistatic ref: %s\n',reff(j).name);
           biref = (biref*(bdcnt-1)+(refiq))/bdcnt;
           bdcnt = bdcnt+1;
        else
            ref = (ref*(dcnt-1)+(refiq))/dcnt;
            dcnt = dcnt + 1;
        end
%          ref = (ref*(j-1)+(refiq))/j;
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

    indC = strfind(s{1},'RX Freq');
    ind = find(not(cellfun('isempty', indC)));
    rxfreq = str2double(s{2}{ind(1)});

    indC = strfind(s{1},'TX Freq');
    ind = find(not(cellfun('isempty', indC)));
    txfreq = str2double(s{2}{ind(1)});

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
        if (numel(ind)>1)
            if(contains(s{2}{ind(2)},'Filename'))
                vitatimes = zeros(numel(s{1})-ind(2),1);
                pulsenames = {};

                for ii=(ind(2)+1):numel(s{1})
                    vitatimes(ii-ind(2))=str2double(s{1}{ii});
                    pulsenames = {pulsenames{:},s{2}{ii}};
                end
                trials(i).vitatimes=vitatimes;
                trials(i).pulsenames=pulsenames;
            end
        end
    end

    indC = strfind(s{1},'Vita Timestamps');
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

    indC = strfind(s{1},'TOF sync');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).tofsync = 0;
    if (ind>0)
        tofsync = str2double(s{2}{ind(1)});
        trials(i).tofsync = tofsync;
    end
    indC = strfind(s{1},'TOF local');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).toflocal = 0;
    if (ind>0)
        toflocal = str2double(s{2}{ind(1)});
        trials(i).toflocal = toflocal;
    end
    indC = strfind(s{1},'Fslope');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).fslope = 0;
    if (ind>0)
        fslope = str2double(s{2}{ind(1)});
        trials(i).fslope = fslope;
    end
    indC = strfind(s{1},'Sync Slot');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).syncslot = 0;
    if (ind>0)
        syncslot = str2double(s{2}{ind(1)});
        trials(i).syncslot = syncslot;
    end
    indC = strfind(s{1},'nsensors');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).nsensors = 1;
    if (ind>0)
        nsensors = str2double(s{2}{ind(1)});
        trials(i).nsensors = nsensors;
    end
    indC = strfind(s{1},'TOF Sync Matrix');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).tofsync_mtx = [];
    if (ind>0)
        tofsync_mtx = s{2}{ind(1)};
        if(numel(tofsync_mtx)>2)
            tofsync_mtx = textscan(tofsync_mtx(2:end-1),'%f',Inf,'Delimiter',';');
            tofsync_mtx = [tofsync_mtx{:}];
            trials(i).tofsync_mtx = reshape(tofsync_mtx,sqrt(numel(tofsync_mtx)),sqrt(numel(tofsync_mtx))).';
        end
    end
    indC = strfind(s{1},'TOF Local Matrix');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).toflocal_mtx = [];
    if (ind>0)
        toflocal_mtx = s{2}{ind(1)};
        if(numel(toflocal_mtx)>2)
            toflocal_mtx = textscan(toflocal_mtx(2:end-1),'%f',Inf,'Delimiter',';');
            toflocal_mtx = [toflocal_mtx{:}];
            trials(i).toflocal_mtx = reshape(toflocal_mtx,sqrt(numel(toflocal_mtx)),sqrt(numel(toflocal_mtx))).';
        end
    end
    indC = strfind(s{1},'Freq Slopes');
    ind = find(not(cellfun('isempty', indC)));
    trials(i).fslopes = [];
    if (ind>0)
        fslopes_str = s{2}{ind(1)};
        if (numel(fslopes_str)>0)
            fslopes = textscan(fslopes_str,'%f');
            trials(i).fslopes = [fslopes{:}].';
        end
    end
    indC = strfind(s{1},'Phase Errors');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        perrors_str = s{2}{ind(1)};
        if (numel(perrors_str)>0)
            perrors = textscan(perrors_str,'%f');
            trials(i).phase_errors = [perrors{:}].';
        else
            trials(i).phase_errors = [];
        end
    end
    indC = strfind(s{1},'Max peaks 1 [db]');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        mp1_str = s{2}{ind(1)};
        if (numel(mp1_str)>0)
            mp1 = textscan(mp1_str,'%f');
            trials(i).tof_maxpeak1 = [mp1{:}].';
        end
    end
    indC = strfind(s{1},'Max peaks 2 [db]');
    ind = find(not(cellfun('isempty', indC)));
    if (ind>0)
        mp2_str = s{2}{ind(1)};
        if (numel(mp2_str)>0)
            mp2 = textscan(mp2_str,'%f');
            trials(i).tof_maxpeak2 = [mp2{:}].';
        end
    end
    % replace tofsync with matrix value if empty
    if ((trials(i).tofsync==0)&&(trials(i).nsensors>1) && (all(size(trials(i).tofsync_mtx)==[trials(i).nsensors,trials(i).nsensors])) && (trials(i).syncslot <= trials(i).nsensors))
      if (trials(i).syncslot==1)
        trials(i).tofsync = trials(i).tofsync_mtx(1,2);
      else
        trials(i).tofsync = trials(i).tofsync_mtx(trials(i).syncslot,1);
      end
    end
    % replace toflocal with matrix value if empty
    if ((trials(i).toflocal==0)&&(trials(i).nsensors>1) && (all(size(trials(i).toflocal_mtx)==[trials(i).nsensors,trials(i).nsensors])) && (trials(i).syncslot <= trials(i).nsensors))
      if (trials(i).syncslot==1)
        trials(i).toflocal = trials(i).toflocal_mtx(1,2);
      else
        trials(i).toflocal = trials(i).toflocal_mtx(trials(i).syncslot,1);
      end
    end
    % replace fslope with matrix value if empty
    if ((trials(i).fslope==0)&&(trials(i).nsensors>1) && (numel(trials(i).fslopes)==(trials(i).nsensors-1)) && (trials(i).syncslot <= trials(i).nsensors))
      trials(i).fslope = trials(i).fslopes(1,1);
    end

    trials(i).txfreq = rxfreq;
    trials(i).rxfreq = txfreq;
    trials(i).freq = freq;
    trials(i).rxpower = rxpower;
    trials(i).txpower = txpower;
    trials(i).rxgain = rxgain;
    trials(i).txgain = txgain;
    trials(i).data = data;
    trials(i).ref = ref;
    trials(i).awglen = awglen;

    if (numel(bidata)>1)
        trials(i).bidata = bidata;
    end
    if (numel(biref)>1)
        trials(i).biref = biref;
    end
end

[~,inds] = sort([trials.freq]);
trials = trials(inds);
end
%------------- END OF CODE --------------
