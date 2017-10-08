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
from sklearn.feature_selection import RFE

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

f1_scores = np.zeros((457,subNum))
acc_scores = np.zeros((457,subNum))


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


for no_k in range(0,457):
    num_k = (no_k+1)*10
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

            clf = svm.SVC(kernel='linear')
            sel_criteria = RFE(estimator=clf, n_features_to_select=num_k, step=0.5).fit(trainX, trainY)
            sel_indx_mask = sel_criteria.get_support()
            sel_indx = np.where(sel_indx_mask == True)
            sel_indx = sel_indx[0]
            trainX = trainX[:, sel_indx]
            testX = testX[:, sel_indx]

            #svm
            clf1 = svm.SVC(kernel='linear')
            clf1.fit(trainX, trainY)
            predict_testY = clf1.predict(testX)
            f1_scores[no_k,subNo]=metrics.f1_score(testY, predict_testY)
            acc_scores[no_k,subNo]=metrics.accuracy_score(testY, predict_testY)


            print('current sub performance:', acc_scores[no_k,subNo], ' kbest:', num_k)


#save results
sio.savemat('f1_scores_valence_subcross_457steps_wrapper_step_0dot5.mat', {'results': f1_scores})
sio.savemat('acc_scores_valence_subcross_457steps_wrapper_step_0dot5.mat', {'results': acc_scores})
