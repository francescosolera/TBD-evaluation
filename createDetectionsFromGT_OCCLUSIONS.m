%% INITIALIZE
clc; clear;

%% PARAMETERS
baseFolder = 'D:\lab\TBD-evaluation';
datasetName = 'AVG-TownCentre';

N_range = 0 : 0.2 : 1;
L_range = 0 : 0.2 : 1;

% number of run to account for randomness
d = 5;

%% LOAD DATA
addpath(genpath('utils'));
data = dlmread(fullfile(baseFolder, datasetName, '\gt\gt.txt'));
frames = unique(data(:, 1));
n_frames = length(frames);
IDs = unique(data(:,2));
n_people = length(IDs);

%% MAIN LOOP - ONE FOR EACH FILE
for n = N_range
    for l = L_range
        for run = 1 : d
            
            % number and IDs of occluded targets
            num_occ = floor(n_people * n);
            occ_index = randperm(n_people, num_occ);
            occ_id = IDs(occ_index);
            
            % set BB size to zero when occluded
            final_data = data;
            for i = 1 : length(occ_id)               
                % retrieve data for track and occlude it
                T_occ = data(data(:,2) == occ_id(i), [1 3 4 5 6]);
                T_new = occlude_traj(T_occ, l);
                
                % update track with occlusion info
                final_data(data(:,2) == occ_id(i), [1 3 4 5 6]) = T_new;
            end
            
            % delete occluded pieces of trajectories
            final_data(final_data(:, 5) == 0, :) = [];
            
            % write text file
            dlmwrite(fullfile(datasetName, 'occlusions_data', sprintf('%s_N%.2f_L%.2f_%02d.txt', datasetName, n, l, run)), final_data, 'delimiter', ' ');
            
        end
    end
end
