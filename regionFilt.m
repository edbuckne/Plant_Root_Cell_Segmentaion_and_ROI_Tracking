function regionFilt( FileName1, FileName2, Iterations )
maskNum = (2^16)-1;

[X1,map1]=imread(FileName1);
% figure(1)
% imshow(X1)

[X2,map2]=imread(FileName2);
figure(2)
imshow(X2)


% if ~isempty(map)
%     Im = ind2rgb(X,map);
% end

SZ1 = size(X1); SZ2 = size(X2);
totSZ1 = SZ1(1)*SZ1(2);
totSz2 = SZ2(1)*SZ2(2);

X1C = histeq(X1);
figure(3)
imshow(X1C)

greenImProj = zeros(SZ2(1),SZ2(2),3);
%Filter out everything that isn't showing flouresence
for x=1:SZ2(1)
    for y=1:SZ2(2)
        if(X2(x,y) > 7000)
            X2(x,y) = 0;
            greenImProj(x,y,2) = 1.00;
        else
            X2(x,y) = 2^16-1;
        end
    end
end

figure(6)
imshow(greenImProj)

redImProj = zeros(SZ2(1),SZ2(2),3);
%Create a red image of wideband picture
for x=1:SZ1(1)
    for y=1:SZ1(2)
            redImProj(x,y,1) = 1;
            redImProj(x,y,2) = 1-double(X1C(x,y))/double(maskNum);
            redImProj(x,y,3) = 1-double(X1C(x,y))/double(maskNum);
    end
end



for x=1:SZ2(1)
    for y=1:SZ2(2)
        if(X2(x,y) < 7000)
            redImProj(x,y,1) = 0;
            redImProj(x,y,2) = 1;
            redImProj(x,y,3) = 0;
        end
    end
end

figure(4)
imshow(redImProj)
% for i=1:totSz2
%     if(X2(i) == 0)
%         X1C(i) = 0;
%     end
% end
% 
% figure(5)
% imshow(X1C)
% imshow(X2)
% imwrite(X2,'TestPicContrasted.tif')

% for j=1:Iterations
%     for i=1:totSZ
%         X2(i) = X2(i)-5000;
%     end
%     %X2 = histeq(X2);
% end


end


