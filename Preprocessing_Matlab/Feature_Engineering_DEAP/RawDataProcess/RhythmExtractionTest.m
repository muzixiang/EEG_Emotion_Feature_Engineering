%遍历32个受试者的mat文件
fs = 128;
subNo = 1;
trialNo = 1;
channelNo = 1;

lowf = [4,8,13,30];
highf = [8,13,30,50];
bandNum = size(lowf,2);

if subNo<10
    filePath = strcat('D:\DEAP DATA\s0',num2str(subNo),'.mat');
else
    filePath = strcat('D:\DEAP DATA\s',num2str(subNo),'.mat');
end

datFile = load(filePath);
eegdata = datFile.data;
channelSignal = eegdata(trialNo,channelNo,:);
channelSignal = squeeze(channelSignal(1,1,:));
baseline = channelSignal(1:128*3);
trialSignal = channelSignal(128*3+1:length(channelSignal));

trialL = size(trialSignal,1);

trialSignal = mapminmax(trialSignal);
for i=1:bandNum
    outSignal=BandPassFilter(trialSignal,fs,lowf(i),highf(i));
    subplot(bandNum+1,1,i);
    plot(1:1:trialL,outSignal);
    title(strcat('Freq Band:',num2str(i)));
end

subplot(bandNum+1,1,i+1);
plot(1:1:trialL,trialSignal);
title('Original Signal');
