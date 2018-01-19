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

channelTypeNum = 62
rhythmNum = 5
rhythms = ['Theta','Alpha','Beta','Gamma','All']

#load data Y
yfile = sio.loadmat('.//subY_all_SEED.mat')
subY_all = yfile['y']

# theta alpha beta gamma all
f1_scores = np.zeros((rhythmNum, channelTypeNum, subNum))
acc_scores = np.zeros((rhythmNum, channelTypeNum, subNum))

for ch_no in range(0,channelTypeNum):
    for rhy_no in range(0,rhythmNum):
        xfile = sio.loadmat('.//SubX_ChannelType//subX_channel_type_'+str(ch_no+1)+'_'+rhythms[rhy_no]+'_SEED.mat')
        subX_all = xfile['f']
        ## scale data
        min_max_scaler = preprocessing.MinMaxScaler()
        subX_all = min_max_scaler.fit_transform(subX_all)
        X = subX_all
        Y = subY_all
        print X.shape
        print Y.shape
        for subNo in range(0, subNum):
            if subNo == 0:
                testX = X[0:30, :]
                testY = Y[0,0:30]
                trainX = X[30:450, :]
                trainY = Y[0,30:450]
            elif subNo == 14:
                testX = X[420:450, :]
                testY = Y[0,420:450]
                trainX = X[0:420, :]
                trainY = Y[0,0:420]
            else:
                testX = X[subNo * subTrialNum:(subNo + 1) * subTrialNum:]
                testY = Y[0,subNo * subTrialNum:(subNo + 1) * subTrialNum]
                trainX = np.vstack((X[0:subNo * subTrialNum, :], X[(subNo + 1) * subTrialNum:subNum * subTrialNum, :]))
                trainY = np.concatenate((Y[0,0:subNo * subTrialNum], Y[0,(subNo + 1) * subTrialNum:subNum * subTrialNum]))

            # svm
            clf1 = svm.SVC(kernel='linear', probability=False)
            clf1.fit(trainX, trainY)
            predict_testY = clf1.predict(testX)
            f1_scores[rhy_no, ch_no, subNo] = metrics.f1_score(testY, predict_testY)
            acc_scores[rhy_no, ch_no, subNo] = metrics.accuracy_score(testY, predict_testY)
            print('channelType: ', ch_no, ' rhythm: ', rhythms[rhy_no], ' sub: ', subNo, ' performance: ', acc_scores[rhy_no, ch_no, subNo])


# save results
sio.savemat('acc_scores_subcross_channeltype_SEED.mat', {'results': acc_scores})
sio.savemat('f1_scores_subcross_channeltype_SEED.mat', {'results': f1_scores})
