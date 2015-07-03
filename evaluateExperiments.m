%% INITIALIZE
clear; clc;

%% ATTENTION:
% BEFORE RUNNING THIS SCRIPT REMEMBER TO CHANGE THE evaluator > seqmaps > seq_to_test.txt
% FILE WITH THE NAME OF THE SEQUENCE YOU WANT TO TEST!
addpath(genpath('evaluator'));

%% PARAMETERS
baseFolder      = 'D:\lab\TBD-evaluation';
trackerName     = 'NN';
seqName         = 'AVG-TownCentre';
resultsFolder   = 'det_results';

%% MAIN EVALUATION LOOP
dataFolder = fullfile(baseFolder, 'trackers', trackerName, seqName, resultsFolder);
tempResFolder = fullfile(baseFolder, 'temp');
fileList = dir(fullfile(dataFolder, '*.txt'));

for i = 1 : length(fileList)
    copyfile(fullfile(dataFolder, fileList(i).name), fullfile(tempResFolder, sprintf('%s.txt', seqName)));
    out{i}.filename = fileList(i).name;
    out{i}.results = evaluateTracking('seq_to_test.txt',tempResFolder,sprintf('%s/', baseFolder));
end

%% SAVE RESULTS
save(fullfile(dataFolder, 'results.mat'), 'out');