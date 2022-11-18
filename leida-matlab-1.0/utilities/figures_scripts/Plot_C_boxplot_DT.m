function Plot_C_boxplot_DT(data_dir,save_dir,selectedK,centroid,parcellation, index100areas)
%
% Plot the boxplot of dwell time (DT) values by condition for the selected
% PL state.
%
% INPUT:
% data_dir      directory where LEiDA results are stored
% save_dir      directory to save results for selected optimal K
% selectedK     K defined by the user
% centroid      centroid defined by the user
% parcellation  parcellation atlas used to segement the brain
%
% OUTPUT:
% .fig/.png     Boxplot of the dwell time values for each condition for
%               the selected centroid
%
% Authors: Miguel Farinha, University of Minho, miguel.farinha@ccabraga.org
%          Joana Cabral, University of Minho, joanacabral@med.uminho.pt

% File with the Kmeans results (output from LEiDA_cluster.m)
file_cluster = 'LEiDA_Clusters.mat';
% File with results for the dwell time (output from LEiDA_stats_DwellTime.m)
file_LT = 'LEiDA_Stats_DwellTime.mat';

%User (Niamh) EDIT - add in line specifing the file with 100 kept AAL regions
load('/Volumes/hwhalley-adol-imaging/irritability_project/LEIDA_Toolbox/LEiDAKeptAALRegionsIdx.mat','KeptRegionsIdx')
index100areas=KeptRegionsIdx;

% Load required data:
if isfile([data_dir file_cluster])
    load([data_dir file_cluster], 'Kmeans_results', 'rangeK');
end
if isfile([data_dir file_LT])
    load([data_dir file_LT], 'cond', 'LT', 'LT_pval2sided', 'Index_Conditions');
end

% Number of conditions of the experiment
n_Cond = size(cond,2);

% Matrix of dimension selectedK*90 where each row represents one FC state
V = Kmeans_results{rangeK == selectedK}.C;

% Number of areas considered for analysis
n_areas = size(V,2);

% Color code from paper Yeo et al., 2011
YeoColor = [125 50 125; 50 50 200; 0 118 14; 196 58 250; 150 200 100; 256 175 25; 240 90 0]./256;

% Compute the overlap between cluster centroids obtained for each value of
% K and the resting-state networks defined by Yeo et al. 2011
[cc_V_yeo7, p_V_yeo7] = Overlap_LEiDA_Yeo(parcellation,n_areas,Kmeans_results,rangeK, index100areas);
clear Kmeans_results


disp(' ');
disp(['Plotting the boxplot of dwell time values by condition for PL state ' num2str(centroid) ':'])

[~, net] = max(cc_V_yeo7(rangeK == selectedK,centroid,:));
LT_cond = cell(1,n_Cond);
r = cell(1,n_Cond);
for j = 1:n_Cond
    LT_cond{j} = LT(Index_Conditions == j,rangeK == selectedK,centroid);
    r{j} = repmat(cond(j), length(LT(Index_Conditions == j,rangeK == selectedK,centroid)),1);
end
LT_data = vertcat(LT_cond{:});
r_data = vertcat(r{:});
    
Fig = figure;
bx = boxplot(LT_data, r_data, 'Symbol', 'k.','OutlierSize',7, 'Widths',0.5);
set(bx,{'linew'},{1})
b = get(get(gca,'children'),'children');   % Get the handles of all the objects
f = get(b,'tag');   % List the names of all the objects
med_col = b(n_Cond+1:n_Cond*2);
set(med_col, 'Color', 'k');
box_col = b(n_Cond*2+1:n_Cond*3);
if p_V_yeo7(rangeK == selectedK,centroid,net) < 0.05/selectedK
    set(box_col, 'Color', YeoColor(net,:));
else
    set(box_col, 'Color', 'k');
end
    
hold on
set(gca,'XTickLabel',cond,'Fontsize',12)
xtickangle(30)
ylabel('Dwell Time (s)','Fontsize',12);
set(gca,'color','none')

X_locations = zeros(n_Cond*(n_Cond-1)/2,2);
cond_pair = 1;
for cond1 = 1:n_Cond-1
    for cond2 = cond1+1:n_Cond
        X_locations(cond_pair,1) = cond1;
        X_locations(cond_pair,2) = cond2;
        cond_pair = cond_pair + 1;
    end
end
% X_locations = sortrows(X_locations,2);
X_locations(:,1) = X_locations(:,1) + 0.1;
X_locations(:,2) = X_locations(:,2) - 0.1;
Max_Y =  max(LT_data);
Y_LOCATIONS = Max_Y + (abs(X_locations(:,1) - X_locations(:,2)));

% Green asterisks
asterisks = find(LT_pval2sided(:,rangeK == selectedK,centroid) <= 0.05/selectedK);
plot(X_locations(asterisks,:)',[Y_LOCATIONS(asterisks) Y_LOCATIONS(asterisks)]','-g', 'LineWidth',1)
plot(mean(X_locations(asterisks,:),2) - 0.05, Y_LOCATIONS(asterisks)*1.025, '*','Color','g','Markersize',4)

if asterisks
    text(mean(X_locations(asterisks,:),2) + 0.05 , Y_LOCATIONS(asterisks)*1.025,...,
        [repmat('p=',numel(asterisks),1) num2str(LT_pval2sided(asterisks,rangeK == selectedK,centroid),'%10.1e')],'Fontsize',7)
end

% Blue asterisks
asterisks = find(LT_pval2sided(:,rangeK == selectedK,centroid) <= 0.05/sum(rangeK));
plot(X_locations(asterisks,:)',[Y_LOCATIONS(asterisks) Y_LOCATIONS(asterisks)]','-b', 'LineWidth',1)
plot(mean(X_locations(asterisks,:),2) - 0.05, Y_LOCATIONS(asterisks)*1.025, '*b','Markersize',4)

if asterisks
    text(mean(X_locations(asterisks,:),2) + 0.05 , Y_LOCATIONS(asterisks)*1.025,...,
        [repmat('p=',numel(asterisks),1) num2str(LT_pval2sided(asterisks,rangeK == selectedK,centroid),'%10.1e')],'Fontsize',7)
end

ylim([0 max(Y_LOCATIONS)*1.15])

hold off
box off
    
saveas(Fig, fullfile(save_dir, ['K' num2str(selectedK) 'C' num2str(centroid) '_BoxplotDwellTime.png']),'png');
saveas(Fig, fullfile(save_dir, ['K' num2str(selectedK) 'C' num2str(centroid) '_BoxplotDwellTime.fig']),'fig');
disp(['- Plot successfully saved as K' num2str(selectedK) 'C' num2str(centroid) '_BoxplotDwellTime']);

close all;