function [ isB ] = isBound( c, levInd )
isB = 1;

if(c(:,levInd(1)+1)==c(:,end))
    isB = 1;
else
end

for i=2:length(levInd)
    if(c(:,levInd(i)+1)==c(:,levInd(i-1)-1))
        break;
    else
        isB = i;
    end
end

for j=isB+1:length(levInd)
    if(c(:,levInd(j)+1)==c(:,levInd(j-1)-1))
    else
        isB = j-1;
        break;
    end
end

end

