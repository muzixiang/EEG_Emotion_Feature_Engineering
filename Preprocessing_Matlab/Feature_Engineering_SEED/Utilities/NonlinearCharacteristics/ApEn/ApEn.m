function [Em,Amean]=ApEn(A,Fs,window_t,overlap)
m=2;
r=0.2;
G=length(A);
%window_t=6;
N=Fs*window_t;%每次计算的序列长度
g=Fs*(window_t*(1-overlap));%每次滑动的点数
t=((G-N)/g);
h=floor(t);
Em=zeros(h,1);
for i=0:h %滑动的次数
    data=A(1+i*g:N+i*g);%数据滑动读取
    R=r*std(data,1);  %计算R
   Em(i+1)=Bm(data,R,m,N)-Bm(data,R,m+1,N);%计算近似熵
end
Amean=mean(Em);


