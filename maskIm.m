function [ Iout ] = maskIm( I )
TH = 0.3;

h = fspecial('disk',12);
Ip = max(I,[],3);
Ipe = imfilter(histeq(Ip),h,'replicate');
Iout = im2bw(Ipe,TH);

end

