%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%李兰兰
%%2010.06.17
%关于输入：该程序中A代表输入矩阵（单导数据），Fs为输入的采样率，window_t为滑动计算窗口，overlap为重叠率如0.5，p如果等于1则画出C0的曲线图
%关于输出:CorrelationDimension代表程序计算得到的关联维数D2的特征值，每window_t s个点得到一个C0值，计算时每次重叠window_t/2 s，M_C为
%输出关联维数的平均值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CorrelationDimension,M_C]=reC(A,Fs,window_t,overlap,p)
    N=Fs*window_t;%每次计算的序列长度
    G=length(A);
    g=Fs*(window_t*(1-overlap));%每次滑动的点数
    t=((G-N)/g);
    h=floor(t);
    ss=20;
    m=15;
    C=zeros(1,ss);
    for ii=0:h %滑动的次数
        data=A(1+ii*g:N+ii*g);
        tau=tau_def(data);
        M=N-(m-1)*tau;%相空间每一维序列的长度
        d=zeros(M-1,M);
        Y=reconstitution(data,N,m,tau);%重构相空间
        for i=1:M-1
            for j=i+1:M
                d(i,j)=norm((Y(:,i)-Y(:,j)),2);
            end     %计算状态空间中每两点之间的距离
        end
        max_d=max(max(d));% 得到所有点之间的最大距离
        min_d=max_d;
        for i=1:M-1
            for j=i+1:M
                if (d(i,j)~=0 && d(i,j)<min_d) 
                 min_d=d(i,j);
                end
            end
        end

        %min_d=min(min(d));%得到所有点间的最短距离
        delt=(max_d-min_d)/ss;% 得到r的步长
        for k=1:ss
            %disp(strcat('ii:',num2str(ii),' k:',num2str(k)));
            r(k)=min_d+k*delt;
            H(k)=length(find(r(k)>d))';
            C(k)=2*H(k)/(M*(M-1))-1;
            %C(k)=correlation_integral(Y,M,r); %计算关联积分
            ln_C(m,k)=log2(C(k)); %lnC(r)
            ln_r(m,k)=log2(r(k)); %lnr
        end
        %figure(ii+1);
        for k=1:ss
            r(k)=min_d+k*delt;
        end
        slope = diff(ln_C(m,:))./diff(log(r));
        if p==1
            subplot(1,2,1);
            plot(log(r),ln_C(m,:),'+:'); grid; %虚线
            xlabel('log(r)'); ylabel('ln_C(m,:)'); 
            hold on;
        end
        % 拟合线性区域
        ln_Cr=ln_C(m,:);    
        ln_r=ln_r(m,:);
        %LinearZone=[2:5];
        F = polyfit(ln_r,ln_Cr,1);
        CorrelationDimension(ii+1)= F(1);
    end
    M_C=mean(CorrelationDimension);
    if p==1
        subplot(1,2,2);
        plot(CorrelationDimension);
        ylabel('CorrelationDimension'); 
        hold on;
    end

    