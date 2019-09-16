
%% Plot PSD of all scouts

for scout = 1:numel(scouts)-1
    
    Data_PSD_OdorOn = log10(squeeze(permute(PSD_OdorOn(2:end,scout,:),[2,1,3])));
    Data_PSD_OdorOff = log10(squeeze(permute(PSD_OdorOff(2:end,scout,:),[2,1,3])));
    
    Data_PSD_PlacOn = log10(squeeze(permute(PSD_PlacOn(2:end,scout,:),[2,1,3])));
    Data_PSD_PlacOff = log10(squeeze(permute(PSD_PlacOff(2:end,scout,:),[2,1,3])));
    
    ROI = scouts(scout);
    figure
    %subplot(2,1,1);
    shadedErrorBar(v_FreqAxis,Data_PSD_OdorOn,{@mean,@std},'lineprops', '-b');hold on;
    shadedErrorBar(v_FreqAxis,Data_PSD_OdorOff,{@mean,@std},'lineprops', '-k');hold on;
    title(strcat('pow spectrum area 1 Odor',ROI))
    legend('odor ON', 'odor OFF');
    
    %subplot(2,1,2);
    shadedErrorBar(v_FreqAxis,Data_PSD_PlacOn,{@mean,@std},'lineprops', '-r');hold on;
    shadedErrorBar(v_FreqAxis,Data_PSD_PlacOff,{@mean,@std},'lineprops', '-g');
    title(strcat('pow spectrum area 1 Placebo',ROI))
    legend('Odor On', 'Odor Off','Placebo ON', 'Placebo OFF');
    
end
%% Plot connectivity PSD of all scouts

for s_scout = 1:5%numel(scouts)
    for s_scout2 = s_scout:numel(scouts)%s_scout:numel(scouts)
        Data_connect_OdorOn = ...
            squeeze(squeeze(permute(CodorOn(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_OdorOff = ...
            squeeze(squeeze(permute(CodorOff(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        
        Data_connect_PlacOn = ...
            squeeze(squeeze(permute(CPlacOn(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_PlacOff = ...
            squeeze(squeeze(permute(CPlacOff(:,s_scout,s_scout2,:),[2,3,1,4])));  
        
        
        ROI1 = scouts(s_scout);
        ROI2 = scouts(s_scout2);
        
        figure
        subplot(2,1,1);
        shadedErrorBar(v_FreqAxis,Data_connect_OdorOn,{@mean,@std},'lineprops', '-b');hold on;
        shadedErrorBar(v_FreqAxis,Data_connect_PlacOn,{@mean,@std},'lineprops', '-k');
        title(strcat('pow spectrum area 1 On',ROI1,ROI2))
        legend('odor', 'placebo');
        
        subplot(2,1,2);
        shadedErrorBar(v_FreqAxis,Data_connect_OdorOff,{@mean,@std},'lineprops', '-b');hold on;
        shadedErrorBar(v_FreqAxis,Data_connect_PlacOff,{@mean,@std},'lineprops', '-k');
        title(strcat('pow spectrum area 1 Off',ROI1,ROI2))
        legend('odor', 'placebo');
    end
end