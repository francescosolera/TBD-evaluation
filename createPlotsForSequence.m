%% INITIALIZE
clear; close all;
colors = 'mcyrgb';
warning('off', 'MATLAB:legend:IgnoringExtraEntries');

%% PARAMETERS
baseFolder = 'D:\lab\TBD-evaluation';

% trackers to compare
trackerName = {'NN', 'TC_ODAL'};
titleName   = {'trk1', 'trk2'};

% video name
seqName = 'PETS09-S2L2';

% plot true detections
plotDetection = 1;

% precision/recall vs occlusion number and length
res_tp  = {{'robustness', 0.5:0.1:1, 'Precision', 'Recall', 'northeast'}, ...
    {'occlusions', 0:0.2:1, 'Number', 'Length', 'northeast'}};

%% COMPUTE DETECTION PERFORMANCES
if plotDetection
    detFile = fullfile(baseFolder, seqName, 'det', 'det.txt');
    gtFile  = fullfile(baseFolder, seqName, 'gt', 'gt.txt');
    [detP, detR] = computeDetectorPerformances(detFile, gtFile);
end

%% START PLOTTING
for t = 1 : length(trackerName)
    for r = 1 : length(res_tp)
        dataFolder  = fullfile(baseFolder, 'trackers', ...
            trackerName{t}, seqName, sprintf('%s_results', res_tp{r}{1}));
        
        % load results
        results     = load(fullfile(dataFolder, 'results.mat'));
        range       = res_tp{r}{2};     lr = length(range);
        
        % create data structures
        % each cell contains results from d runs
        mota_matrix = cell(lr);     tl_matrix   = cell(lr);
        
        % results averaged over the d runs
        mota_avg    = zeros(lr);    tl_avg      = cell(lr);
        mota_var    = zeros(lr);    tl_var      = cell(lr);
        
        % fill the cell matrices
        for i = 1 : length(results.out)
            % get parameter values by string parsing and matrix indexes
            parsed  = strsplit(results.out{i}.filename, '_');
            r_idx   = find(range == str2double(parsed{2}(2:end)));
            c_idx   = find(range == str2double(parsed{3}(2:end)));
            
            %get MT value and add in cell array in percentage over GT total
            mota_matrix{r_idx,c_idx}    = [mota_matrix{r_idx,c_idx} ...
                max(0, results.out{i}.results.mets2d.m(12))];
            tl_matrix{r_idx,c_idx}      = [tl_matrix{r_idx,c_idx}; ...
                sort(results.out{i}.results.mets2d.TLP, 'descend')];
        end
        
        % compute average values over the d runs
        for i = 1 : lr
            for j = 1 : lr
                mota_avg(i,j)   = mean(mota_matrix{i,j});
                mota_var(i,j)   = sqrt(var(mota_matrix{i,j}));
                
                tl_avg{i,j}     = mean(tl_matrix{i,j});
                tl_var{i,j}     = var(tl_matrix{i,j});
            end
        end
        
        % compute normalized AUC TL curves
        AUC_mdiag = zeros(1, length(tl_avg));   % principal diagonal
        AUC_idiag = zeros(1, length(tl_avg));   % inverse diagonal
        for i = 1 : length(tl_avg)
            AUC_mdiag(i) = trapz(tl_avg{i,i}) / length(tl_avg{i,i});
            AUC_idiag(i) = trapz(tl_avg{i, length(tl_avg)-i+1}) / length(tl_avg{i,i});
        end
        
        %% PLOT
        % plot tracker results in subplots
        figure(t);
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        
        % plot MOTA matrix
        mota_avg_to_plot = flipud(mota_avg);
        mota_var_to_plot = flipud(mota_var);
        subplot(length(res_tp), 3, 3*(r-1)+1);
        imagesc(mota_avg_to_plot, [0 100]); colorbar;
        for i = 1 : lr, for j = 1 : lr, text(i-0.4,j+0.3,sprintf('%2.2f', mota_var_to_plot(i,j)), 'color', [0.5 0.5 0.5]); end; end
        title(sprintf('%s MOTA (%s)', titleName{t}, res_tp{r}{1}));
        ylabel(res_tp{r}{3});   xlabel(res_tp{r}{4});
        ax = gca;
        set(ax, 'XTickLabel', res_tp{r}{2});
        set(ax, 'YTickLabel', fliplr(res_tp{r}{2}));
        
        % add true detection MOTA
        if isequal(res_tp{r}{1}, 'robustness') && plotDetection
            h = colormap;
            rr = (detR-res_tp{r}{2}(1))*(length(res_tp{r}{2})-1)/(res_tp{r}{2}(end)-res_tp{r}{2}(1))+1;
            pp = length(res_tp{r}{2})-(detP-res_tp{r}{2}(1))*(length(res_tp{r}{2})-1)/(res_tp{r}{2}(end)-res_tp{r}{2}(1));
            
            det_res = load(fullfile(baseFolder, 'trackers', ...
                trackerName{t}, seqName, 'det_results', 'results.mat'));
            v = max(1, round((det_res.out{1}.results.mets2d.m(12) / 100) * size(h, 1)));
            
            hold on; scatter(rr, pp, 500, 'MarkerEdgeColor', [0.2 0.2 0.2], 'MarkerFaceColor', h(v, :),  'LineWidth', 3)
            hold off;
        end
        
        % PLOT COMPARATIVE RESULTS        
        figure(length(trackerName)+1);
        subplot(1, 2, r);
        plot(range, AUC_mdiag, colors(mod(t+2, length(colors))+1), 'LineWidth', 3); hold on;
        grid on;
        axis([min(res_tp{r}{2}) max(res_tp{r}{2}) 0 1]);
        xlabel(sprintf('%s = %s', res_tp{r}{3}, res_tp{r}{4}));
        ylabel('Tracked length (%)');
        legend(titleName);
        title(sprintf('Tracker comparison on %s', res_tp{r}{1}));
        
        % plot MAIN diagonal TL curves and AUC
        figure(t);
        subplot(length(res_tp), 3, 3*(r-1)+2); hold off;
        this_legend = cell(1, lr);
        for i = 1 : lr
            plot(tl_avg{i, i}, sprintf('-%s', ...
                colors(mod(i, length(colors))+1)), 'LineWidth', 1.5); hold on;
            this_legend{i} = sprintf('%s: %2.2f, %s: %2.2f', res_tp{r}{3}(1), range(i), res_tp{r}{4}(1), range(i));
        end
        % add true detection TL
        if isequal(res_tp{r}{1}, 'robustness') && plotDetection
            det_res = load(fullfile(baseFolder, 'trackers', ...
                trackerName{t}, seqName, 'det_results', 'results.mat'));
            v = sort(det_res.out{1}.results.mets2d.TLP, 'descend');
            plot(v, 'k', 'LineWidth', 1.5);
            this_legend{i+plotDetection} = sprintf('DET (%2.2f, %2.2f)', detP, detR);
            hold off;
        end
        grid on;
        legend(this_legend, 'Location', res_tp{r}{5});
        xlabel('Number of GT tracks');      ylabel('Tracked length (%)');
        title(sprintf('%s TL curves %s = %s (%s)', titleName{t}, res_tp{r}{3}(1), res_tp{r}{4}(1), res_tp{r}{1}));
        
        % plot INVERSE diagonal TL curves and AUC
        subplot(length(res_tp), 3, 3*(r-1)+3); hold off;
        this_legend = cell(1, lr);
        for i = 1 : lr
            plot(tl_avg{i, 6-i+1}, sprintf('-%s', ...
                colors(mod(i, length(colors))+1)), 'LineWidth', 1.5); hold on;
            this_legend{i} = sprintf('%s: %2.2f, %s: %2.2f', res_tp{r}{3}(1), range(i), res_tp{r}{4}(1), range(6-i+1));
        end
        if isequal(res_tp{r}{1}, 'robustness') && plotDetection
            det_res = load(fullfile(baseFolder, 'trackers', ...
                trackerName{t}, seqName, 'det_results', 'results.mat'));
            v = sort(det_res.out{1}.results.mets2d.TLP, 'descend');
            plot(v, 'k', 'LineWidth', 1.5);
            this_legend{i+plotDetection} = sprintf('DET (%2.2f, %2.2f)', detP, detR);
            hold off;
        end
        grid on;
        legend(this_legend, 'Location', res_tp{r}{5});
        xlabel('Number of GT tracks');      ylabel('Tracked length (%)');
        title(sprintf('%s TL curves %s inv %s (%s)', titleName{t}, res_tp{r}{3}(1), res_tp{r}{4}(1), res_tp{r}{1}));
        
    end
end