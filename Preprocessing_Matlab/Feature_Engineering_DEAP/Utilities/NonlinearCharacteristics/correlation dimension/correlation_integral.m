%%%%%%%%%%%%%%%%%%%%%%%%%% function C_I=correlation_integral(X,M,r) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%作者：李兰兰
%%%题目：关联积分的计算
%%%日期：2009.11.15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C_I=correlation_integral(X,M,r)
%此函数用来计算关联积分
%C_I:关联积分的值
%X:重构状态空间，X是m*M矩阵
%m:嵌入维数
%M:M是m维嵌入空间的点数
%r:Heaviside函数的半径,取值域是sigma/2<r<2sigma
sum_H=0;
for i=1:M-1
    for j=i+1:M
        d=norm((X(:,i)-X(:,j)),2);%计算矩阵中两点间的范数
        sita=heaviside(r,d);%计算heaviside函数的值 
        sum_H=sum_H+sita;
    end
end
C_I=2*sum_H/(M*(M-1));%关联积分的值