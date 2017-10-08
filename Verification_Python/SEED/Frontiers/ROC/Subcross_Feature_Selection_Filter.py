from sklearn import svm
import scipy.io as sio
from sklearn import preprocessing
import numpy as np
import h5py
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import chi2, f_classif, mutual_info_classif


bestK = [200, 20, 20]


subNum = 15
trialNum = 10
expNum = 3
subTrialNum = trialNum*expNum
# ((9+9)*62+27)*4
featureDim = 4572


#non neutral trial index
trial_indx = [0,2,3,5,6,8,9,11,13,14]

#load data Y
file1 = sio.loadmat('..//trial_label.mat')
Y = file1['label']

#predict probability and true labels for 15 subjects. 3 methods,  2 for probability and 1 for true label
probas_labels = np.zeros((subNum*subTrialNum,3,3))

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
    # three feature selection method...
    # method 1
    sel_criteria1 = SelectKBest(chi2, k=bestK[0]).fit(trainX, trainY)
    sel_indx1_mask = sel_criteria1.get_support()
    sel_indx1 = np.where(sel_indx1_mask == True)
    sel_indx1 = sel_indx1[0]
    trainX1 = trainX[:, sel_indx1]
    testX1 = testX[:, sel_indx1]
    clf1 = svm.SVC(kernel='linear', probability=True)
    clf1.fit(trainX1, trainY)
    predict_probas = clf1.predict_proba(testX1)
    print predict_probas
    probas_labels[subNo * subTrialNum:(subNo + 1) * subTrialNum, 0, 0:2] = predict_probas
    probas_labels[subNo * subTrialNum:(subNo + 1) * subTrialNum, 0, 2] = testY

    # method 2
    sel_criteria2 = SelectKBest(mutual_info_classif, k=bestK[1]).fit(trainX, trainY)
    sel_indx2_mask = sel_criteria2.get_support()
    sel_indx2 = np.where(sel_indx2_mask == True)
    sel_indx2 = sel_indx2[0]
    trainX2 = trainX[:, sel_indx2]
    testX2 = testX[:, sel_indx2]
    clf2 = svm.SVC(kernel='linear', probability=True)
    clf2.fit(trainX2, trainY)
    predict_probas = clf2.predict_proba(testX2)
    print predict_probas
    probas_labels[subNo * subTrialNum:(subNo + 1) * subTrialNum, 1, 0:2] = predict_probas
    probas_labels[subNo * subTrialNum:(subNo + 1) * subTrialNum, 1, 2] = testY

    # method 3
    sel_criteria3 = SelectKBest(f_classif, k=bestK[2]).fit(trainX, trainY)
    sel_indx3_mask = sel_criteria3.get_support()
    sel_indx3 = np.where(sel_indx3_mask == True)
    sel_indx3 = sel_indx3[0]
    trainX3 = trainX[:, sel_indx3]
    testX3 = testX[:, sel_indx3]
    clf3 = svm.SVC(kernel='linear', probability=True)
    clf3.fit(trainX3, trainY)
    predict_probas = clf3.predict_proba(testX3)
    print predict_probas
    probas_labels[subNo * subTrialNum:(subNo + 1) * subTrialNum, 2, 0:2] = predict_probas
    probas_labels[subNo * subTrialNum:(subNo + 1) * subTrialNum, 2, 2] = testY

#save results

sio.savemat('predict_probability_Filter.mat', {'probas_labels': probas_labels})
