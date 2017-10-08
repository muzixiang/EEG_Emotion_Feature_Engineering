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

hemisphereNum = 8
rhythmNum = 5
rhythms = ['Theta','Alpha','Beta','Gamma','All']

#load data Y
yfile = sio.loadmat('.//subY_all_SEED.mat')
subY_all = yfile['y']

# theta alpha beta gamma all
f1_scores = np.zeros((rhythmNum, hemisphereNum, subNum))
acc_scores = np.zeros((rhythmNum, hemisphereNum, subNum))

LA=[1,4,6,7,8,9,15,16,17,18]
RA=[3,5,14,13,12,11,23,22,21,20]
LP=[33,34,35,36,42,43,44,45,51,52,53,58,59]
RP=[41,40,39,38,50,49,48,47,57,56,55,62,61]
L = [1,4,6,7,8,9,15,16,17,18,33,34,35,36,42,43,44,45,51,52,53,58,59]
R = [3,5,14,13,12,11,23,22,21,20,41,40,39,38,50,49,48,47,57,56,55,62,61]
A = [1,4,6,7,8,9,15,16,17,18,3,5,14,13,12,11,23,22,21,20]
P = [33,34,35,36,42,43,44,45,51,52,53,58,59,41,40,39,38,50,49,48,47,57,56,55,62,61]

for hm_no in range(0,hemisphereNum):
    for rhy_no in range(0,rhythmNum):
        if hm_no == 0:
            chs = LA
        elif hm_no == 1:
            chs = RA
        elif hm_no == 2:
            chs = LP
        elif hm_no == 3:
            chs = RP
        elif hm_no == 4:
            chs = L
        elif hm_no == 5:
            chs = R
        elif hm_no == 6:
            chs = A
        else:
            chs = P

        if rhy_no<4:
            subX_all = np.zeros((450,18*len(chs)))
        else:
            subX_all = np.zeros((450, 18 * len(chs)*4))

        ## concatenate channel information
        i = 0
        for ch_no in chs:
            xfile = sio.loadmat(
                './/SubX_ChannelType//subX_channel_type_' + str(ch_no) + '_' + rhythms[rhy_no] + '_SEED.mat')
            ch_all = xfile['f']

            if rhy_no<4:
                subX_all[:, i*18:(i+1)*18] = ch_all
            else:
                subX_all[:, i * 18*4:(i + 1) * 18*4] = ch_all
            i = i+1

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
            f1_scores[rhy_no, hm_no, subNo] = metrics.f1_score(testY, predict_testY)
            acc_scores[rhy_no, hm_no, subNo] = metrics.accuracy_score(testY, predict_testY)
            print('hemiType: ', hm_no, ' rhythm: ', rhythms[rhy_no], ' sub: ', subNo, ' performance: ', acc_scores[rhy_no, hm_no, subNo])


# save results
sio.savemat('acc_scores_subcross_hemitype_SEED.mat', {'results': acc_scores})
sio.savemat('f1_scores_subcross_hemitype_SEED.mat', {'results': f1_scores})
