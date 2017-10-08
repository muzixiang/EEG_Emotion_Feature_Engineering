%%%%%%%%%%%%%%%%%%%%%%shannon_entropy%%%%%%%%%%%%%%%%%%%%%
%%作者：李兰兰
%%日期：2010.07.02
%%%%%window_t为每次计算的窗口时间长度，overlap为重叠比率如0.5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H,Average_SHen]=shannon_entropy(A,Fs,window_t,overlap)
N=Fs*window_t;%每次计算的序列长度
G=length(A);
g=Fs*(window_t*(1-overlap));%每次滑动的点数
t=((G-N)/g);
h=floor(t);

for j=0:h
    Xt=A(1+j*g:N+j*g);
    Sam=sum(abs(Xt));  %计算幅度的绝对值
    P=abs(Xt)./Sam;   %计算概率
    for i=1:N
        if P(i)~=0
           LP(i)=log(P(i));                
        else
           LP(i)=0;
        end
    end
  Hi=P'.*LP;   %计算香农熵
 H(j+1)=-(sum(Hi));
end
Average_SHen=mean(H);
