%%%%%%%%%%%%%%%%%%%   singular_entropy.m    %%%%%%%%%%%%%%%%%
%% 功能：用于计算奇异谱熵
%% 作者：李兰兰
%% 时间：2010.07.10
%%%window_t为每次计算的窗口时间长度，overlap为重叠比率如0.5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H_singu, M_H]=singular_entropy(A,Fs,window_t,overlap)
N=Fs*window_t;%每次计算的序列长度
G=length(A);
g=Fs*(window_t*(1-overlap));%每次滑动的点数
t=((G-N)/g);
h=floor(t);
for ii=0:h
    data = A(1+ii*g:N+ii*g);
    % 重构相空间
    % m为嵌入空间维数
    % tau为时间延迟
    % data为输入时间序列
    % N为时间序列长度
    % X为输出,是m*M维矩阵
    tau=tau_def(data);
    m = 15;
    M = N-(m-1)*tau;%相空间中点的个数
    for  j=1:M       %相空间重构
        for i=1:m
            X(i,j) = data((i-1)*tau+j);
        end
    end
    
    C = (X*X')./m;  % 自协方差矩阵
    [V,S] = eig(C); % 求特征值，特征向量
    for i=1:m
        a(i) = S(i,i);
    end
    amax = max(a);
    singu = log(a./amax);
    
    for i=1:m       % singu排序
        for j=(i+1):m
            if singu(j)>singu(i)
                temp = singu(j);
                singu(j) = singu(i);
                singu(i) = temp;
            end
        end
        p(i)=singu(i)./sum(singu);
        if p(i)~=0
            lp(i)=log(p(i));
        else
            lp(i)=0;
        end
    end
    H_singu(ii+1)=-sum(p*lp');
end
M_H=mean(H_singu);

