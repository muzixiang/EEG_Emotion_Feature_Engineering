%%%%%%%%%%%%%spectral entropy%%%%%%%%%%%%%%%%%%%%
%%李兰兰
%%2010.06.17
%&关于输入：A为需要计算特征的数据（单导），Fs为输入的采样率，p如果等于1则画出功率谱熵随时间变化的曲线图
%%关于输出：PSen代表程序计算得到的功率谱熵的特征值，每4s个点得到一个值，计算时每次重叠2s，Average为
%输出功率谱熵的平均值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
function [PSen,Average_PSen]=spectral_entropy(A,Fs,window_t,overlap,p)
M=length(A);
N=Fs*window_t;%每次计算的序列长度
m=Fs*(window_t*(1-overlap));%每次滑动的点数
t=((M-N)/m);
h=floor(t);
for j=0:h %滑动的次数
    Xt=A(1+j*m:N+j*m);
    Pxx = abs(fft(Xt,N)).^2/N;                 %求取功率谱密度
    Spxx=sum(Pxx(2:1+N/2));                    %求取时间序列的总功率
    Pf=(Pxx(2:1+N/2))./Spxx;                            %求取概率
    for i=1:N/2
        if Pf(i)~=0
           LPf(i)=log(Pf(i));                %求取功率谱熵
        else
           LPf(i)=0;
        end
    end
 Hf=Pf'.*LPf;
 PSen(j+1)=-(sum(Hf));
end
if p==1
plot(PSen);
end
Average_PSen=mean(PSen);


        