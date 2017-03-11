function [ I_OUT, I_OUT_GRAD ] = partitionImage2D( I_IN, opt, IT )
% partitionImage2D takes in an image and partitions it into it's cell
% sections.  
%   Input:
%       1. I_IN - image to be partitioned
%       2. opt - option for whether to do row data or column data.  'row'
%       means row data and 'col' means column data.
%   Output:
%       1. I_OUT - partitioned image
%       2. I_OUT_GRAD - partitioned image that shows the gradient of the
%       image

%Initiated variables
ROW = 'row';
COLUMN = 'col';
FILT_PARAM = 8;
TH = 0.1;

h = fspecial('disk',FILT_PARAM); %Filters the image
I_IN = imfilter(I_IN,h,'replicate');

if (strcmp(opt,ROW))
elseif (strcmp(opt,COLUMN))
    I_IN = I_IN'; %Transpose the image if it is the column data option. This is used to make the coding simpler
else
    error('Incorrect input parameter for opt (must be "row" or "col")');
end

sz = size(I_IN); %Size of the image
newIm = zeros(sz(1),sz(2));

for i=1:sz(1)
    data = I_IN(i,:);
    newIm(i,:) = equalizeData(data,IT); %Local Extreme Equalization algorithm
end

if (strcmp(opt,COLUMN))
    newIm = newIm'; %If it is the column option, transpose the image back
end

I_OUT_GRAD = newIm;
I_OUT = im2bw(newIm,TH); %Sets the threshold for the new image
end
