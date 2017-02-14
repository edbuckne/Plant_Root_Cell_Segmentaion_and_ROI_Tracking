    function [ ZCMatrix ] = findZCrossing1( data, negPos )

    N = length(data);
    data2 = diff(data);
    ZCMatrix = [];

    if negPos==1
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

