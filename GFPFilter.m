function [ finalIm ] = GFPFilter( GFPim, RGB, TH )

SZ1 = size(GFPim); %Demensions of GFP image
finalIm = zeros(SZ1(1),SZ1(2),3); %Empty RGB image

%Filters everything that is outside of threshold value
for x=1:SZ1(1)
    for y=1:SZ1(2)
        if(GFPim(x,y) > TH)
            GFPim(x,y) = 0;
            finalIm(x,y,RGB) = 1.00;
            finalIm(x,y,1) = double(GFPim(x,y))/double((2^16)-1);
            finalIm(x,y,3) = double(GFPim(x,y))/double((2^16)-1);
        else
            GFPim(x,y) = 2^16-1;
        end
    end
end

end

