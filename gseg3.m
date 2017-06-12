function [ regIm, CL ] = gseg3( I, TH, sigma, xzrat )
%sigma=8 is default value
%TH=0.15 is default value
Kp = 100; %Proportional constant
sec = -1; %Sections
trailId = 1; %Starting trail Id at 1
R = 10; %Radius of settling basin

s = size(I);


trailM = int16(zeros(s(1).*s(2),1)); %Vector that tells which trails belong to which regions


Ilog = zeros(s); %Holds the region settling areas and trails
CL = zeros(5000, 9); %Matrix that holds the cell location information

%Filter each z stack with a Gaussian convolution from the given variance
%sigma
disp('Filtering 3D image')

I3Gmag = zeros(s);
I3Gdir = zeros(s);
for z=1:s(3)
    I(:,:,z) = imgaussfilt(I(:,:,z),sigma);
    [I3Gmag(:,:,z), I3Gdir(:,:,z)] = imgradient(I(:,:,z),'sobel');
end

Ixz = yStacks(I); %Create orthogonal view images of I in order to get the gradient in the z direciton
disp('Getting gradient in z direction');
I3Gmagy = zeros(s(3),s(2),s(1));
I3Gdiry = zeros(s(3),s(2),s(1));
for y=1:s(1)
    [I3Gmagy(:,:,y), I3Gdiry(:,:,y)] = imgradient(Ixz(:,:,y),'sobel');
end

Gmagz = yStacks(I3Gmagy); %Undo the orthogonal operator for the gradient
Gdirz = yStacks(I3Gdiry);

clear I3Gmagy
clear I3Gdiry

Gx = I3Gmag.*cosd(I3Gdir); %Calculates the gradient values for x, y, and z
Gy = -1.*I3Gmag.*sind(I3Gdir);
Gz = -1.*Gmagz.*sind(Gdirz);

clear I3Gmag
clear I3Gdir


Xs = zeros(s(1),s(2)); %Xs, Ys, and Zs are used for creating the radius
Ys = zeros(s(1),s(2));
for row=1:s(1)
    for col=1:s(2)
        Xs(row,col) = col;
        Ys(row,col) = row;
    end
end

Ibw = zeros(s); %Mask for activity regions
disp('Thresholding images');
for z=1:s(3)
    Ibw(:,:,z) = im2bw(I(:,:,z),TH); %Thresholding the image to mask only activity in the GFP channel
end
xStep = Kp.*Gx.*Ibw; %Proportional gradients
yStep = Kp.*Gy.*Ibw;

disp('Finding cell locations by regional maximum locations');
Ilog1 = imregionalmax3(I).*Ibw; %Finds local maximums of a 3D image

disp('Creating settling regions');
for z=1:s(3) %Going through each element in the logical image and adding disks
    for row=1:s(1)
        for col=1:s(2)
            if(Ilog1(row,col,z)==1) %If this is the location of a local maximum                
                if~(Ilog(row,col,z)==0) %If the pixel is already assigned to a settling region
                    continue; %Ignore it
                end
                CL((-sec),1:3) = [col, row, z]; %Store cell COM location
                Irg = im2double(sqrt((col-Xs).^2+(row-Ys).^2)<R); 
                Ilog(:,:,z) = Ilog(:,:,z) + Irg.*im2double(Ilog(:,:,z)==0).*sec; %Inserting a disk
                if~(z==1)
                    Ilog(:,:,z-1) = Ilog(:,:,z-1) + Irg.*im2double(Ilog(:,:,z-1)==0).*sec; %Inserting a disk
                end
                if~(z==s(3))
                    Ilog(:,:,z+1) = Ilog(:,:,z+1) + Irg.*im2double(Ilog(:,:,z+1)==0).*sec; %Inserting a disk
                end
                sec = sec-1;
            end
        end
    end
end
CL = CL(1:(-sec)-1,:);
CL(:,4) = CL(:,1); %This is so we can find minimums
CL(:,6) = CL(:,2);
CL(:,8) = CL(:,3);


regIm = zeros(s); %Final image that will contain the segmented regions
disp('Segmenting regions');
for z=1:s(3) %Going through each element in the proportional gradient matrices
    for row=1:s(1)
        for col=1:s(2)
            if(Ibw(row,col,z)==0) %Don't consider areas not found in the mask image
                continue;
            end
            xd = col; %Dynamic pixel starts at the static pixel location
            yd = row;
            zd = z;
            while(Ilog(yd,xd,zd)==0) %As long as we are seeing pixels that have never seen activity
                Ilog(yd,xd,zd) = trailId; %Mark trail
                
                %Find new dynamic pixel
                delx = xStep(yd,xd,zd); %New delta x and y
                dely = yStep(yd,xd,zd);
                
                %Calculating the z step
                if~(zd==1||zd==s(3)) %Demorgans law for z is not at the edges
                    delz = Gz(yd,xd,zd); %Gradient in z direction
                    if~(delz==0) %z gradient can only be 1 or -1
                        delz = double(-(delz<0)+(delz>0));
                    else 
                        delz=0;
                    end
                elseif(zd==s(3))
                    delz = double((I(yd,xd,zd)-I(yd,xd,zd-1))<0)*(-1); %Gradient is 0 or negative
                else %zd has to be 1
                    delz = double((I(yd,xd,zd+1)-I(yd,xd,zd))>0); %Gradient is 0 or positive
                end
                
                if(abs(delx)<1) %Proportional x step
                    delx = double((delx>0) - (delx<0));
                else
                    delx = round(delx);
                end
                if(abs(dely)<1) %Proportional y step
                    dely = double((dely>0) - (dely<0));
                else
                    dely = round(dely);
                end
                
                xd = xd+delx; %Quick increments
                yd = yd+dely;
                zd = zd+delz;
                
                if(Ibw(yd,xd,zd)==0) %If the dynamic pixel drifts out of the mask image
                    break;
                end
            end

            if(Ibw(yd,xd,zd)==0||Ilog(yd,xd,zd)==trailId)
                disV = sqrt((CL(:,1)-col).^2+(CL(:,2)-row).^2+(CL(:,3).*xzrat-z*xzrat).^2); %Distance from COM locations
                [~,location] = min(disV);
                trailM(trailId) = -location;
                regIm(row,col,z) = -1*trailM(trailId); %Store in region Image
                trailId = trailId+1;
                continue;
            end
            
            if(Ilog(yd,xd,zd)<0) %We have found a settling region
                trailM(trailId) = Ilog(yd,xd,zd);
            else %We have found an old trail
                trailM(trailId) = trailM(Ilog(yd,xd,zd));
            end
            regId = -1*trailM(trailId);
            regIm(row,col,z) = regId; %Store in region Image of the static pixel
            trailId = trailId+1;
            rCL = CL(regId,:);
            
            if(col<rCL(4)) %New x1 or x2
                CL(regId,4)=col;
            elseif(col>rCL(5))
                CL(regId,5)=col;
            end
            if(row<rCL(6)) %New y1 or y2
                CL(regId,6)=row;
            elseif(row>rCL(7))
                CL(regId,7)=row;
            end
            if(z<rCL(8)) %New z1 or z2
                CL(regId,8)=z;
            elseif(z>rCL(9))
                CL(regId,9)=z;
            end
        end
    end
end

trailM = trailM(1:trailId-1);

disp('Finalizing region image');
maxp = max(regIm,[],3);
maxp = max(maxp(:));
regIm = im2double(regIm)./maxp;
end

