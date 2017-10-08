data = load('subX_all_SEED.mat');
subX_all = data.x;
rhythms = {'Theta','Alpha','Beta','Gamma','All'};
%È¥³ýÒì²½ÌØÕ÷
subX1 = subX_all(:,[1:1:1116]);
subX2 = subX_all(:,[1144:1:2259]);
subX3 = subX_all(:,[2287:1:3402]);
subX4 = subX_all(:,[3430:1:4545]);
non_asy_num = 4572-27*4;
non_asy_num_band = non_asy_num/4;
channel_num = 62;
rhy_num = 5;
for ch_no = 1:channel_num
    for rhy_no = 1:rhy_num
        if rhy_no==1
            f = subX1(:,(ch_no-1)*18+1:ch_no*18);
        elseif rhy_no==2
            f = subX2(:,(ch_no-1)*18+1:ch_no*18);
        elseif rhy_no==3
            f = subX3(:,(ch_no-1)*18+1:ch_no*18);
        elseif rhy_no==4
            f = subX4(:,(ch_no-1)*18+1:ch_no*18);
        else
            f = [subX1(:,(ch_no-1)*18+1:ch_no*18),subX2(:,(ch_no-1)*18+1:ch_no*18),subX3(:,(ch_no-1)*18+1:ch_no*18),subX4(:,(ch_no-1)*18+1:ch_no*18)];
        end
        save(strcat('subX_channel_type_',num2str(ch_no),'_',rhythms{rhy_no},'_SEED.mat'),'f');
    end
end