function BVTconfig( )
%Highest level function in BVT framework.  This function takes in
%information from the user or a configuration file to be used for the
%data analysis.

tmStart = input('Which time stamp do you want to be evaluated first? ');
tmEnd = input('Which time stamp do you want to be evaluated last? ');
sprd = input('Is the GFP data at low contrast? (1 - yes, 0 - no) ');
if(sprd==1)
    spm = input('Which specimen do you want to view? ');
    for t=tmStart:tmEnd
        disp(['Writing max projection for time ' num2str(t) ' of ' num2str(tmEnd)])
        [I,~] = microImInputRaw(spm,t,1,1);
        if t==tmStart
            [I,minp,maxp] = spreadPixelRange(I);
        else
            I = (I-minp)./maxp;
        end
        imwrite(max(I,[],3),'max3dprojtm1.tif','writemode','append');
    end
end
TH = zeros(tmEnd-tmStart+1,1);
THtmp = input('What is the normalized (0-1) threshold value for GFP activity?');
for t=tmStart:tmEnd
    TH(t) = THtmp;
end
xPix = input('What is the pixel distance in microns for the x and y directions? ');
yPix = xPix;
zPix = input('What is the pixel distance in microns for the z direction? ');
xyratz = zPix/xPix;

clear I;
clear zTest;
clear z;
clear t;
clear THtmp

save('data_config');
end

