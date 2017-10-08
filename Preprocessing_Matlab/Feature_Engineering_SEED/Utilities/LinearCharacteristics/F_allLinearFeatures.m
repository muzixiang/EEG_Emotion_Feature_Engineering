function features = F_allLinearFeatures(fs,input,onetime,overlap)
    N = fs*onetime;   %截取的一次计算的点数
    Xt = input;
    Len = length(Xt);
    ii = 0;
    flag=0;
    while flag+N <= Len
        Xt_ii = Xt( (flag+1):(flag+N) );
        PPmean(ii+1) = mean(abs(Xt_ii));        %% PPmean：峰峰值的平均值
        meanSquare(ii+1) = (Xt_ii)'*(Xt_ii)/N; %% meanSquare: 均方值
        variance(ii+1) = var(Xt_ii);            %% variance: 方差
        [activity(ii+1), mobility(ii+1), complexity(ii+1)] = F_hjorth(Xt_ii,0);
%%%%%%%%%%%%%%%%%%%%%%%%%   AR model   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% 自适应求阶数 %%%%%%%%%%
        temp = 0;
        for p = [1:sqrt(N)]
            [a,E] = aryule(Xt_ii,p);
            AIC(p) = log(E)+2*p/N;
        end
        [minA bestp] = min(AIC);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [a,E] = aryule(Xt_ii,bestp);
        f = 0:1/(2*N):0.5;
        b = 0;
        for k = [1:bestp]
            b = b+a(k+1)*exp(-j*2*pi*f*k);
        end;
        s = E./( ( abs(1+b) ).^2 );     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        maxs_temp = s(1);
        kk = 0;
        for k = [1:length(s)]
            if s(k)>maxs_temp
                maxs_temp = s(k);
                kk = k;
            end
        end
        if kk==0
            kk=1;
        end
        maxs(ii+1) = maxs_temp;         %% maxs：最大功率谱密度
        f0(ii+1) = fs*(kk-1)/(2*N);        %% f0: 取得最大功率密度时的频率
        sumPower(ii+1) = sum(s)*fs/(2*N);        %% sumPower：总功率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ii = ii+1;
        flag = flag+(onetime*(1-overlap))*fs;
        Num_feature = ii;
    end
    
    features(:,1) = mean(PPmean);
    features(:,2) = mean(meanSquare);
    features(:,3) = mean(variance);
    features(:,4) = mean(activity);
    features(:,5) = mean(mobility);
    features(:,6) = mean(complexity);
    features(:,7) = mean(f0);
    features(:,8) = mean(maxs);
    features(:,9) = mean(sumPower);
   