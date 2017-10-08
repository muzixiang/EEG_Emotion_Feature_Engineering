%%%%%%%%%%%%%%%%%%%%  alpha_asymmetry.m  %%%%%%%%%%%%%%%%%%%%
%  Defination:  alpha 8~13Hz
%  该程序改自求alpha_asymmetry，因为输入信号频段成分已确定所以不需要在最后单独指出计算哪个频段的不同步
%  Result:      ln(Power_right/Power_left)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  asymmetry = brain_asymmetry(Fs,step_second,s_right,s_left)

N = round(Fs*step_second);

Len = min( length(s_right),length(s_left) );        % 选取最短的数据
s_right = s_right(1:Len);
s_left = s_left(1:Len);      % 截取，使左右电极采集到的信号长度相同
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii=1:(Len/N)
    s_right_ii = s_right( (ii-1)*N+1:ii*N );
    Pxx_right(ii,:) = abs(fft(s_right_ii)).^2/N;      % 用FFT求功率谱
end
if Len/N>=2
    Pxx_right_average = mean(Pxx_right);
else
     Pxx_right_average = Pxx_right;
end

for ii=1:(Len/N)
    s_left_ii = s_left( (ii-1)*N+1:ii*N );
    Pxx_left(ii,:) = abs(fft(s_left_ii)).^2/N;      % 用FFT求功率谱
end
if Len/N>=2
    Pxx_left_average = mean(Pxx_left);
else
     Pxx_left_average = Pxx_left;
end


Power_right = sum(Pxx_right_average); % 求xx波段的总功率
Power_left = sum(Pxx_left_average);

asymmetry = log(Power_left)-log(Power_right);
    
    
    
    
    
