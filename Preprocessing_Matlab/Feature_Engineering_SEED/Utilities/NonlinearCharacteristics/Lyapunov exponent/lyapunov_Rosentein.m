%%关于输入：该程序中A代表输入矩阵（单导数据），Fs为输入的采样率，window_t为滑动计算窗口，overlap为重叠率如0.5，
%%关于输出：lamda_1代表程序计算得到的最大Lyapunov特征值，每window_t s个点得到一个值，计算时每次重叠window_t/2 s，M_lya为输出的最大Lyapunov的平均值
function [lambda_1,M_lya]=lyapunov_Rosentein(A,Fs,window_t,overlap,p)
%window_t=6;
N=Fs*window_t;
m=15;           %嵌入维数
delt_t=1/Fs;    %采样间隔
G=length(A);
g=Fs*(window_t*(1-overlap));%每次滑动的点数
t=((G-N)/g);
h=floor(t);
for ii=0:h%滑动的次数
    data=A(1+ii*g:N+ii*g);
    tau=tau_def(data);%时间延迟
    P=period(data); %序列的平均周期
    Y=reconstitution(data,N,m,tau);%相空间重构
    M=N-(m-1)*tau;       %重构相空间中相点的个数
     for j=1:M           %寻找相空间中每个点的最近距离点
         d_min=1.0e+15;
          for jj=1:M
              if abs(j-jj)>P %限制短暂分离
               d_s(j,jj)=norm((Y(:,j)-Y(:,jj)),2);
               if d_s(j,jj)<d_min
                            d_min=d_s(j,jj);
                            idx_j=jj;     %记下相空间中每个点的最近距离点的下标
                end
              end
          end
        index(j)=idx_j;
        imax=min((M-j),(M-idx_j));%计算点j的最大演化时间步长i
        for i=1:imax             
            d_j_i=0;
            d_j_i=norm((Y(:,j+i)-Y(:,idx_j+i)),2);   %计算点j与其最近邻点在i个离散步后的距离
            d(i,j)=d_j_i;     %生成i*j列矩阵
        end
    end
    %对每个演化时间步长i，求所有的j的lnd(i,j)平均
    [l_i,l_j]=size(d);
    for i=1:l_i
        q=0;
        y_s=0;
        for j=1:l_j
            if d(i,j)~=0
                q=q+1; %计算非零的d(i,j)的数目
                y_s=y_s+log(d(i,j));
            end
        end
        y(i)=y_s/(q*delt_t);%对每个i求出所有的j的lnd(i,j)平均
    end
    x=1:length(y);
    linearzone=[20:80];
    Lya=polyfit(x(linearzone),y(linearzone),1);
    lambda_1(ii+1)=Lya(1);
end
M_lya=mean(lambda_1);
if p==1
    plot(lambda_1);
end



         
              
              