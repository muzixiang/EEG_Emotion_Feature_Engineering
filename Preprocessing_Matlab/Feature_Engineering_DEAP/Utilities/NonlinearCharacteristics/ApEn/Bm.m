function Phi=Bm(data,R,m,N)

M=N-m+1;
discount=zeros(M,1);
d=zeros(M,M);
Y=reconstitution(data,N,m,1);%重构相空间
for i=1:M
    for j=1:M
        d(i,j)=max(abs(Y(:,i)-Y(:,j)));%计算不同向量间距离
    end
end
H=abs(d)-R;%比较向量间距离与R的大小
for i=1:M
    discount(i)=length(find((H(i,:)<0)));
end
disc=discount-1;%统计向量i与其他向量间距离小于R的向量个数
Lpm=disc./(N-m);
for i=1:M
    if Lpm(i)~=0
        Dm(i)=log(Lpm(i));
    else
        Dm(i)=0;
    end
end
Phi=sum(Dm)/(N-m+1);