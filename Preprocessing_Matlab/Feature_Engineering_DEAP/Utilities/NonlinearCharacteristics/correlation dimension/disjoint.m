function data_d=disjoint(data,N,t)
%该函数用来将时间序列分为t组不相交的时间序列
%data:脑电信号时间序列
%N:序列长度 
%t:组数
for i=1:t
    for j=1:(N/t)
        data_d(i,j)=data(i+(j-1)*t);
    end
end