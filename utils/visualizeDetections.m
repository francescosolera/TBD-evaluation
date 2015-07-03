function visualizeDetections(baseFolder, datasetName, filename)

close all;

%% LOAD DATA
data = dlmread(fullfile(baseFolder, datasetName, filename));
frames = min((data(:, 1))) : max((data(:, 1)));
n_frames = length(frames);

%% VISUALIZE
figure(1);
for f = 1 : n_frames
    data_frame = data(data(:, 1) == frames(f), 1:6);
    
    % plot image
    hold off;
    imshow(imread(sprintf('%s/%s/img/%06d.jpg', baseFolder, datasetName, f)));
    hold on;
    
    for i = 1 : size(data_frame, 1)
        rectangle('Position', data_frame(i, [3 4 5 6]), 'edgecolor', [0 0 0] / 255, 'linewidth', 2);
    end
    pause(0.1);
end


end

