function [ Iint ] = interp3DIm( I, K, opt )
s = size(I);
mkdir interp
Iint = zeros(s(1),s(2),s(3)*K);

tmpIm = zeros(s(1),s(3));
for x=1:s(2)
    x/s(2)
    for z=1:s(3)
        tmpIm(:,z) = I(:,x,z);
    end
    intImage = imresize(tmpIm,[s(1),s(3)*K]);
    for z=1:s(3)*K
        Iint(:,x,z)=intImage(:,z);
    end
end
if(strcmp(opt,'print'))
    for z=1:s(3)*K
        imwrite(Iint(:,:,z),[pwd '/interp/I' num2str(z) '.tif']);
    end
end
end

