

outdir = '~/.x300_Client/outputs/uasnow_flighttest_feb2_2021_fullmimo_bistaticonly_1000mhzbw_from2500_bweff80_ts600_flight2-B'

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
        if (contains(fname,'-mimo.dat'))
            fnamemove = strrep(fname,'-mimo.dat','.dat');
            movefile([subfiles(j).folder,'/',fname],[subfiles(j).folder,'/',fnamemove]);
        elseif (contains(fname,'-mimoloopback.ref'))
            fnamemove = strrep(fname,'-mimoloopback.ref','-loopback.ref');
            movefile([subfiles(j).folder,'/',fname],[subfiles(j).folder,'/',fnamemove]);
        end
    end
end