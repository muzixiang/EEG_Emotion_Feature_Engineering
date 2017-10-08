emodim = 0;
if emodim==0
    dat = load('valence_feature_number_count_L1_Revision.mat');
else
    dat = load('arousal_feature_number_count_L1_Revision.mat');
end

feature_idxs=2360;
feature_counts = dat.results;

ch_count=zeros(1,32);
asy_count=zeros(1,14);
r_count=zeros(1,4);
f_count = zeros(4,18);
lr = zeros(2,2);
LA=[1,2,3,4,5,6];
RA=[17,18,20,21,22,23];
LP=[9,10,11,12,13,14];
RP=[27,28,29,30,31,32];

%analyzing critical channels....according to channels
% (9+9)*32+14=590 per rhythm
for idx = 1:feature_idxs
    y = mod(idx,590);
    if y==0
        y=590;
    end
    if y<=576
        ch_no = ceil(double(y)/double(18));
        ch_count(1,ch_no)=ch_count(1,ch_no)+feature_counts(1,idx);
    else
        continue;%
    end
end

%analyzing critical pairs....according to channels
% (9+9)*32+14=590 per rhythm
for idx = 1:feature_idxs
    y = mod(idx,590);
    if y==0
       y=590;
    end
    if y<=576
        continue;%
    else
        asy_no = y-576;
        asy_count(1,asy_no)=asy_count(1,asy_no)+feature_counts(1,idx);
    end
end

%analyzing critical components...according to rhythms
for idx = 1:feature_idxs
    r = double(idx)/double(590);
    rhy_no = ceil(r);%向大取整
    r_count(1,rhy_no)=r_count(1,rhy_no)+feature_counts(1,idx);
end

%analyzing critical components: linear+nonlinear
% (:,1) = PPmean; (:,2) = meanSquare; (:,3) = variance; (:,4) = activity; (:,5) = mobility; (:,6) = complexity; (:,7) = f0; (:,8) = maxs; (:,9) = sumPower;
% (:,1) = ApEn; (:,2) = C0 Complexity; (:,3) = correlation dimension; (:,4) = kolmogorov entropy  (:,5) = lyapunov exponent; (:,6) = permutation entropy; (:,7) = singular entropy; (:,8) = shannon entropy; (:,9) = spectral_entropy;
% valence 分析beta节律部分 arousal 分析theta节律部分
for idx = 1:feature_idxs
    r = ceil(double(idx)/double(590));
    y = mod(idx,590);
    if y==0
       y=590;
    end
    if y<=576
        x = mod(y,18);
        if x==0
            x=18;
        end
        f_count(r,x)=f_count(r,x)+feature_counts(1,idx);
    else
        continue;
    end
end

%analyzing critical components: left centro_anterior, right centro_anterior, left posterior, right posterior
%channel No. LA={1,2,3,4,5,6,7}, RA={17,18,20,21,22,23,25}
%channel No. LP={8,9,10,11,12,13,14}, RP={26,27,28,29,30,31,32}
for idx = 1:feature_idxs
    y = mod(idx,590);
    if y==0
        y=590;
    end
    if y<=576
         ch_no = ceil(double(y)/double(18));
        if ismember(ch_no,LA)
            lr(1,1)=lr(1,1)+feature_counts(1,idx);
        elseif ismember(ch_no, RA)
            lr(1,2)=lr(1,2)+feature_counts(1,idx);
        elseif ismember(ch_no,LP)
            lr(2,1)=lr(2,1)+feature_counts(1,idx);
        elseif ismember(ch_no,RP)
            lr(2,2)=lr(2,2)+feature_counts(1,idx);
        end
    else
        continue;%
    end
end