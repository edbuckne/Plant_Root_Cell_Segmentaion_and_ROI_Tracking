function [ isB ] = isBound( c, levInd )

if(c(:,levInd(1)+1)==c(:,end));
else
    isB = 1;
end

for i=2:length(levInd)
    if(c(:,levInd(i)+1)==c(:,levInd(i-1)-1))
    else
        isB = i-2;
        break;
    end
end

end

