%% INITIALIZE
clc; clear;

%% PARAMETERS
baseFolder = 'D:\lab\TBD-evaluation';
datasetName = 'AVG-TownCentre';

P_range = 0.5 : 0.1 : 1;
R_range = 0.5 : 0.1 : 1;

% number of run to account for randomness
d = 5;

sigma_1 = 4;                  % variance for FP positions
sigma_2 = 2;                  % variance for BB sizes

%% LOAD DATA
data = dlmread(fullfile(baseFolder, datasetName, '\gt\gt.txt'));
frames = unique(data(:, 1));
n_frames = length(frames);

%% MAIN LOOP - ONE FOR EACH FILE
for p = P_range
    for r = R_range
        for run = 1 : d
            
            % compute constants
            FP = (1 - p) / p;
            FN = (1 - r);
            
            final_data = [];
            for f = 1 : n_frames
                tfd = data(data(:, 1) == frames(f), 1:6);       % this frame data
                n_people = size(tfd, 1);
                
                %% ADD FP
                fp_n = round(FP*(1-FN)*n_people);               % choose number of people
                fp_idx = randi(n_people, fp_n, 1);              % choose people to affect
                
                false_positives = zeros(fp_n, size(tfd, 2));
                for i = 1 : fp_n
                    new_dim = tfd(fp_idx(i), 5:6)./2 + rand*tfd(fp_idx(i), 5:6);
                    new_pos = tfd(fp_idx(i), 3:4) + randn(1, 2)*sigma_1^2 - (new_dim-tfd(fp_idx(i), 5:6))./2;
                    false_positives(i, :) = [frames(f) -1 new_pos new_dim];
                end
                
                %% MODIFY BB SIZE
                for i = 1 : size(tfd, 1)
                    bb_mod = randn(1, 2)*sigma_2^2;
                    tfd(i, 5:6) = tfd(i, 5:6) + bb_mod;
                    tfd(i, 3:4) = tfd(i, 3:4) - bb_mod./2;         % otherwise upper left corner is fixed
                end
                
                %% ADD FN
                fn_idx = rand(size(tfd, 1), 1) < FN;
                tfd = tfd(~fn_idx, :);
                
                % finalize results
                final_data = [final_data; tfd; false_positives];
            end
            
            % write text file
            dlmwrite(fullfile(datasetName, 'robustness_data', sprintf('%s_P%.2f_R%.2f_%02d.txt', datasetName, p, r, run)), final_data, 'delimiter', ' ');
            
        end
    end
end
