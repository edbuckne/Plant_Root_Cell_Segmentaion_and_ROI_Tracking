function [ I, I_PROJ ] = microImInputRaw( SPM, TM, CM, NUM, VIEW )
    
    SPMstr = num2str(SPM,'%.2d'); %Create strings for each parameter
    TMstr = num2str(TM,'%.4d');
    CMstr = num2str(CM,'%.1d');
    VIEWstr = num2str(VIEW);
    
    for i=1:NUM %Obtain each image
        Zstr = num2str(i,'%.3u');
        fileName = ['/SPM' SPMstr '/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif']; %Path to raw images
        I(:,:,i) = im2double(imread([pwd fileName]));
    end
    I_PROJ = max(I,[],3);
end
