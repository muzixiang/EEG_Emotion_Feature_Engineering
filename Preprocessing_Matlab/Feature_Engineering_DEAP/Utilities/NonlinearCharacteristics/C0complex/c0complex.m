%function c0complex(input,output) 
%关于输入：该程序中A代表输入矩阵（单导数据），Fs为输入的采样率，window_t为滑动计算窗口，overlap为重叠率如0.5，p如果等于1则画出C0的曲线图
%关于输出：C0代表程序计算得到的C0特征值，每window_t s个点得到一个C0值，计算时每次重叠window_t/2 s，C0_average为输出C0的平均值
function  [C0,C0_average]=c0complex(A,Fs,window_t,overlap,p) 
M=length(A);
N=Fs*window_t;%每次计算的序列长度
m=Fs*(window_t*(1-overlap));%每次滑动的点数
r=5;
t=((M-N)/m);
h=floor(t);
for i=0:h %滑动的次数
    data=A(1+i*m:N+i*m);%数据滑动读取
    Fn=fft(data,N);      %对序列做FFT
    Fn_1=zeros(size(Fn));
    Gsum=0;
    for j=1:N
        Gsum=Gsum+abs(Fn(j))*abs(Fn(j));
    end
        Gave=(1/N)*Gsum; %求序列的均方值
    for j=1:N
        if abs(Fn(j))*abs(Fn(j))>(r*Gave) %求取序列的规则部分的频谱
           Fn_1(j)=Fn(j);
        end
    end
    data1=ifft(Fn_1,N);%求取序列的规则部分
    D=(abs(data(1:N)-data1)).^2;%求取序列的随机部分
    Cu=sum(D);%序列随机部分的面积
    E=(abs(data(1:N))).^2;
    Cx=sum(E);%序列的面积
    C0(i+1)=Cu/Cx; %C0复杂度
end  
if p==1
   plot(C0);
end

%%取C0的平均值
C0_average=mean(C0);



