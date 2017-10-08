%%%%%%%%%%%%%%%%Permutation entropy%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%window_t为每次计算的窗口时间长度，overlap为重叠比率如0.5

%%%%%%%author:lanlanli
%%%%%%%date:2010.09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [P_E,M_P]=permuatation_entropy(A,Fs,window_t,overlap)
N=Fs*window_t;%每次计算的序列长度
g=Fs*(window_t*(1-overlap));%每次滑动的点数

G=length(A);
t=((G-N)/g);
h=floor(t);
m=15;

for ii=0:h %滑动的次数
     data=A(1+ii*g:N+ii*g);
     tau=tau_def(data);
     M=N-(m-1)*tau;%相空间每一维序列的长度
     Y=reconstitution(data,N,m,tau)';%重构相空间
     [X,I]=sort(Y,2);
     B=unique(I,'rows');
     [Point,K]=size(B);
     C=zeros(Point,1);
     for i=1:Point
         for j=1:M
             if B(i,:)==I(j,:)
                 C(i)=C(i)+1;
             end
         end
     end
     P_pi=C./M;
     Log_pi=log(P_pi);
     H_m=-sum(P_pi.*Log_pi);
     P_E(ii+1)=H_m/(m-1);
    end
M_P=mean(P_E);
             
                 
                    
                         
             
    
   