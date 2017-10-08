# gensim modules
# -*- coding: utf-8 -*-
#本程序用来画所有model的roc曲线
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve, auc  
import scipy.io as sio


emodim=0

if emodim==0:
	filepath1='valence_predict_probability_wrapper_revision.mat'
	filepath2='valence_predict_probability_filter_revision.mat'
	filepath3='valence_predict_probability_L1_revision.mat'
else:
	filepath1 = 'arousal_predict_probability_wrapper_revision.mat'
	filepath2 = 'arousal_predict_probability_filter_revision.mat'
	filepath3 = 'arousal_predict_probability_L1_revision.mat'

data1=sio.loadmat(filepath1)
data2=sio.loadmat(filepath2)
data3=sio.loadmat(filepath3)

#true label
tl_wrapper=data1['probas_labels'][:,2]
tl_chi2 = data2['probas_labels'][:,0,2]
tl_mi = data2['probas_labels'][:,1,2]
tl_af = data2['probas_labels'][:,2,2]
tl_l1 = data3['probas_labels'][:,2]

#predict probability
pp_wrapper=data1['probas_labels'][:,1]
pp_chi2 = data2['probas_labels'][:,0,1]
pp_mi = data2['probas_labels'][:,1,1]
pp_af = data2['probas_labels'][:,2,1]
pp_l1 = data3['probas_labels'][:,1]

fpr1, tpr1, thresholds1 = roc_curve(tl_wrapper, pp_wrapper, pos_label=1)
roc_auc1 = auc(fpr1, tpr1)
fpr2, tpr2, thresholds2 = roc_curve(tl_chi2, pp_chi2)
roc_auc2 = auc(fpr2, tpr2)
fpr3, tpr3, thresholds3 = roc_curve(tl_mi, pp_mi)
roc_auc3 = auc(fpr3, tpr3)
fpr4, tpr4, thresholds4 = roc_curve(tl_af, pp_af)
roc_auc4 = auc(fpr4, tpr4)
fpr5, tpr5, thresholds5 = roc_curve(tl_l1, pp_l1)
roc_auc5 = auc(fpr5, tpr5)


plt.plot(fpr2, tpr2, lw=1, label='ROC  %s (area = %0.3f)' % ("Chi2", roc_auc2))
plt.plot(fpr3, tpr3, lw=1, label='ROC  %s (area = %0.3f)' % ("MI", roc_auc3))
plt.plot(fpr4, tpr4, lw=1, label='ROC  %s (area = %0.3f)' % ("AF", roc_auc4))
plt.plot(fpr1, tpr1, lw=1, label='ROC  %s (area = %0.3f)' % ("RFE", roc_auc1))
plt.plot(fpr5, tpr5, lw=1, label='ROC  %s (area = %0.3f)' % ("L1", roc_auc5))
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate') 
plt.title('Receiver operating characteristic curve') 
plt.legend(loc="lower right") 
plt.show() 