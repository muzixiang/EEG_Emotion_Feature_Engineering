%rhythm extraction params theta alpha beta gamma
lowf = [4,8,13,30];
highf = [8,13,30,50];
bandNum = size(lowf,2);
rhythms = {'GammaRhythm','BetaRhythm','AlphaRhythm','ThetaRhythm'};%特意逆序写为了先算高频部分

%% hyper params
subNum = 15;
channelNum = 62;%EEG通道共32个
expNum = 3;
fs = 200;
trialTime = 20;
trialL = fs*trialTime;
trialNum = 15;
linear_feature_num = 9;
nonlinear_feature_num = 9;
brainAsync_feature_num = 27;%左右脑半球对称电极对数
nondomain_feature_num = linear_feature_num+nonlinear_feature_num;
total_feature_num = nondomain_feature_num*channelNum+brainAsync_feature_num;%一个样本所能抽取的特征数量

%% 针对不同的滑动计算窗口长度提取相应特征
windowTime = 4;%滑动计算窗口长度是1s,2s,3s,4s,5s,6s,10s等等
rhythmNo = 1;
overlap = 0.5;%滑窗机制下滑动的步长，也就是窗口间的覆盖比例。

for subNo=1:subNum
    for expNo=1:expNum
        %% allocate memory
        EEG_Features = zeros(trialNum,total_feature_num);
        %% load data
        filePath = strcat('D:\LX\Processed SEED DATA\NoScaleForEachChannel_RhythmExtraction\',rhythms{rhythmNo},'\sub',num2str(subNo),'_',num2str(expNo),'.mat');
        datFile = load(filePath);
        subData = datFile.data;
        tic;
        %% extraction features
        for trialNo=1:trialNum
            %% extraction linear+nonlinear for each channel in current sample
            for channelNo = 1:channelNum %每个sample是由32个电极对应数据构成的，所以这里要分别从32个电极里去取对应当前sample的数据。
                disp(strcat('Feature Extracting: Sub-',num2str(subNo),' experiment- ',num2str(expNo),' trialNo-',num2str(trialNo),' channelNo-',num2str(channelNo)));
                chsig_start = (channelNo-1)*trialL+1;%此值代表对应channel数据抽取的起始位置,注意有3秒的baseline
                chsig_end = channelNo*trialL;%此值代表对应channel数据抽取的结束位置,注意有3秒的baseline
                channelSignal = subData(trialNo,chsig_start:chsig_end);%抽取trial对应的channel完整信号,包括了3秒baseline
                channelTrialSignal = channelSignal;%除去baseline部分
                %% linear feature extraction:linearF totalnum=9*channelNum
                %     (:,1) = PPmean;
                %     (:,2) = meanSquare;
                %     (:,3) = variance;
                %     (:,4) = activity;
                %     (:,5) = mobility;
                %     (:,6) = complexity;
                %     (:,7) = f0;
                %     (:,8) = maxs;
                %     (:,9) = sumPower;
                %plot(signal_sample);
                linearF = F_allLinearFeatures(fs,channelTrialSignal',windowTime,overlap);
                %% non-linear feature extraction:nonlinearF totalnum=9*channelNum
                %     (:,1) = ApEn;
                %     (:,2) = C0 Complexity;
                %     (:,3) = correlation dimension;
                %     (:,4) = kolmogorov entropy 总遇到bug故取消先
                %     不适合数据长度小于1000,2000的序列
                %     (:,5) = lyapunov exponent;
                %     (:,6) = permutation entropy;
                %     (:,7) = singular entropy;
                %     (:,8) = shannon entropy;
                %     (:,9) = spectral_entropy;
                nonlinearF = F_allNonlinearFeatures(fs,channelTrialSignal',windowTime,overlap);
                %拼接线性与非线性特征
                nonDomainF = [linearF,nonlinearF];
                startIndex = nondomain_feature_num*(channelNo-1)+1;
                endIndex = nondomain_feature_num*channelNo;
                EEG_Features(trialNo,startIndex:endIndex)=nonDomainF;%将得到的非线性特征保存到相应位置
            end
            %% brain_asymmetry extraction:asymmetryF totalNum=1*channelpairNum
            % 27对对称电极
            left_ch=[1,4,6,7,8,9,15,16,17,18,24,25,26,27,33,34,35,36,42,43,44,45,51,52,53,58,59];
            right_ch=[3,5,14,13,12,11,23,22,21,20,32,31,30,29,41,40,39,38,50,49,48,47,57,56,55,62,61];
            asyNum = brainAsync_feature_num;
            asymmetryF = zeros(1,asyNum);
            for j=1:asyNum
                l_chsig_start = (left_ch(j)-1)*(trialTime)*fs+1;
                l_chsig_end = left_ch(j)*(trialTime)*fs;
                r_chsig_start = (right_ch(j)-1)*(trialTime)*fs+1;
                r_chsig_end = right_ch(j)*(trialTime)*fs;
                l_channelSignal = subData(trialNo,l_chsig_start:l_chsig_end);%抽取trial对应的左channel完整信号,包括了3秒baseline
                r_channelSignal = subData(trialNo,r_chsig_start:r_chsig_end);%抽取trial对应的右channel完整信号,包括了3秒baseline
                asymmetry = brain_asymmetry(fs,windowTime,r_channelSignal',l_channelSignal');
                asymmetryF(j)=asymmetry;
            end
            startIndex = nondomain_feature_num*channelNum+1;
            endIndex = nondomain_feature_num*channelNum+brainAsync_feature_num;
            EEG_Features(trialNo,startIndex:endIndex)=asymmetryF;%将得到的非线性特征保存到相应位置
        end
        toc;
        %将该被试的EEG_Features保存起来
        fileName = strcat('D:\LX\Processed SEED DATA\FeatureEngineering\EEG\Frontiers\NoScaleRawData_RhythmExtraction\',rhythms{rhythmNo},'\WindowTime',num2str(windowTime),'_sub',num2str(subNo),'_',num2str(expNo),'.mat');
        save(fileName,'EEG_Features','-v7.3');
        disp(strcat('end!subject ',num2str(subNo)));
    end
end
