from sklearn import svm
from sklearn.ensemble import RandomForestClassifier
from sklearn import neighbors
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB
from sklearn.neural_network import MLPClassifier

import scipy.io as sio
from sklearn import preprocessing
import numpy as np
from sklearn import metrics
import h5py
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import chi2, f_classif, mutual_info_classif

subNum = 32
trialNum = 40
featureDim = 2360

# 0 valence 1 arousal
emodim = 0

#load data Y
file1 = sio.loadmat('.//trial_labels_personal_valence_arousal_dominance.mat')
Y = file1['trial_labels']

f1_scores = np.zeros((236,3,32))
acc_scores = np.zeros((236,3,32))

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
X = min_max_scaler.fit_transform(subX_all)
Y = subY_all


for no_k in range(0,236):
        num_k = (no_k+1)*10
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

            # three feature selection method...
            # method 1
            sel_criteria1 = SelectKBest(chi2, k=num_k).fit(trainX, trainY)
            sel_indx1_mask = sel_criteria1.get_support()
            sel_indx1 = np.where(sel_indx1_mask == True)
            sel_indx1 = sel_indx1[0]
            trainX1 = trainX[:,sel_indx1]
            testX1 = testX[:,sel_indx1]
            # svm
            clf1 = svm.SVC(kernel='linear')
            clf1.fit(trainX1, trainY)
            predict_testY1 = clf1.predict(testX1)
            f1_scores[no_k, 0, subNo] = metrics.f1_score(testY, predict_testY1)
            acc_scores[no_k, 0, subNo] = metrics.accuracy_score(testY, predict_testY1)
            print(
            'current sub performance:', acc_scores[no_k, 0, subNo], ' kbest:', num_k, ' selection_method:', 1)

            # method 2
            sel_criteria2 = SelectKBest(mutual_info_classif, k=num_k).fit(trainX, trainY)
            sel_indx2_mask = sel_criteria2.get_support()
            sel_indx2 = np.where(sel_indx2_mask == True)
            sel_indx2 = sel_indx2[0]
            trainX2 = trainX[:, sel_indx2]
            testX2 = testX[:, sel_indx2]
            # svm
            clf2 = svm.SVC(kernel='linear')
            clf2.fit(trainX2, trainY)
            predict_testY2 = clf2.predict(testX2)
            f1_scores[no_k, 1, subNo] = metrics.f1_score(testY, predict_testY2)
            acc_scores[no_k, 1, subNo] = metrics.accuracy_score(testY, predict_testY2)
            print(
            'current sub performance:', acc_scores[no_k, 1, subNo], ' kbest:', num_k, ' selection_method:', 2)

            # method 3
            sel_criteria3 = SelectKBest(f_classif, k=num_k).fit(trainX, trainY)
            sel_indx3_mask = sel_criteria3.get_support()
            sel_indx3 = np.where(sel_indx3_mask == True)
            sel_indx3 = sel_indx3[0]
            trainX3 = trainX[:, sel_indx3]
            testX3 = testX[:, sel_indx3]
            # svm
            clf3 = svm.SVC(kernel='linear')
            clf3.fit(trainX3, trainY)
            predict_testY3 = clf3.predict(testX3)
            f1_scores[no_k, 2, subNo] = metrics.f1_score(testY, predict_testY3)
            acc_scores[no_k, 2, subNo] = metrics.accuracy_score(testY, predict_testY3)
            print('current sub performance:', acc_scores[no_k, 2, subNo], ' kbest:', num_k, ' selection_method:', 3)




#save results
if emodim==0:
    #save results
    sio.savemat('f1_scores_valence_subcross_236steps_filter_revision.mat', {'results': f1_scores})
    sio.savemat('acc_scores_valence_subcross_236steps_filter_revision.mat', {'results': acc_scores})
else:
    sio.savemat('f1_scores_arousal_subcross_236steps_filter_revision.mat', {'results': f1_scores})
    sio.savemat('acc_scores_arousal_subcross_236steps_filter_revision.mat', {'results': acc_scores})