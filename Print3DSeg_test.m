s = size(seg3D);
sim = size(I1);
rgbMatrix = zeros(s(1),3);
colArray = linspace(400,700,s(1));
for i=1:s(1)
    i/s(1)
    rgbMatrix(i,:) = spectrumRGB(colArray(i));
end

for z=1:sim(3)
    z/sim(3)
    rgb = zeros(sim(1),sim(2),3);
    rgb2 = zeros(sim(1),sim(2),3);
    rgb(:,:,1)=I1(:,:,z); rgb(:,:,2)=I1(:,:,z); rgb(:,:,3)=I1(:,:,z);
    rgb2(:,:,1)=I1(:,:,z); rgb2(:,:,2)=I1(:,:,z); rgb2(:,:,3)=I1(:,:,z);
    for i=1:s(1)
        if(seg3D(i,9)<=z&&seg3D(i,10)>=z)
            x1=seg3D(i,5);
            x2=seg3D(i,6);
            y1=seg3D(i,7);
            y2=seg3D(i,8);
            rgb(y1:y2,x1:x2,1) = zeros(y2-y1+1,x2-x1+1)+rgbMatrix(i,1);
            rgb(y1:y2,x1:x2,2) = zeros(y2-y1+1,x2-x1+1)+rgbMatrix(i,2);
            rgb(y1:y2,x1:x2,3) = zeros(y2-y1+1,x2-x1+1)+rgbMatrix(i,3);
        end
    end
    imwrite([rgb rgb2],[pwd '/3DSegImages/I3DSeg' num2str(z) '.tif']);
end