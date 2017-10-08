%% 对每个被试的数据进行normalize并且重构封装格式
% 分别对每个channel在40段视频里的数据进行normalization，scale到0~1
% 这种normalize的方式能保留各个channel在不同刺激下的幅值差异，同时还能消除掉不同channel的幅值差异，同时还能降低被试与被试间的差异
subNum = 32;
trialNum = 40;
channelNum = 40;
fs = 128;
trialTime = 63; 
trialL = fs*trialTime;
signalL = trialL*channelNum;

%rhythm extraction params theta alpha beta gamma
lowf = [4,8,13,30];
highf = [8,13,30,64];
bandNum = size(lowf,2);
rhythms = {'ThetaRhythm','AlphaRhythm','BetaRhythm','GammaRhythm'};%cell字符串

%分频段进行节律抽取 并封装到不同文件里保存
for i=1:bandNum
    for subNo=1:subNum
        data = zeros(trialNum,signalL);
        if subNo<10
            filePath = strcat('D:\DEAP DATA\s0',num2str(subNo),'.mat');
        else
            filePath = strcat('D:\DEAP DATA\s',num2str(subNo),'.mat');
        end
        datFile = load(filePath);
        subData = datFile.data;
        for channelNo=1:channelNum
            %拼接各个channel在40段实验中的数据成一列
            channel_data = zeros(trialNum,trialL);
            for trialNo=1:trialNum
                disp(strcat('start processing rhythm ',rhythms{i},'sub ',num2str(subNo),' channel ',num2str(channelNo),' trial ',num2str(trialNo)));
                channelSignal = subData(trialNo,channelNo,:);
                channelSignal = squeeze(channelSignal);%squeeze压缩那些无用的只有一行一列的维度
                %按频段进行节律抽取 并封装到不同文件里保存
                rhythmSignal=BandPassFilter(channelSignal,fs,lowf(i),highf(i));
                channel_data(trialNo,:) = rhythmSignal;%squeeze压缩那些无用的只有一行一列的维度
            end
            %将当前channel数据写入data相应的位置
            startIndex = (channelNo-1)*trialL+1;
            endIndex = channelNo*trialL;
            data(:,startIndex:endIndex) = channel_data;
        end
        %将该被试的data保存起来
        fileName = strcat('D:\LX\Processed DEAP DATA\NoScaleForEachChannel_RhythmExtraction\',rhythms{i},'\sub',num2str(subNo));
        save(fileName,'data','-v7.3');
        disp(strcat('end!subject ',num2str(subNo)));
    end
end