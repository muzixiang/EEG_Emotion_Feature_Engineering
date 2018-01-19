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

# 0 valence 1 arousal
emodim = 0

#load data Y
file1 = sio.loadmat('.//trial_labels_personal_valence_arousal_dominance.mat')
Y = file1['trial_labels']


f1_scores = np.zeros((100,32))
acc_scores = np.zeros((100,32))

subX_all = np.zeros((subNum*trialNum, featureDim))
subY_all = np.zeros((subNum*trialNum))

## combine all subjects' samples...
for subNo in range(0, subNum):
    file2 = h5py.File(
        'D://LX//Processed DEAP DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//BetaRhythm//WindowTime4_sub' + str(
            subNo + 1) + '.mat', 'r')
    file3 = h5py.File(
        'D://LX//Processed DEAP DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//GammaRhythm//WindowTime4_sub' + str(
            subNo + 1) + '.mat', 'r')
    file4 = h5py.File(
        'D://LX//Processed DEAP DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//AlphaRhythm//WindowTime4_sub' + str(
            subNo + 1) + '.mat', 'r')
    file5 = h5py.File(
        'D://LX//Processed DEAP DATA//FeatureEngineering//EEG//Frontiers//NoScaleRawData_RhythmExtraction//ThetaRhythm//WindowTime4_sub' + str(
            subNo + 1) + '.mat', 'r')
    subX1 = file2['EEG_Features']
    subX1 = np.transpose(subX1)
    subX2 = file3['EEG_Features']
    subX2 = np.transpose(subX2)
    subX3 = file4['EEG_Features']
    subX3 = np.transpose(subX3)
    subX4 = file5['EEG_Features']
    subX4 = np.transpose(subX4)
    subX = np.hstack((subX4, subX3, subX1, subX2)) # with order of : theta alpha beta gamma
    subY = Y[subNo*trialNum:(subNo+1)*trialNum, emodim]

    subX_all[subNo*trialNum:(subNo+1)*trialNum,:] = subX
    subY_all[subNo*trialNum:(subNo+1)*trialNum] = subY


## scale data
min_max_scaler = preprocessing.MinMaxScaler()
subX_all = min_max_scaler.fit_transform(subX_all)
Y = subY_all
X= subX_all

for no_c in range(0,100):
    for subNo in range(0, subNum):
        print("Building model and test for ------------------------------------------------------------------------------------------------ sub " + str(subNo + 1))
        if subNo == 0:
            testX = X[0:40,:]
            testY = Y[0:40]
            trainX = X[40:subNum*trialNum,:]
            trainY = Y[40:subNum*trialNum]
        elif subNo == 31:
            testX = X[1240:1280,:]
            testY = Y[1240:1280]
            trainX = X[0:1240,:]
            trainY = Y[0:1240]
        else:
            testX = X[subNo*trialNum:(subNo+1)*trialNum, :]
            testY = Y[subNo*trialNum:(subNo+1)*trialNum]
            trainX = np.vstack((X[0:subNo*trialNum, :], X[(subNo+1)*trialNum:subNum*trialNum, :]))
            trainY = np.concatenate((Y[0:subNo*trialNum], Y[(subNo+1)*trialNum:subNum*trialNum]))

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
        print predict_testY
        f1_scores[no_c,subNo]=metrics.f1_score(testY, predict_testY)
        acc_scores[no_c,subNo]=metrics.accuracy_score(testY, predict_testY)
        print('current sub performance:', acc_scores[no_c,subNo], ' c:', num_c)


#save results
if emodim==0:
    #save results
    sio.savemat('f1_scores_valence_subcross_100steps_L1_Revision.mat', {'results': f1_scores})
    sio.savemat('acc_scores_valence_subcross_100steps_L1_Revision.mat', {'results': acc_scores})
else:
    sio.savemat('f1_scores_arousal_subcross_100steps_L1_Revision.mat', {'results': f1_scores})
    sio.savemat('acc_scores_arousal_subcross_100steps_L1_Revision.mat', {'results': acc_scores})