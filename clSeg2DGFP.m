function [ CL ] = clSeg2DGFP( I3D, TM )
h = fspecial('disk',10);
s = size(I3D);
If = zeros(s);
Ith = zeros(s);
Imax = zeros(s);
Ilog = zeros(s);
CL = [];
ID = 1;

for z=1:s(3)
    If(:,:,z) = imfilter(I3D(:,:,z),h,'replicate');
    Ith(:,:,z) = If(:,:,z).*im2bw(If(:,:,z),0.15);
    if(max(max(Ith(:,:,z)))==0)
        continue;
    end
    Imax(:,:,z) = imregionalmax(Ith(:,:,z));
    Iws = im2double(watershed(1-If(:,:,z)));
    maxp = max(Iws(:));
    Iws=Iws./maxp;
    Iws = im2bw(Iws,0.0001).*im2bw(If(:,:,z),0.15);
    
    for y=1:s(1)
        for x=1:s(2)
            if(Imax(y,x,z)==1)
                if(Ilog(y,x,z)==1)
                    continue;
                end
                [~,T]=findRegion(Iws,x,y,1);
                [~,B]=findRegion(Iws,x,y,2);
                [R,~]=findRegion(Iws,x,y,3);
                [L,~]=findRegion(Iws,x,y,4);
                
                CL = [CL;ID TM x y z R L T B];
                ID = ID+1;
                Ilog(T:B,L:R,z) = zeros(B-T+1,R-L+1)+1;
            end
        end
    end
end
end

