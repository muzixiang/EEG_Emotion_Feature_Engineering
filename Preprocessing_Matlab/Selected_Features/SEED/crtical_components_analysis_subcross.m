
dat = load('feature_number_count_L1_Revision.mat');

feature_idxs=4572;
feature_counts = dat.results;

ch_count=zeros(1,62);
asy_count=zeros(1,27);
r_count=zeros(1,4);
f_count = zeros(4,18);
lr = zeros(2,2);
LA=[1,4,6,7,8,9,15,16,17,18];
RA=[3,5,14,13,12,11,23,22,21,20];
LP=[33,34,35,36,42,43,44,45,51,52,53,58,59];
RP=[41,40,39,38,50,49,48,47,57,56,55,62,61];

%analyzing critical channels....according to channels
% (9+9)*62+27=1143 per rhythm
for idx = 1:feature_idxs
    y = mod(idx,1143);
    if y==0
        y=1143;
    end
    if y<=1116
        ch_no = ceil(double(y)/double(18));
        ch_count(1,ch_no)=ch_count(1,ch_no)+feature_counts(1,idx);
    else
        continue;%
    end
end

%analyzing critical pairs....according to channels
% (9+9)*62+27=1143 per rhythm
for idx = 1:feature_idxs
    y = mod(idx,1143);
    if y==0
       y=1143;
    end
    if y<=1116
        continue;%
    else
        asy_no = y-1116;
        asy_count(1,asy_no)=asy_count(1,asy_no)+feature_counts(1,idx);
    end
end

%analyzing critical components...according to rhythms
for idx = 1:feature_idxs
    r = double(idx)/double(1143);
    rhy_no = ceil(r);%向大取整
    r_count(1,rhy_no)=r_count(1,rhy_no)+feature_counts(1,idx);
end

%analyzing critical components: linear+nonlinear
% (:,1) = PPmean; (:,2) = meanSquare; (:,3) = variance; (:,4) = activity; (:,5) = mobility; (:,6) = complexity; (:,7) = f0; (:,8) = maxs; (:,9) = sumPower;
% (:,1) = ApEn; (:,2) = C0 Complexity; (:,3) = correlation dimension; (:,4) = kolmogorov entropy  (:,5) = lyapunov exponent; (:,6) = permutation entropy; (:,7) = singular entropy; (:,8) = shannon entropy; (:,9) = spectral_entropy;
for idx = 1:feature_idxs
    r = ceil(double(idx)/double(1143));
    y = mod(idx,1143);
    if y==0
       y=1143;
    end
    if y<=1116
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
for idx = 1:feature_idxs
    y = mod(idx,1143);
    if y==0
        y=1143;
    end
    if y<=1116
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