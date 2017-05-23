function [ As, Imax ] = bfBorderInd( I, alpha, beta, We, It, Np, opt, stack )
s = size(I);

%Getting the gradient image
sigma = 6;

Igrad = zeros(s);
for z=1:s(3) %Getting the gradient of a gaussian filtered image
    [Igrad(:,:,z),~] = imgradient(imgaussfilt(I(:,:,z),sigma));
end

%Find the percentile of the data
data = zeros(s(1)*s(2)*s(3),1);
i=1;

for row=1:s(1)
    for col=1:s(2)
        for z=1:s(3)
            data(i) = Igrad(row,col,z); %Put pixels in a data vector
            i=i+1;
        end
    end
end

p=99.5;
y = prctile(data,p);

%Threshold the image with the percentile
Ith = zeros(s);

for z=1:s(3)
    Ith(:,:,z) = im2bw(Igrad(:,:,z),y);
end

Ith = im2double(Ith);
Imax = max(Ith,[],3);

%Apply the active contour algorithm
As = acSeg(Imax,Np,alpha,beta,We,It,'none');
if(strcmp(opt,'show')) %Print if user indicated
    figure
    imshow(I(:,:,stack))
    line(As(:,1),As(:,2),'linewidth',2)
end
end

