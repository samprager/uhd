function detections = peak_detect(filtiq,dataiq,fs,er,name,lpf_div) 
c = 3e8;
vel = c/sqrt(er);
fig_h = figure;
logscale = 1;
rng_offset = 35;
    if (numel(filtiq) < numel(dataiq))
        filtiq = [filtiq,zeros(1,numel(dataiq)-numel(filtiq))];
    end
    [acor,lag] = xcorr(dataiq,filtiq);
    start = find(lag==0)+1;
    acor = acor(start:end);
    lag = lag(start:end);
    range = lag*(vel/(2*fs))-rng_offset;
%     x1 = floor(numel(acor)/2)+130; x2 = x1+60;
    x1 = 100; x2 = 300*(ceil(numel(dataiq)/4096));
    len = numel(dataiq);
    acor_filt = fft(dataiq,len).*conj(fft(filtiq,len));
    %acor_filt(ceil(end/2):end) = 0;
    acor_filt = abs(ifft(acor_filt,len/lpf_div));
    
   % Constant false alaram rate threshold
    windowSize = 140;
    cfar_const = 3.98;
    IQ_cfar_thresh = cfar_const*cfar(acor_filt,windowSize,'caso');
    
    IQ_cfar = abs(acor_filt);
    IQ_cfar(IQ_cfar<IQ_cfar_thresh) = 0;
    [IQ_cfar_val, IQ_cfar_ind] = findpeaks(IQ_cfar);
%     IQ_cfar_rng = (IQ_cfar_ind+lag(1)-1)*(c/(2*fs))-113;
    [p, ind] = sort(IQ_cfar_val,'descend');
    m = IQ_cfar_ind(ind(1:min(20,end)));
    cut = 100;
    maxinds = m(((range(m)>=(range(m(1))))&(range(m)<=(range(m(1))+cut))));
    %IQ_cfar_rng = (maxinds+lag(1)-1)*(c/(2*fs))-113;
    IQ_cfar_rng = range(maxinds);
    IQ_cfar_val = IQ_cfar(maxinds);
    
    detection_rng = IQ_cfar_rng(min(2,end));
    detection_val = IQ_cfar_val(min(2,end));
    
       % Constant false alaram rate threshold
    if(numel(maxinds)>=3)
        IQ_cfar2 = abs(acor_filt(maxinds(2):maxinds(2)+cut));

        windowSize = 20;
        cfar_const = 1.6;
        IQ_cfar_thresh2 = cfar_const*cfar(IQ_cfar2,windowSize);

 %       figure; hold on; plot(20*log10(IQ_cfar_thresh2)); plot(20*log10(IQ_cfar2)); legend('thresh','data');title('iq cfar2');

        IQ_cfar2(IQ_cfar2<IQ_cfar_thresh2) = 0;
        [IQ_cfar_val2, IQ_cfar_ind2] = findpeaks(IQ_cfar2);
    %     IQ_cfar_rng = (IQ_cfar_ind+lag(1)-1)*(c/(2*fs))-113;
        [p, ind] = sort(IQ_cfar_val2,'descend');
        m = IQ_cfar_ind2(ind(1:min(20,end)));
        maxinds2 = m;
        %IQ_cfar_rng = (maxinds+lag(1)-1)*(c/(2*fs))-113;
        matching = ismember(maxinds2+maxinds(2)-1,maxinds);
        IQ_cfar_rng2 = range(maxinds2+maxinds(2)-1);
        IQ_cfar_val2 = IQ_cfar2(maxinds2);
        if(sum(matching)==0)
            detection_rng2 = IQ_cfar_rng(min(2,end));
            detection_val2 = IQ_cfar_val(min(2,end));
        else
            detection_rng2 = IQ_cfar_rng2(min(1,end));
            detection_val2 = IQ_cfar_val2(min(1,end));
        end
    else
            IQ_cfar_rng2 = [];
            IQ_cfar_val2 = [];
    
            detection_rng2 = IQ_cfar_rng(min(2,end));
            detection_val2 = IQ_cfar_val(min(2,end));
    end
    
%     figure; area(range(x1:x2),20*log10(abs(acor_filt(x1:x2)))-40); 
    
%     if(logscale)
%         figure(h2); hold on; plot(range(x1:x2),20*log10(abs(acor(x1:x2)))); hold off; axis tight; grid on;     
%     else 
%         figure(h2); hold on; plot(range(x1:x2),abs(acor(x1:x2))); hold off; axis tight; grid on;
%     end
    
        if(logscale)
            figure(fig_h); hold on;
            plot(range(x1:x2),20*log10(abs(acor_filt(x1:x2)))); 
            plot(range(x1:x2),20*log10(abs(IQ_cfar_thresh(x1:x2))));
            scatter(detection_rng,20*log10(detection_val),100,'MarkerEdgeColor','cyan');
            scatter(detection_rng2,20*log10(detection_val2),250,'MarkerEdgeColor','magenta','LineWidth',1.5);
            scatter(IQ_cfar_rng,20*log10(IQ_cfar_val),'MarkerEdgeColor',[0 .5 .7]); 
            scatter(IQ_cfar_rng2,20*log10(IQ_cfar_val2),'MarkerEdgeColor',[0 .5 .7]); 
            hold off; axis tight; grid on;

        else 
            figure(fig_h); hold on;
            plot(range(x1:x2),(abs(acor_filt(x1:x2)))); 
            plot(range(x1:x2),(abs(IQ_cfar_thresh(x1:x2))));
            scatter(detection_rng,detection_val,100,'MarkerEdgeColor','cyan');
            scatter(detection_rng2,(detection_val2),250,'MarkerEdgeColor','magenta','LineWidth',1.5);
            scatter(IQ_cfar_rng,IQ_cfar_val); 
            scatter(IQ_cfar_rng2,(IQ_cfar_val2));             
            hold off; axis tight; grid on;
        end
figure(fig_h); legend({'Acorr','Threshold','Initial Guess','Final Detection','candidates'}); 
title([name,' Detection: ',sprintf('%g m',detection_rng2)]);

detections = [detection_rng,detection_val;detection_rng2 detection_val2];
end