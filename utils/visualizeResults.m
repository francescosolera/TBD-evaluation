function visualizeResults(baseFolder, datasetName, filename)

%% LOAD DATA
data = dlmread(fullfile(baseFolder, filename));
frames = min((data(:, 1))) : max((data(:, 1)));
n_frames = length(frames);

colors = 'ymcrgbwk';

%% VISUALIZE
figure(1);
for f = 1 : n_frames
    data_frame = data(data(:, 1) == frames(f), 1:6);
    
    % plot image
    hold off;
    imshow(imread(sprintf('%s/%s/img/%06d.jpg', baseFolder, datasetName, f)));
    hold on;
    
    for i = 1 : size(data_frame, 1)
        rectangle('Position', data_frame(i, [3 4 5 6]), 'edgecolor', colors(mod(data_frame(i,2), length(colors))+1));
    end
    pause;
end


end

