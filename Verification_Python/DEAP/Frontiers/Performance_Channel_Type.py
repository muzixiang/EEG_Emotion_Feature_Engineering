from sklearn import svm
import scipy.io as sio
from sklearn import preprocessing
import numpy as np
from sklearn import metrics
import h5py
from sklearn.feature_selection import SelectFromModel
from sklearn.svm import LinearSVC

subNum = 32
trialNum = 40
featureDim = 2360


channelTypeNum = 32
rhythmNum = 5
rhythms = ['Theta','Alpha','Beta','Gamma','All']

#load data Y
yfile = sio.loadmat('.//subY_all_DEAP.mat')
subY_all = yfile['y']

# theta alpha beta gamma all
f1_scores = np.zeros((rhythmNum, channelTypeNum, subNum))
acc_scores = np.zeros((rhythmNum, channelTypeNum, subNum))

for ch_no in range(0,channelTypeNum):
    for rhy_no in range(0,rhythmNum):
        xfile = sio.loadmat('.//SubX_ChannelType//subX_channel_type_'+str(ch_no+1)+'_'+rhythms[rhy_no]+'_DEAP.mat')
        subX_all = xfile['f']
        ## scale data
        min_max_scaler = preprocessing.MinMaxScaler()
        subX_all = min_max_scaler.fit_transform(subX_all)
        X = subX_all
        Y = subY_all
        print X.shape
        print Y.shape
        for subNo in range(0, subNum):
            print(
            "Building model and test for ------------------------------------------------------------------------------------------------ sub " + str(
                subNo + 1))
            if subNo == 0:
                testX = X[0:40, :]
                testY = Y[0,0:40]
                trainX = X[40:subNum * trialNum, :]
                trainY = Y[0,40:subNum * trialNum]
            elif subNo == 31:
                testX = X[1240:1280, :]
                testY = Y[0,1240:1280]
                trainX = X[0:1240, :]
                trainY = Y[0,0:1240]
            else:
                testX = X[subNo * trialNum:(subNo + 1) * trialNum, :]
                testY = Y[0,subNo * trialNum:(subNo + 1) * trialNum]
                trainX = np.vstack((X[0:subNo * trialNum, :], X[(subNo + 1) * trialNum:subNum * trialNum, :]))
                trainY = np.concatenate((Y[0,0:subNo * trialNum], Y[0,(subNo + 1) * trialNum:subNum * trialNum]))

            # svm
            clf1 = svm.SVC(kernel='linear', probability=False)
            clf1.fit(trainX, trainY)
            predict_testY = clf1.predict(testX)
            f1_scores[rhy_no, ch_no, subNo] = metrics.f1_score(testY, predict_testY)
            acc_scores[rhy_no, ch_no, subNo] = metrics.accuracy_score(testY, predict_testY)
            print('channelType: ', ch_no, ' rhythm: ', rhythms[rhy_no], ' sub: ', subNo, ' performance: ',
                  acc_scores[rhy_no, ch_no, subNo])


# save results
sio.savemat('acc_scores_subcross_channeltype_DEAP.mat', {'results': acc_scores})
sio.savemat('f1_scores_subcross_channeltype_DEAP.mat', {'results': f1_scores})
