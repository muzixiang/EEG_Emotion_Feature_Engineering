%设定各个trial的label 0：低 1：高
data = load('personal_1280_trial_rating_valence_arousal_dominance_liking.mat');
scores = data.scoredata;
valenceScores = scores(:,1);
arousalScores = scores(:,2);
dominanceScores = scores(:,3);
length = size(scores,1);
trial_labels = zeros(1280,3);
for i=1:length
    score = valenceScores(i);
    if score>5
        trial_labels(i,1)=1;
    else
        trial_labels(i,1)=-1;
    end
    
    score = arousalScores(i);
    if score>5
        trial_labels(i,2)=1;
    else
        trial_labels(i,2)=-1;
    end
    
    score = dominanceScores(i);
    if score>5
        trial_labels(i,3)=1;
    else
        trial_labels(i,3)=-1;
    end
end
save('trial_labels_personal_valence_arousal_dominance.mat','trial_labels');