
filepath = 'C:\Users\lanan\Documents\MATLAB\functions\Scripts Marcos';
addpath(genpath(filepath))
%% Input params

%% Plot PSD of all scouts

for scout = 1:numel(scouts)-1
    
    Data_PSD_OdorOn = log10(squeeze(permute(PSD_OdorOn(2:end,scout,:),[2,1,3])));
    Data_PSD_OdorOff = log10(squeeze(permute(PSD_OdorOff(2:end,scout,:),[2,1,3])));
    
    Data_PSD_PlacOn = log10(squeeze(permute(PSD_PlacOn(2:end,scout,:),[2,1,3])));
    Data_PSD_PlacOff = log10(squeeze(permute(PSD_PlacOff(2:end,scout,:),[2,1,3])));
    
    ROIp = scouts(scout);
    ROI = strrep(ROIp,'_','\_');
    
%     fig = figure;
%     
%     shadedErrorBar(v_FreqAxis,Data_PSD_OdorOn,{@mean,@std},'lineprops', '-b');hold on;
%     shadedErrorBar(v_FreqAxis,Data_PSD_OdorOff,{@mean,@std},'lineprops', '-k');hold on;
%     
%     shadedErrorBar(v_FreqAxis,Data_PSD_PlacOn,{@mean,@std},'lineprops', '-r');hold on;
%     shadedErrorBar(v_FreqAxis,Data_PSD_PlacOff,{@mean,@std},'lineprops', '-g');
%     title(['pow spectrum',ROI])
%     legend('Odor On', 'Odor Off','Placebo ON', 'Placebo OFF');
%     xlabel('Freq (Hz)')
%     ylabel('PSD')
%     saveas(fig,char(strcat(ROIp,'.png')));
    
    f_WilcTest(ROIp,'Freq','PSD','OdorOn','PlaceboOn',Data_PSD_OdorOn,Data_PSD_PlacOn,v_FreqAxis)
    f_WilcTest(ROIp,'Freq','PSD','OdorOn','OdorOff',Data_PSD_OdorOn,Data_PSD_OdorOff,v_FreqAxis)
    f_WilcTest(ROIp,'Freq','PSD','PlaceboOn','PlaceboOff',Data_PSD_PlacOn,Data_PSD_PlacOff,v_FreqAxis)
    f_WilcTest(ROIp,'Freq','PSD','OdorOff','PlaceboOff',Data_PSD_OdorOff,Data_PSD_PlacOff,v_FreqAxis)

end
% close all
%% Difference between on and off in PSD of all scouts

for scout = 1:numel(scouts)-1
    
    Data_PSD_OdorOn = log10(squeeze(permute(PSD_OdorOn(2:end,scout,:),[2,1,3])));
    Data_PSD_OdorOff = log10(squeeze(permute(PSD_OdorOff(2:end,scout,:),[2,1,3])));
    
    Data_PSD_OdorDiff = Data_PSD_OdorOn - Data_PSD_OdorOff;
    
    Data_PSD_PlacOn = log10(squeeze(permute(PSD_PlacOn(2:end,scout,:),[2,1,3])));
    Data_PSD_PlacOff = log10(squeeze(permute(PSD_PlacOff(2:end,scout,:),[2,1,3])));

    Data_PSD_PlacDiff = Data_PSD_PlacOn - Data_PSD_PlacOff;

    
    ROIp = scouts(scout);
    ROI = strrep(ROIp,'_','\_');
    fig = figure;
    %subplot(2,1,1);
    shadedErrorBar(v_FreqAxis,Data_PSD_OdorDiff,{@mean,@std},'lineprops', '-b');hold on;
    shadedErrorBar(v_FreqAxis,Data_PSD_PlacDiff,{@mean,@std},'lineprops', '-k');hold on;
    title(['Diff pow spectrum ',ROI])
    legend('Odor', 'Placebo');
    xlabel('Freq (Hz)')
    ylabel('PSD')
    saveas(fig,char(strcat(ROIp,'_Diff.png')));
    
    f_WilcTest(ROIp,'Freq','PSD','OdorDiff','PlaceboDiff',Data_PSD_OdorDiff,Data_PSD_PlacDiff,v_FreqAxis) 
end
close all
%% Plot connectivity PSD of all scouts

for s_scout = 12%1:numel(scouts)
    for s_scout2 = 1:numel(scouts)%s_scout+1:numel(scouts)%s_scout:numel(scouts)
        Data_connect_OdorOn = ...
            squeeze(squeeze(permute(CodorOn(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_OdorOff = ...
            squeeze(squeeze(permute(CodorOff(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        
        Data_connect_PlacOn = ...
            squeeze(squeeze(permute(CPlacOn(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_PlacOff = ...
            squeeze(squeeze(permute(CPlacOff(:,s_scout,s_scout2,:),[2,3,1,4])));  
        
        
        ROI1p = scouts(s_scout);
        ROI2p = scouts(s_scout2);
        ROI1 = strrep(ROI1p,'_','\_'); ROI2 = strrep(ROI2p,'_','\_');
        
        fig = figure;
        %subplot(2,1,1);
        shadedErrorBar(v_FreqAxis,Data_connect_OdorOn,{@mean,@std},'lineprops', '-b');hold on;
        shadedErrorBar(v_FreqAxis,Data_connect_PlacOn,{@mean,@std},'lineprops', '-k');hold on;
        %title(['pow of Coherence',ROI1,ROI2])
        %legend('odor', 'placebo');
        
        %subplot(2,1,2);
        shadedErrorBar(v_FreqAxis,Data_connect_OdorOff,{@mean,@std},'lineprops', '-r');hold on;
        shadedErrorBar(v_FreqAxis,Data_connect_PlacOff,{@mean,@std},'lineprops', '-g');
        title(['pow of Coherence',strcat(ROI1,'vs',ROI2)])
        legend('Odor On', 'Odor Off','Placebo On', 'Placebo Off');
        
        %saveas(fig,char(strcat(ROI1p,'vs',ROI2p','.png')));
        f_WilcTest(strcat(ROI1p,'vs',ROI2p),'Freq','PSD','OdorOn','PlaceboOn',Data_connect_OdorOn,Data_connect_PlacOn,v_FreqAxis)
        f_WilcTest(strcat(ROI1p,'vs',ROI2p),'Freq','PSD','OdorOn','OdorOff',Data_connect_OdorOn,Data_connect_OdorOff,v_FreqAxis)
        f_WilcTest(strcat(ROI1p,'vs',ROI2p),'Freq','PSD','PlaceboOn','PlaceboOff',Data_connect_PlacOn,Data_connect_PlacOff,v_FreqAxis)
        f_WilcTest(strcat(ROI1p,'vs',ROI2p),'Freq','PSD','OdorOff','PlaceboOff',Data_connect_OdorOff,Data_connect_PlacOff,v_FreqAxis)        
    end
    %close all
end



%% Difference between on and off in connectivity PSD of all scouts

for s_scout = 4%1:numel(scouts)
    for s_scout2 = 39%s_scout + 1:numel(scouts)%s_scout:numel(scouts)
        Data_connect_OdorOn = ...
            squeeze(squeeze(permute(CodorOn(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_OdorOff = ...
            squeeze(squeeze(permute(CodorOff(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_OdorDiff = Data_connect_OdorOn - Data_connect_OdorOff;
        
        Data_connect_PlacOn = ...
            squeeze(squeeze(permute(CPlacOn(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_PlacOff = ...
            squeeze(squeeze(permute(CPlacOff(:,s_scout,s_scout2,:),[2,3,1,4])));
        
        Data_connect_PlacDiff = Data_connect_PlacOn - Data_connect_PlacOff;
        
        ROI1p = scouts(s_scout);
        ROI2p = scouts(s_scout2);
        ROI1 = strrep(ROI1p,'_','\_'); ROI2 = strrep(ROI2p,'_','\_');
        
        fig = figure;
        shadedErrorBar(v_FreqAxis,Data_connect_OdorDiff,{@mean,@std},'lineprops', '-b');hold on;
        shadedErrorBar(v_FreqAxis,Data_connect_PlacDiff,{@mean,@std},'lineprops', '-k');hold on;
        title(['Diff in pow for Coherence',strcat(ROI1,'vs',ROI2)])
        legend('Odor','Placebo');
        
        
        %saveas(fig,char(strcat(ROI1p,'vs',ROI2p','Diff.png')));   
        f_WilcTest(strcat(ROI1p,'vs',ROI2p),'Freq','PSD','OdorOff','PlaceboOff',Data_connect_OdorDiff,Data_connect_PlacDiff,v_FreqAxis)

        %close all
    end
    
end






