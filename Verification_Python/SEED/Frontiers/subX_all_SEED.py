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
featureTypeNum = 18


#non neutral trial index
trial_indx = [0,2,3,5,6,8,9,11,13,14]


#load data Y
file1 = sio.loadmat('.//trial_label.mat')
Y = file1['label']


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


#save results
sio.savemat('subX_all_SEED.mat', {'x': subX_all})
sio.savemat('subY_all_SEED.mat', {'y': subY_all})

