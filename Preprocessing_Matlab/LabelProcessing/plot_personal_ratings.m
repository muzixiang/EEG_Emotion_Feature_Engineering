data = load('personal_1280_trial_rating_valence_arousal_dominance_liking.mat');
scoredata = data.scoredata;
scoredata = data.scoredata;

%data = load('D:\我的坚果云\Project Files\Matlab\DEAP2\label\general_40_stimuli_avgrating_valence_arousal_dominance.mat');
%scoredata = online_avg_ratings;
vscore = scoredata(:,1);
ascore = scoredata(:,2);
for i=1:1280
    if(vscore(i)>5&ascore(i)>5)
        plot(vscore(i),ascore(i),'o','markerfacecolor', 'r');hold on;
    elseif(vscore(i)>5&ascore(i)<5)
        plot(vscore(i),ascore(i),'o','markerfacecolor', 'm');hold on;
    elseif(vscore(i)<5&ascore(i)<5)
        plot(vscore(i),ascore(i),'o','markerfacecolor', 'g');hold on;
    else
        plot(vscore(i),ascore(i),'o','markerfacecolor', 'y');hold on;
    end
end
xlabel('VALENCE');
ylabel('AROUSAL');
