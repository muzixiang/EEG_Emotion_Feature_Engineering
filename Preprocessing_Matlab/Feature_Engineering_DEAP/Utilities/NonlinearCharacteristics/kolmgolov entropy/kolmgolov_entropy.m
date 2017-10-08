%%%%%%%%%%%%%%%%%%%%%%kolmgolov entropy%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%作者：李兰兰
%%%%日期：2010.07.08
%&关于输入：A为需要计算特征的数据（单导），Fs为输入的采样率，window_t为滑动计算窗口，overlap为重叠率如0.5，p如果等于1则画出kolmogolov熵随时间变化的曲线图
%%关于输出：Km代表程序计算得到的kolmogolov熵的特征值，每window_t s个点得到一个值，计算时每次重叠window_t/2 s，Average为
%输出kolmogolov熵的平均值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Km,Kmean]=kolmgolov_entropy(A,Fs,window_t,overlap,p)
N=Fs*window_t;%每次计算的序列长度
m=15;
G=length(A);
g=Fs*(window_t*(1-overlap));%每次滑动的点数
t=((G-N)/g);
h=floor(t);
LKm=zeros(h,1);
for i=0:h %滑动的次数
    data=A(1+i*g:N+i*g);
    tau=tau_def(data);
    LKm(i+1)=log((CK(data,m,N,tau))./(CK(data,m+13,N,tau)));
    Km=(1/(tau*13))*LKm;
end
if p==1
    plot(Km);
end
Kmean=mean(Km);

