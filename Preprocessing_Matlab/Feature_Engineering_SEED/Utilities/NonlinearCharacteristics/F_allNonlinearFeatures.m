function features = F_allNonlinearFeatures(fs,input,onetime,overlap)
     %ApEn
    [Em,Amean] = ApEn(input,fs,onetime,overlap);
    f1 = Amean;
    %C0 Complexity
    [C0,C0_average] = c0complex(input,fs,onetime,overlap,0);
    f2 = C0_average;
    %correlation dimension
    [CorrelationDimension,M_C] = reC(input,fs,onetime,overlap,0);
    f3 = M_C;
    %kolmogorov entropy
    [Km,Kmean]=kolmgolov_entropy(input,fs,onetime,overlap,0);
    f4 = Kmean;
    %lyapunov exponent
    [lambda_1,M_lya]=lyapunov_Rosentein(input,fs,onetime,overlap,0);
    f5 = M_lya;
    %permutation entropy
    [P_E,M_P]=permutation_entropy(input,fs,onetime,overlap);
    f6 = M_P;
    %singular entropy
    [H_singu, M_H]=singular_entropy(input,fs,onetime,overlap);
    f7 = M_H;
    %shannon entropy
    [H,Average_SHen]=shannon_entropy(input,fs,onetime,overlap);
    f8 = Average_SHen;
    %spectral entropy
    [PSen,Average_PSen]=spectral_entropy(input,fs,onetime,overlap,0);
    f9 = Average_PSen;
    features = [f1,f2,f3,f4,f5,f6,f7,f8,f9];      


