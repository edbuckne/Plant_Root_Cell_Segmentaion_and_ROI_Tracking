function [ I, I_PROJ ] = microImInputRaw( SPM, TM, CM, NUM )
    
    SPMstr = num2str(SPM,'%.2d'); %Create strings for each parameter
    TMstr = num2str(TM,'%.4d');
    CMstr = num2str(CM,'%.1d');
    
    fileName = ['/SPM' SPMstr '/TM' TMstr '/SPM' SPMstr '_TM' TMstr '_CM' CMstr '_CHN00_PLN']; %Path to raw images
    
    for i=1:NUM %Obtain each image
        I(:,:,i) = im2double(imread([pwd fileName num2str(i,'%.2d') '.tif']));
    end
    I_PROJ = max(I,[],3);
end
