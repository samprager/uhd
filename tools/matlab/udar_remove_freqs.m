remove_freqs = {'971mhz', '1009mhz', '1046mhz'}

outdir = '~/.x300_Client/outputs/uasnow_flighttest_mar12_1500mhzbw_from625_bweff80_caloff_avg4_ts600_flight7pitnotched-B'

if (~strcmp(outdir(end),'/')&&(isunix))
    outdir = [outdir,'/'];
elseif (~strcmp(outdir(end),'\')&&(ispc))
    outdir = [outdir,'\'];
end

deldir = [outdir,'deleted/'];
if (exist(deldir)==0)
    mkdir(deldir);
end

fids = dir(outdir);
dirflags = [fids.isdir];
subfolders = fids(dirflags);

numtotalswps = numel(subfolders);

numtotalswps = numtotalswps-3; % 'deleted/', './', and '../' don't count
if (numtotalswps<1)
    error('unable to find valid sweep directories in %s',outdir);
end

for i=1:numtotalswps
    deldir_swp = [deldir,sprintf('sweep-%i/',i-1)];
    if (exist(deldir_swp)==0)
        mkdir(deldir_swp);
    end
    fids = dir([outdir,sprintf('sweep-%i/',i-1)]);
    fileflags = ~[fids.isdir];
    subfiles = fids(fileflags);
    for j=1:numel(subfiles)
        fname = subfiles(j).name;
        for k=1:numel(remove_freqs)
            if (contains(fname,remove_freqs{k}))
                sprintf('sweep %i:removing file: %s\n',(i-1),fname)
                movefile([subfiles(j).folder,'/',fname],deldir_swp);
                continue;
            end
        end
    end
end