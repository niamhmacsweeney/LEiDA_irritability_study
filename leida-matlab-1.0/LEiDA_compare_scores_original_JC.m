function LEiDA_compare_scores
%
% Function to compare behavioural data and Physiological markers with
% properties of LEiDA networks
%
%
% Fran Hancock
% May 2021 fran.hancock@kcl.ac.uk
% Modified by Joana Cabral and Vania Miguel
% May 2021
%
%
%%%%%%%


% File to load generated with LEiDA_cluster.m;
Kmeans_file='/Users/joana/Documents/Work/LEiDA general/LEiDA_HCP/LEiDA90_Centroids_V1_unfiltered_100unrelated';
load(Kmeans_file)

% File with Time_sessions
load('/Users/joana/Documents/Work/LEiDA general/LEiDA_HCP/LEiDAaal90_LR_unfiltered_100unrelated','Time_all')
Time_sessions=Time_all;
clear Time_all

signif_threshold=0.005;
%

N_Subjects=max(Time_sessions);

% Indicate the collumns in the table of scores that will be compared
ind_scores=3:31;    % all

table_scores = struct2array(load('HCP_Scores'));


for score=1:length(ind_scores)
    
    disp(' ')
    disp([table_scores.Properties.VariableNames{ind_scores(score)}  ' - Collumn ' num2str(ind_scores(score))])
    
    Scores=table2array(table_scores(:,ind_scores(score)));
    
    for K=1:length(rangeK)
        
        for c=1:rangeK(K)
            
            Pkc=squeeze(P(:,K,c));
            % Calculate correlation between Scores and Probability of
            % Network
            [cc, p]=corr(Pkc,Scores, 'Type','Spearman');
            P_pval(score,K,c)=p;
            P_corr(score,K,c)=cc;
            
            if P_pval(score,K,c)<(signif_threshold)
                disp(['signif correlation with prob Network =' num2str(c) ' for K=' num2str(rangeK(K))])
                disp(['cc=' num2str(cc) ' p=' num2str(p)])
            end
            
            Lkc=squeeze(LT(:,K,c));
            [cc, p]=corr(Lkc,Scores,'Type','Spearman');
            LT_pval(score,K,c)=p;
            LT_corr(score,K,c)=cc;
            
            if LT_pval(score,K,c)<(signif_threshold)
                disp(['signif correlation with duration of Network =' num2str(c) ' for K=' num2str(rangeK(K))])
                disp(['cc=' num2str(cc) ' p=' num2str(p)])
            end
        end
    end
    
end


