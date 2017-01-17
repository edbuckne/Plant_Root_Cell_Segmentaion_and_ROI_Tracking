function [ mergedImage ] = mergeCellIms( WBim, GFPim, TH )

%Sizes of each image
SZWB = size(WBim); 
mergedImage = zeros(SZWB(1),SZWB(2),3);

for x=1:SZWB(2)-5
    for y=1:SZWB(1)-5
        if(GFPim(y,x,1)<TH && ~(WBim(y,x,3)==1)) %If floresence area, paint if not black
            mergedImage(y,x,1) = GFPim(y,x,1);
        else %Else, keep original image
            mergedImage(y,x,1) = WBim(y,x,1);
            mergedImage(y,x,2) = WBim(y,x,2);
            mergedImage(y,x,3) = WBim(y,x,3);
        end
    end
end
end

