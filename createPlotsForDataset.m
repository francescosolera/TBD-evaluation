%% INITIALIZE
clear; close all;
colors = 'mcyrgb';
warning('off', 'MATLAB:legend:IgnoringExtraEntries');

%% PARAMETERS
baseFolder = 'D:\lab\TBD-evaluation';

% trackers to compare
trackerName = {'NN', 'TC_ODAL'};
titleName   = {'trk1', 'trk2'};

% sequences to study
sequences   = {'PETS09-S2L2', 'TUD-Stadtmitte', 'AVG-TownCentre'};

% precision/recall vs occlusion number and length
res_tp  = {{'robustness', 0.5:0.1:1, 'Precision', 'Recall', 'northeast'}, ...
    {'occlusions', 0:0.2:1, 'Number', 'Length', 'northeast'}};

%% START PLOTTING
for t = 1 : length(trackerName)
    for r = 1 : length(res_tp)
        
        % create data structures
        range       = res_tp{r}{2};     lr = length(range);
        
        % each cell contains results from d runs
        mota_matrix_num = cell(lr);     mota_matrix_den = cell(lr);
        tl_matrix   = cell(lr);
        
        % results averaged over the d runs
        mota_avg    = zeros(lr);    tl_avg      = cell(lr);
        mota_var    = zeros(lr);    tl_var      = cell(lr);
        
        for s = 1 : length(sequences)
            seqName = sequences{s};
            
            dataFolder  = fullfile(baseFolder, 'trackers', ...
                trackerName{t}, seqName, sprintf('%s_results', res_tp{r}{1}));
            
            % count annotated objects
            loadfileforGTcounting = dlmread(fullfile(baseFolder, seqName, 'gt\gt.txt'));
            this_GT_points = size(loadfileforGTcounting, 1);
            
            % load results
            results     = load(fullfile(dataFolder, 'results.mat'));
            
            % fill the cell matrices
            tl_matrix   = cell(lr);
            for i = 1 : length(results.out)
                % get parameter values by string parsing and matrix indexes
                parsed  = strsplit(results.out{i}.filename, '_');
                r_idx   = find(range == str2double(parsed{2}(2:end)));
                c_idx   = find(range == str2double(parsed{3}(2:end)));
                
                %get MT value and add in cell array in percentage over GT total
                mota_matrix_num{r_idx,c_idx}    = [mota_matrix_num{r_idx,c_idx} ...
                    max(0, sum(results.out{i}.results.mets2d.m(8:10)))];
                mota_matrix_den{r_idx,c_idx}    = [mota_matrix_den{r_idx,c_idx} ...
                    this_GT_points];
                
                tl_matrix{r_idx,c_idx}          = [tl_matrix{r_idx,c_idx}; ...
                    sort(results.out{i}.results.mets2d.TLP, 'descend')];
            end
            
            for i = 1 : lr
                for j = 1 : lr
                    tl_avg{i,j}     = [tl_avg{i,j} mean(tl_matrix{i,j})];
                end
            end
            
        end
        
        % compute average values over the d runs
        for i = 1 : lr
            for j = 1 : lr
                mota_avg(i,j)   = max([0 1 - sum(mota_matrix_num{i,j}) / sum(mota_matrix_den{i,j})])*100;
                tl_avg{i,j}     = sort(tl_avg{i,j}, 'descend');
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
        subplot(length(res_tp), 3, 3*(r-1)+1);
        imagesc(mota_avg_to_plot, [0 100]); colorbar;
        title(sprintf('%s MOTA (%s)', titleName{t}, res_tp{r}{1}));
        ylabel(res_tp{r}{3});   xlabel(res_tp{r}{4});
        ax = gca;
        set(ax, 'XTickLabel', res_tp{r}{2});
        set(ax, 'YTickLabel', fliplr(res_tp{r}{2}));
        
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
        grid on;
        legend(this_legend, 'Location', res_tp{r}{5});
        xlabel('Number of GT tracks');      ylabel('Tracked length (%)');
        title(sprintf('%s TL curves %s inv %s (%s)', titleName{t}, res_tp{r}{3}(1), res_tp{r}{4}(1), res_tp{r}{1}));
        
    end
end