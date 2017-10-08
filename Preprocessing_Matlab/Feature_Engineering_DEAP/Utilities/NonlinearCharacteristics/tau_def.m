%%%%%%%%%%%%%%%%%%%%%autocorelation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%作者：李兰兰
%题目：时间延迟tau的计算
%日期：2009.11.15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tau_value=tau_def(data)
A_ave=mean(data);   %需序列的均值
%A_std=std(data);%序列的标准差
N=length(data);
D=0;
E=0;
for t=1:1000 %用自相关法计算tau
    for i=1:N-t
        D=D+(data(i)-A_ave)*(data(i+t)-A_ave);
        E=E+(data(i)-A_ave)*(data(i)-A_ave);
    end
   C(t)=D/E;
   if C(t)<=0.65;%0.65=1-1/e
       tau_F=t;
       break
   end  
end
if tau_F<=20
    tau_value=tau_F;
else
    tau_value=20;
end