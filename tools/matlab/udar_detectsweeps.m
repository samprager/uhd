function numtotalswps = udar_detectsweeps(outdir)
    fids = dir(outdir);
    dirflags = [fids.isdir];
    subfolders = fids(dirflags);
    numtotalswps = numel(subfolders)-2; % don't include '..', '.'
end