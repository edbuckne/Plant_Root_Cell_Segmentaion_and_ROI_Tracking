function [ ZCMatrix ] = findZCrossing( data, negPos )

N = length(data);
ZCMatrix = [];

if negPos
for i=2:N
    if((data(i-1)>0)&&(data(i)<=0))
        ZCMatrix = [ZCMatrix; i];
    end
end
else
    for i=2:N
    if((data(i-1)<0)&&(data(i)>=0))
        ZCMatrix = [ZCMatrix; i];
    end
end
end


end

