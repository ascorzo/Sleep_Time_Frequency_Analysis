function [CohNormTotal,DeltaPowerCoh,ThetaPowerCoh,AlphaPowerCoh,SpindlePowerCoh,BetaPowerCoh,v_TimeAxis,v_FreqAxis] = ...
    f_Connectivity(scouts,Data,file,str_Cond,s_TimeBeforeCero,...
    s_baselineStart,s_baselineEnd,ChanVsSource)

%% Connectivity Analysis

for scout = 1:numel(scouts)
    if strcmp(ChanVsSource,'Channel')
        s_ROI1 = find(strcmp(file.Channel.Labels, scouts(scout)));
    else
        s_ROI1 = strcmp({file.Atlas.Scouts.Label},scouts(scout));
    end
    
    for scout2 = scout:numel(scouts)
        
        
        if strcmp(ChanVsSource,'Channel')
            s_ROI2 = find(strcmp(file.Channel.Labels, scouts(scout2)));
        else
            s_ROI2 = strcmp({file.Atlas.Scouts.Label},scouts(scout2));
        end
        
        params.tapers = [3,5];
        params.pad = -1;
        params.Fs = 1000;
        params.fpass = [0,40];
        params.trialave = 1;
        
        winsize = 2;
        winstep = 0.2;
        movingwin = [winsize,winstep];
        
        
        DataTemp1 = Data(s_ROI1,:,:);
        DataTemp2 = Data(s_ROI2,:,:);
        
        [Coh,~,~,~,~,v_TimeAxis,v_FreqAxis] = cohgramc(squeeze(DataTemp1), squeeze(DataTemp2), movingwin, params);
        v_TimeAxis = v_TimeAxis - s_TimeBeforeCero;
        % figure; pcolor(v_TimeAxis,v_FreqAxis,Coh'); shading interp; colormap jet; colorbar;%; caxis([0 0.3])
        % title(strcat(str_ROI{1},'__vs__',str_ROI{2},'__',str_Cond))
        
        Coh = Coh';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Normalization
        
        %Coh'
        [~, idx1] = min(abs(v_TimeAxis - s_baselineStart));
        [~, idx2] = min(abs(v_TimeAxis - s_baselineEnd));
        
        Mean_Coh= repmat(mean(Coh(:,idx1:idx2),2),[1, size(Coh,2)]);
        CohNorm = Coh./Mean_Coh;
        
        
        %             figure; pcolor(v_TimeAxis,v_FreqAxis,CohNorm); shading interp; colormap jet; colorbar;%; caxis([0 0.3])
        %             xlim([v_TimeAxis(idx1) v_TimeAxis(end)])
        %             vline(0,'w')
        %             title(strcat(scout,'__vs__',scout2,'__',str_Cond))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%
        
        [DeltaPowerCoh(scout,scout2,:),...
            ThetaPowerCoh(scout,scout2,:),...
            AlphaPowerCoh(scout,scout2,:),...
            SpindlePowerCoh(scout,scout2,:),...
            BetaPowerCoh(scout,scout2,:)] = ...
            f_FreqCalc(CohNorm,v_FreqAxis);
        
        
        %             % delta plot
        %             subplot(5,1,1)
        %             plot(v_TimeAxis,DeltaPowerCoh)
        %             xlim([s_baselineStart,10])
        %             vline(0, 'r')
        %
        %             % Theta plot
        %             subplot(5,1,2)
        %             plot(v_TimeAxis,ThetaPowerCoh)
        %             xlim([s_baselineStart,10])
        %             vline(0, 'r')
        %
        %             % Alpha plot
        %             subplot(5,1,3)
        %             plot(v_TimeAxis,AlphaPowerCoh)
        %             xlim([s_baselineStart,10])
        %             vline(0, 'r')
        %
        %             % Spindles plot
        %             subplot(5,1,4)
        %             plot(v_TimeAxis,SpindlePowerCoh)
        %             xlim([s_baselineStart,10])
        %             vline(0, 'r')
        %
        %             % Beta plot
        %             subplot(5,1,5)
        %             plot(v_TimeAxis, BetaPowerCoh)
        %             xlim([s_baselineStart,10])
        %             %ylim([0,1 ]);
        %             vline(0, 'r')
        %             suptitle(strcat(scout,'__vs__',scout2,'__',str_Cond))
        
        
        
        CohNormTotal(scout,scout2,:,:) =  CohNorm;
        CohNormTotal(scout2,scout,:,:) =  CohNorm;
    end
    
    %CohNormTotal(s_I1,s_I1,:,:) = nan;
end
