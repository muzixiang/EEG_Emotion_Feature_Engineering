%%%%%%%%%%%%%%%%%%%%%%% period %%%%%%%%%%%%%%
%%作者：李兰兰
%%题目：平均周期P
%%日期：2009.11.29
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P=period(data)
F=fft(data) ;           %快速FFT变换
N=length(F);            %FFT变换后数据长度
%Y(1)=[];                %去掉Y的第一个数据，它是所有数据的和
for i=1:N
    f(i)=(2*pi)*((i-1)/N);
end
for i=2:N
    aver_P(i)=((abs(F(i)))*(abs(F(i))))./f(i);
    aver_TP(i)=(abs(F(i)))*(abs(F(i)));
end
P_value=(sum(aver_P))/(sum(aver_TP));
if P_value<=100
    P=P_value;
else
    P=100;
end
% for i=1:N
%     f(i)=i/N;
% end
% plot(f,abs(Y));
% Y1=abs(Y);
% [a,b]=max(Y1(1:N));
% P=1/f(b);


% power = log(real(Y).^2+imag(Y).^2);%求功率谱
% freqave=power/(N/Fs);
% P=freqave;       %由下标求出平均周期

% Y=fft(data) ;           %快速FFT变换
% N=length(Y);            %FFT变换后数据长度
% Y(1)=[];                %去掉Y的第一个数据，它是所有数据的和
% power = log(real(Y).^2+imag(Y).^2);%求功率谱
% nyquist=1/2;
% freq=(1:N/2)/(N/2)*nyquist;%求频率
% [mp,index] = max(power);  %求最高谱线所对应的下标    
% freqave=freq(index);
% P=1/freqave;       %由下标求出平均周期
