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

f1_scores = np.zeros((100,subNum))
acc_scores = np.zeros((100,subNum))

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
Y = subY_all
X = subX_all

for no_c in range(0,100):
    for subNo in range(0, subNum):
            print("Building model and test for ------------------------------------------------------------------------------------------------ sub " + str(subNo + 1))
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
                testX = X[subNo * subTrialNum:(subNo + 1) * subTrialNum:]
                testY = Y[subNo * subTrialNum:(subNo + 1) * subTrialNum]
                trainX = np.vstack((X[0:subNo * subTrialNum, :], X[(subNo + 1) * subTrialNum:subNum * subTrialNum, :]))
                trainY = np.concatenate((Y[0:subNo * subTrialNum], Y[(subNo + 1) * subTrialNum:subNum * subTrialNum]))
            num_c = (no_c + 1) * 0.01
            lsvc = LinearSVC(C=num_c, penalty="l1", dual=False).fit(trainX, trainY)
            sel_indx1_mask = SelectFromModel(lsvc, prefit=True).get_support()
            sel_indx1 = np.where(sel_indx1_mask == True)
            sel_indx1 = sel_indx1[0]
            trainX = trainX[:, sel_indx1]
            testX = testX[:, sel_indx1]

            #svm
            clf1 = svm.SVC(kernel='linear', probability=False)
            clf1.fit(trainX, trainY)
            predict_testY = clf1.predict(testX)
            f1_scores[no_c,subNo]=metrics.f1_score(testY, predict_testY)
            acc_scores[no_c,subNo]=metrics.accuracy_score(testY, predict_testY)
            print('current sub performance:', acc_scores[no_c,subNo], ' c:', num_c)


#save results
sio.savemat('f1_scores_valence_subcross_100steps_L1.mat', {'results': f1_scores})
sio.savemat('acc_scores_valence_subcross_100steps_L1.mat', {'results': acc_scores})
