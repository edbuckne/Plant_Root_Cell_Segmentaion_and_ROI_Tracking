function [ regIm, CL ] = gseg3CE( I, TH, sigma, sigma2, xzrat )
%Author: Eli Buckner
%Description:
%This function does 3D GFP segmentation on C.Elegan lightsheet images.  It
%uses the image gradient to threshold the image instead of image intensity
%(used for arabidopsis).
%   Outputs:
%       regIm = 3D segmented image.  All voxels included in the same region
%       have the same value.
%       CL = Cell location information.  Contains information concerning
%       the size and location of the segmented regions found.
%   Inputs:
%       I = 3D image to be segmented (type double)
%       TH = Double threshold value used on the gradient image, not the
%       voxel intensities.
%       sigma = Standard deviation used for the gaussian blur applied to
%       the gradient image.
%       sigma2 = Standard deviation used for the gaussian blur applied to
%       the original image.
%       xzrat = Ratio of distances between a z-stack and a pixel step in
%       the x direction.
%The Kp and R variables below can be adjusted to give different results.
%The descriptions of what these variables do are written next to them.
%
%Example: [regIm, CL] = gseg3CE(I,0.0118,3,5.2);

    Kp = 100; %Proportional constant used for gradient step sizes
    R = 5; %Radius of the cylinder used for settling regions
    
    sec = -1; %Beginning
    trailId = 1; %Starting trail Id at 1
    
    CL = zeros(5000, 9); %Matrix that holds the cell location information
    
    s = size(I); %Get the size of the image and create gradient images
    IgradMag = zeros(s); %Variable that holds the xy planar gradient magnitudes
    IgradDir = zeros(s); %Variable that hold the xy planar gradient directions
    IgradTH = zeros(s); %Variable that holds the 3D image that is thresholded
    
    disp('Obtaining 3D gradient fields')
    for z=1:s(3) 
        [IgradMag(:,:,z), IgradDir(:,:,z)] = imgradient(I(:,:,z),'sobel'); %Obtain gradients of images and filter the gradient magnitude
        IgradMag(:,:,z) = imgaussfilt(IgradMag(:,:,z),sigma);
        IgradTH(:,:,z) = im2bw(IgradMag(:,:,z),TH); %Threshold image
        
        I(:,:,z) = imgaussfilt(I(:,:,z),sigma2); %Filter the original image to reduce noise
    end
    
    Ixz = yStacks(I); %Obtain gradients in the z direction by creating xz view images
    I3Gmagy = zeros(s(3),s(2),s(1));
    I3Gdiry = zeros(s(3),s(2),s(1));
    for y=1:s(1)
        [I3Gmagy(:,:,y), I3Gdiry(:,:,y)] = imgradient(Ixz(:,:,y),'sobel');
    end
    Gmagz = yStacks(I3Gmagy); %Undo the orthogonal operator for the gradient
    Gdirz = yStacks(I3Gdiry);
    clear Ixz %Clear these variables to save RAM space
    clear I3Gmagy
    clear I3Gdiry
    
    Gx = IgradMag.*cosd(IgradDir); %Calculates the gradient values for x, y, and z
    Gy = -1.*IgradMag.*sind(IgradDir); %Sines are negative because the y coordinate in images increases going down
    Gz = -1.*Gmagz.*sind(Gdirz);
    clear IgradMag %Clear these variables to save RAM space
    clear IgradDir
    clear Gmagz
    clear Gdirz
    
    Xs = zeros(s(1),s(2)); %Xs, Ys, and Zs are used for creating a volume for the settling regions
    Ys = zeros(s(1),s(2));
    for row=1:s(1)
        for col=1:s(2)
            Xs(row,col) = col; %The position that the pixel is in is the value at that pixel
            Ys(row,col) = row;
        end
    end
    
    xStep = Kp.*Gx.*IgradTH; %Proportional gradients used for step sizes in the flow algorithm
    yStep = Kp.*Gy.*IgradTH;
    clear Gx
    clear Gy
    
    disp('Finding potential 3D COM locations')
    Ilog1 = imregionalmax3(I).*IgradTH; %Finds local maximums of a 3D image and masks it with the logical image
    Ilog = zeros(s); %Holds the region settling areas and trails
    
    disp('Creating settling regions')
    for z=1:s(3) %Going through each element in the logical image and adding disks
        for row=1:s(1)
            for col=1:s(2)
                if(Ilog1(row,col,z)==1) %If this is the location of a local maximum
                    if~(Ilog(row,col,z)==0) %If the pixel is already assigned to a settling region
                        continue; %Ignore it
                    end
                    CL((-sec),1:3) = [col, row, z]; %Store cell COM location
                    Irg = im2double(sqrt((col-Xs).^2+(row-Ys).^2)<R); %This image just creates a white disk
                    Ilog(:,:,z) = Ilog(:,:,z) + Irg.*im2double(Ilog(:,:,z)==0).*sec; %Inserting a disk
                    if~(z==1) %We can't insert a disk at z-1 if we are at the first z stack
                        Ilog(:,:,z-1) = Ilog(:,:,z-1) + Irg.*im2double(Ilog(:,:,z-1)==0).*sec; %Inserting a disk
                    end
                    if~(z==s(3)) %We can't insert a disk at z+1 if we are at the last z stack
                        Ilog(:,:,z+1) = Ilog(:,:,z+1) + Irg.*im2double(Ilog(:,:,z+1)==0).*sec; %Inserting a disk
                    end
                    sec = sec-1; %Decrement to indicate a new section
                end
            end
        end
    end
    CL = CL(1:(-sec)-1,:);
    CL(:,4) = CL(:,1); %This is used to find the box that describes the location of the segmented region
    CL(:,6) = CL(:,2);
    CL(:,8) = CL(:,3);
    
    clear Ilog1
    regIm = zeros(s); %Final image that will contain the segmented regions
    trailM = int16(zeros(s(1).*s(2),1)); %Vector that tells which trails belong to which regions
    
    disp('Segmenting images using gradient vector flow')
    for z=1:s(3) %Going through each element in the proportional gradient matrices
        for row=1:s(1)
            for col=1:s(2)
                if(IgradTH(row,col,z)==0) %Don't consider areas not found in the mask image
                    continue;
                end
                xd = col; %Dynamic pixel starts at the static pixel location
                yd = row;
                zd = z;
                while(Ilog(yd,xd,zd)==0) %As long as we are seeing pixels that have never seen activity
                    Ilog(yd,xd,zd) = trailId; %Mark trail
                    
                    %Find new dynamic pixel
                    delx = xStep(yd,xd,zd); %New delta x and y based on dynamic location
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
                        delz = double((I(yd,xd,zd)-I(yd,xd,zd-1))<0)*(-1); %Gradient is 0 or negative if at the last z stack
                    else %zd has to be 1
                        delz = double((I(yd,xd,zd+1)-I(yd,xd,zd))>0); %Gradient is 0 or positive if at the first z stack
                    end
                    
                    if(abs(delx)<1) %Proportional x step
                        delx = double((delx>0) - (delx<0)); %x and y steps are +1 or -1 if the proportional step is >-1 and <+1
                    else
                        delx = round(delx); %Otherwise they are just rounded to the nearest integer
                    end
                    if(abs(dely)<1) %Proportional y step
                        dely = double((dely>0) - (dely<0));
                    else
                        dely = round(dely);
                    end
                    
                    xd = xd+delx; %Quick increments
                    yd = yd+dely;
                    zd = zd+delz;
                    
                    if(IgradTH(yd,xd,zd)==0) %If the dynamic pixel drifts out of the mask image
                        break;
                    end
                end
                
                if(IgradTH(yd,xd,zd)==0||Ilog(yd,xd,zd)==trailId)
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
                
                if(col<rCL(4)) %New x minimum or x maximum
                    CL(regId,4)=col;
                elseif(col>rCL(5))
                    CL(regId,5)=col;
                end
                if(row<rCL(6)) %New y min or y max
                    CL(regId,6)=row;
                elseif(row>rCL(7))
                    CL(regId,7)=row;
                end
                if(z<rCL(8)) %New z min or z max
                    CL(regId,8)=z;
                elseif(z>rCL(9))
                    CL(regId,9)=z;
                end
            end
        end
    end
    
    maxp = max(regIm,[],3);
    maxp = max(maxp(:));
    regIm = im2double(regIm)./maxp; %Making the highest double value be 1
end

