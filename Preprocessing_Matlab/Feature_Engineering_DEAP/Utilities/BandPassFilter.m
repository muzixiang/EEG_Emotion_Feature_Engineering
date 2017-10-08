function output=BandPassFilter(x,fs,fc1,fc2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 文件功能：基本带通FIR滤波器，汉宁窗，具有较小的旁瓣和较大的衰减速度，但是截取信号时容易造成前边界区间失真。
%fc1、fc2分别为滤波器的上下频率边界，fs为采样频率，x为滤波器的输入信号，输出为output。
%此程序前端数据基本无失真，后端有0.05s左右的失真，但是已经补零，数据长度与原始数据保持一致。
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check input signal
[a_1,b_1]=size(x);
if b_1==1 && b_1<a_1
    x=x';
end
if a_1~=1 && b_1~=1
    error('MATLAB:mark_EOG:Inputmatrixisnotreliable',...
              'Input matrix is not a one - dimensional array.  See mark_EOG.');
end

% b(n)列长为M 约为501，信号为x
seg_len = 256; %seg 为原始信号分段长度应为单位冲击响应一个数量级。 
len = length(x);
wp=[2*fc1/fs 2*fc2/fs];
N=500;    %通带边界频率（归一化频率）和滤波器阶数
b=fir1(N,wp,hanning(N+1));           %设计FIR带通滤波器
M = length(b);
flo = floor(len/seg_len)-1;
L = seg_len+M-1;
output = zeros(1,(flo+2)*seg_len);
t=zeros(1,M-1);
for i = 0:1:flo+1
    if i ~= flo+1
        y = x(seg_len*i+1:(i+1)*seg_len);
    else
        y_1 = x(seg_len*(flo+1):end);
        y =[y_1,zeros(1,seg_len-length(y_1))];
    end

%     y=[y,zeros(1,L-256)];
%     b=[b,zeros(1,L-M)];
    z = conv(b,y);
    z(1:M-1) = z(1:M-1) + t(1:M-1);
    t(1:M-1) = z(seg_len+1:L);
    output1(seg_len*i+1:(i+1)*seg_len) = z(1:seg_len);
end

start_t = floor((N)/2);
output2 = output1(start_t:end);

if len>length(output2)
    output= [output2,zeros(1,len-length(output2))];
else
    output=output2(1:len);
end


end

