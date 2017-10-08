%% 对每个被试的数据进行normalize并且重构封装格式
% 分别对每个channel在40段视频里的数据进行normalization，scale到0~1
% 这种normalize的方式能保留各个channel在不同刺激下的幅值差异，同时还能消除掉不同channel的幅值差异，同时还能降低被试与被试间的差异
subNum = 15;
expNum = 3;%每个被试实验3次
trialNum = 15;
channelNum = 62;
fs = 200;
trialTime = 60; 
trialL = fs*trialTime;
signalL = trialL*channelNum;

%rhythm extraction params theta alpha beta gamma
lowf = [4,8,13,30];
highf = [8,13,30,100];
bandNum = size(lowf,2);
rhythms = {'ThetaRhythm','AlphaRhythm','BetaRhythm','GammaRhythm'};

%分频段进行节律抽取 并封装到不同文件里保存
for i=1:bandNum
    for subNo=1:subNum
        for expNo=1:expNum
            scale_data = zeros(trialNum,signalL);
            if subNo<10
                filePath = strcat('D:\LX\SEED DATA\sub0',num2str(subNo),'_',num2str(expNo),'.mat');
            else
                filePath = strcat('D:\LX\SEED DATA\sub',num2str(subNo),'_',num2str(expNo),'.mat');
            end
            datFile = load(filePath);
            trialNames = fieldnames(datFile);%取出结构体内所有字段
            for channelNo=1:channelNum
                %拼接各个channel在不同trial中的数据成一列
                channel_data = zeros(trialNum,trialL);
                for trialNo=1:trialNum
                    disp(strcat('start processing rhythm ',rhythms{i},' sub ',num2str(subNo),' experiment ',num2str(expNo),' channel ',num2str(channelNo),' trial ',num2str(trialNo)));
                    trialName=trialNames{trialNo};
                    trialData = getfield(datFile,trialName);
                    channelSignal = trialData(channelNo,:);
                    %取最中间的1分钟部分作为目标信号
                    length = size(channelSignal,2);
                    l_center = round(length/2);
                    centerSignal = channelSignal(l_center-fs*30+1:l_center+fs*30);
                    %按频段进行节律抽取 并封装到不同文件里保存
                    rhythmSignal=BandPassFilter(centerSignal,fs,lowf(i),highf(i));
                    channel_data(trialNo,:) = rhythmSignal;
                end
                %对该channel在各个trial下的数据进行scale到scale_channel_data
                maxVal= max(max(channel_data));
                minVal = min(min(channel_data));
                scope = maxVal-minVal;
                scale_channel_data = 2*(channel_data-minVal)/scope-1;%归一化到-1到1
                %将scale后的channel数据写入scale_data相应的位置
                startIndex = (channelNo-1)*trialL+1;
                endIndex = channelNo*trialL;
                scale_data(:,startIndex:endIndex) = scale_channel_data;
            end
            %将该被试的data保存起来
            fileName = strcat('D:\LX\Processed SEED DATA\ScaleForEachChannel_RhythmExtraction\',rhythms{i},'\sub',num2str(subNo),'_',num2str(expNo));
            save(fileName,'scale_data','-v7.3');
            disp(strcat('end!subject ',num2str(subNo)));
        end
    end
end