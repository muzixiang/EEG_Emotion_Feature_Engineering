from sklearn import svm
import scipy.io as sio
from sklearn import preprocessing
import numpy as np
from sklearn import metrics
import h5py
from sklearn.feature_selection import SelectFromModel
from sklearn.svm import LinearSVC

subNum = 15
trialNum = 10
expNum = 3
subTrialNum = trialNum*expNum
# ((9+9)*62+27)*4
featureDim = 4572

#non neutral trial index
trial_indx = [0,2,3,5,6,8,9,11,13,14]

#load data Y
file1 = sio.loadmat('.//trial_label.mat')
Y = file1['label']

asy_channel_pairs_num = 27

rhythmNum = 5

# theta alpha beta gamma all
f1_scores = np.zeros((rhythmNum, asy_channel_pairs_num, subNum))
acc_scores = np.zeros((rhythmNum, asy_channel_pairs_num, subNum))

subX_all = np.zeros((subNum*subTrialNum, featureDim))
subY_all = np.zeros((subNum*subTrialNum))

## combine all subjects' samples...
for subNo in range(0, subNum):
    subX = np.zeros((subTrialNum,featureDim))
    subY = np.zeros((subTrialNum))
    for expNo in range(0, expNum):
        file2 = h5py.File(
            'D://LX//Processed SEED DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//BetaRhythm//WindowTime4_sub' + str(
                subNo + 1) +'_'+str(expNo+1)+'.mat', 'r')
        file3 = h5py.File(
            'D://LX//Processed SEED DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//GammaRhythm//WindowTime4_sub' + str(
                subNo + 1) +'_'+str(expNo+1)+'.mat', 'r')
        file4 = h5py.File(
            'D://LX//Processed SEED DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//AlphaRhythm//WindowTime4_sub' + str(
                subNo + 1) +'_'+str(expNo+1)+'.mat', 'r')
        file5 = h5py.File(
            'D://LX//Processed SEED DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//ThetaRhythm//WindowTime4_sub' + str(
                subNo + 1)+'_'+str(expNo+1)+ '.mat', 'r')
        subX1 = file2['EEG_Features']
        subX1 = np.transpose(subX1)
        subX2 = file3['EEG_Features']
        subX2 = np.transpose(subX2)
        subX3 = file4['EEG_Features']
        subX3 = np.transpose(subX3)
        subX4 = file5['EEG_Features']
        subX4 = np.transpose(subX4)
        subXX = np.hstack((subX4, subX3, subX1, subX2)) # with order of : theta alpha beta gamma
        subX_exp = subXX[trial_indx,:]
        subY_exp = Y[0,trial_indx]
        subX[expNo*trialNum:(expNo+1)*trialNum,:]=subX_exp
        subY[expNo*trialNum:(expNo+1)*trialNum]=subY_exp
    subX_all[subNo*subTrialNum:(subNo+1)*subTrialNum,:] = subX
    subY_all[subNo*subTrialNum:(subNo+1)*subTrialNum] = subY

## scale data
min_max_scaler = preprocessing.MinMaxScaler()
subX_all = min_max_scaler.fit_transform(subX_all)
X = subX_all
Y = subY_all
print X.shape
print Y.shape

for ch_no in range(0,asy_channel_pairs_num):
    for rhy_no in range(0,rhythmNum):
        for subNo in range(0, subNum):
            if subNo == 0:
                testX = X[0:30, :]
                testY = Y[0:30]
                trainX = X[30:450, :]
                trainY = Y[30:450]
            elif subNo == 14:
                testX = X[420:450, :]
                testY = Y[420:450]
                trainX = X[0:420, :]
                trainY = Y[0:420]
            else:
                testX = X[subNo * subTrialNum:(subNo + 1) * subTrialNum, :]
                testY = Y[subNo * subTrialNum:(subNo + 1) * subTrialNum]
                trainX = np.vstack((X[0:subNo * subTrialNum, :], X[(subNo + 1) * subTrialNum:subNum * subTrialNum, :]))
                trainY = np.concatenate((Y[0:subNo * subTrialNum], Y[(subNo + 1) * subTrialNum:subNum * subTrialNum]))

            if rhy_no < 4:
                trainX1 = trainX[:,rhy_no*1143+1116+ch_no]
                testX1 = testX[:,rhy_no*1143+1116+ch_no]
                trainX = np.zeros((420,1))
                testX = np.zeros((30,1))
                trainX[:,0] = trainX1
                testX[:,0] = testX1
            else:
                trainX = trainX[:, [0 * 1143 + 1116 + ch_no,1 * 1143 + 1116 + ch_no,2 * 1143 + 1116 + ch_no,3 * 1143 + 1116 + ch_no]]
                testX = testX[:, [0 * 1143 + 1116 + ch_no,1 * 1143 + 1116 + ch_no,2 * 1143 + 1116 + ch_no,3 * 1143 + 1116 + ch_no]]
            # svm

            clf1 = svm.SVC(kernel='linear', probability=False)
            clf1.fit(trainX,trainY)
            predict_testY = clf1.predict(testX)
            f1_scores[rhy_no, ch_no, subNo] = metrics.f1_score(testY, predict_testY)
            acc_scores[rhy_no, ch_no, subNo] = metrics.accuracy_score(testY, predict_testY)
            print('asy_channelType: ', ch_no, ' rhythm: ', rhy_no, ' sub: ', subNo, ' performance: ', acc_scores[rhy_no, ch_no, subNo])


# save results
sio.savemat('acc_scores_subcross_asychanneltype_SEED.mat', {'results': acc_scores})
sio.savemat('f1_scores_subcross_asychanneltype_SEED.mat', {'results': f1_scores})
