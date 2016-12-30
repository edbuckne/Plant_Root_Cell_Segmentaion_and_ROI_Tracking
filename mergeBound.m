function [ boundIm ] = mergeBound( virtIm, horIm )

SZ = size(virtIm); %Only need to find the size of one.  They are the same size
boundIm = zeros(SZ(1),SZ(2),3); %Empty rgb image

for x=1:SZ(2)
    for y=1:SZ(1)
        %We can find whether or not a pixel is black by multiplying the RGB
        %value of a pixel.  If it is 1, then the pixel is black.
        tmpV = (1-virtIm(y,x,1))*(1-virtIm(y,x,2))*(1-virtIm(y,x,3));
        tmpH = (1-horIm(y,x,1))*(1-horIm(y,x,2))*(1-horIm(y,x,3));
        if (tmpV==1 || tmpH==1) %If it is black, paint the new pixel black
            boundIm(y,x,1) = 0;
            boundIm(y,x,2) = 0;
            boundIm(y,x,3) = 0;
        else %Else just keep the old image
            boundIm(y,x,:) = virtIm(y,x,:);
        end
    end
end
end

