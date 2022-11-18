%% LEiDA_prep_data_LR.m
%
% LEADING EIGENVECTOR DYNAMICS ANALYSIS (LEiDA)
%
% This script prepares the data for use in the LEiDA Toolbox scripts by J.
% Cabral, June 2022. 

% We are using the resting pure and resting irritability with two
% conditions in each, depressed and non-depressed
% This gives 4 conditions in total. 



% 1 - convert files from .csv to .mat for rest irrit 
% 2 - detect NaNs for each participant across two scan conditions
% 3 - Remove regions that have any NaNs for a participant across both
% conditions. 
% 4 - Make index of non NaN regions in the AAL 120 order so that LEiDA
% knows what brain regions are being used. 

% Steps 1 & 2 & 3

%Irritability condition
% 20 regions have one or more NaNs across participants
%This leaves 100 regions to work with

% Folders = { '/Volumes/hwhalley-adol-imaging/irritability_project/data/LEiDA_timeseries_irrit_data'; ...
%             '/Volumes/hwhalley-adol-imaging/irritability_project/data/LEiDA_timeseries_rest_data' };

Folders = { '/Volumes/hwhalley-adol-imaging/irritability_project/data/LEiDA_timeseries_irrit_data'; ...
            '/Volumes/hwhalley-adol-imaging/irritability_project/data/LEiDA_timeseries_rest_data'};
NanRegionIdxCondition = cell(1, length(Folders));
NanRegionIdxComplete = [];
for k = 1:length(Folders)

  Folder = Folders{k};
  disp('Identifying NaN regions for timeseries data in: ');
  disp(Folder);

  FileList = dir(fullfile(Folder, 'sub*.csv'));
  for iFile = 1:numel(FileList)
    [~, name, ext] = fileparts(FileList(iFile).name);
    data = readtable(fullfile(Folder, [name, ext]));
    data = table2array(data);
    data = data';
    NanIdx = find(isnan(data(:, 1)));
    disp('Participant regions with NaN: '); NanRegions = length(NanIdx)
    NanRegionIdxCondition{k} = union(NanRegionIdxCondition{k}, NanIdx);
  end 
  
  NanRegionIdxComplete = ...
      union(NanRegionIdxComplete, NanRegionIdxCondition{k});

end

for k = 1:length(Folders)
  Folder = Folders{k};
  disp('Removing NaN regions for timeseries data in: ');
  disp(Folder);

  FileList = dir(fullfile(Folder, 'sub*.csv'));
  for iFile = 1:numel(FileList)
      [~, name, ext] = fileparts(FileList(iFile).name);
      data = readtable(fullfile(Folder, [name, ext]));
      data = table2array(data);
      data = data';
      data(NanRegionIdxComplete, :) = [];
      save(fullfile(Folder, [name, '.mat']), 'data');
  end
end
disp(' ');


%Convert LEiDA behavioural data from .csv to .mat for use in LEiDA_compare
%scores script. 

%read in .csv file
T=readtable('/Volumes/hwhalley-adol-imaging/irritability_project/data/LEiDA_behavioural_data.csv')
   










