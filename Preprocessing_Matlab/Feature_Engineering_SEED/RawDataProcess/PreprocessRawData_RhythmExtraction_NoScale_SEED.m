%% 对每个被试的数据进行normalize并且重构封装格式
% 分别对每个channel在40段视频里的数据进行normalization，scale到0~1
% 这种normalize的方式能保留各个channel在不同刺激下的幅值差异，同时还能消除掉不同channel的幅值差异，同时还能降低被试与被试间的差异
subNum = 15;
expNum = 3;%每个被试实验3次
trialNum = 15;
channelNum = 62;
fs = 200;
trialTime = 20; 
trialL = fs*trialTime;
signalL = trialL*channelNum;

%rhythm extraction params theta alpha beta gamma
lowf = [4,8,13,30];
highf = [8,13,30,50];
bandNum = size(lowf,2);
rhythms = {'ThetaRhythm','AlphaRhythm','BetaRhythm','GammaRhythm'};

%分频段进行节律抽取 并封装到不同文件里保存
for i=1:bandNum %记得修改起始位置
    for subNo=1:subNum
        for expNo=1:expNum
            data = zeros(trialNum,signalL);
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
                    %取最中间的20s部分作为目标信号，因为考虑到采样率200，需要降低抽取特征计算代价，即缩短信号长度
                    length = size(channelSignal,2);
                    l_center = round(length/2);
                    centerSignal = channelSignal(l_center-fs*10+1:l_center+fs*10);
                    %按频段进行节律抽取 并封装到不同文件里保存
                    rhythmSignal=BandPassFilter(centerSignal,fs,lowf(i),highf(i));
                    channel_data(trialNo,:) = rhythmSignal;
                end
                %将当前channel数据写入data相应的位置
                startIndex = (channelNo-1)*trialL+1;
                endIndex = channelNo*trialL;
                data(:,startIndex:endIndex) = channel_data;
            end
            %将该被试的data保存起来
            fileName = strcat('D:\LX\Processed SEED DATA\NoScaleForEachChannel_RhythmExtraction\',rhythms{i},'\sub',num2str(subNo),'_',num2str(expNo));
            save(fileName,'data','-v7.3');
            disp(strcat('end!subject ',num2str(subNo)));
        end
    end
end