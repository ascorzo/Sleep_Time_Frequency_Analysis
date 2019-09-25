
filepath = 'C:\Users\lanan\Documents\MATLAB\functions\Scripts Marcos';
addpath(genpath(filepath))
%% Input params

display_fig = 'on';   % 'on' or 'off'
savefig = 0;           % binario 1 = guardar, 0 = no guardar
% t = 2;                 % COMPARE FREQS (1) OR TASKS (2)
testType = 'signrank'; % type of wilcoxon or statistical test
windowSize = 10;       % non-overlapping window size for test % 32 = 250 ms, 63 = 500 ms,  96 = 750
start_point = 1;     % start sample for testing (usually after baseline), 1537 (500 ms), 126 = 0 189 (500 ms)

error = 'Sem';         % define error

x1 = 0; % events line plots in seconds
freq = 'PSD'; 

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

for s_scout = 1:5%numel(scouts)|
    for s_scout2 = s_scout+1:numel(scouts)%s_scout:numel(scouts)
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

%% Difference between on and off in PSD of all scouts

for scout = 1:numel(scouts)-1
    
    Data_PSD_OdorOn = log10(squeeze(permute(PSD_OdorOn(2:end,scout,:),[2,1,3])));
    Data_PSD_OdorOff = log10(squeeze(permute(PSD_OdorOff(2:end,scout,:),[2,1,3])));
    
    Data_PSD_OdorDiff = Data_PSD_OdorOn - Data_PSD_OdorOff;
    
    Data_PSD_PlacOn = log10(squeeze(permute(PSD_PlacOn(2:end,scout,:),[2,1,3])));
    Data_PSD_PlacOff = log10(squeeze(permute(PSD_PlacOff(2:end,scout,:),[2,1,3])));

    Data_PSD_PlacDiff = Data_PSD_PlacOn - Data_PSD_PlacOff;

    
    ROI = scouts(scout);
    figure
    %subplot(2,1,1);
    shadedErrorBar(v_FreqAxis,Data_PSD_OdorDiff,{@mean,@std},'lineprops', '-b');hold on;
    shadedErrorBar(v_FreqAxis,Data_PSD_PlacDiff,{@mean,@std},'lineprops', '-k');hold on;
    title(strcat('pow spectrum area 1 Odor',ROI))
    legend('Odor', 'Placebo');
    
end

%% Difference between on and off in connectivity PSD of all scouts

for s_scout = 1:5%numel(scouts)|
    for s_scout2 = s_scout + 1:numel(scouts)%s_scout:numel(scouts)
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
        
        ROI1 = scouts(s_scout);
        ROI2 = scouts(s_scout2);
        
        roi = strcat(ROI1,{' vs '},ROI2);
        
        condition1 = 'Odor'; condition2 = 'Placebo';
         
        [stats] = test_wilcoxon_cvar(Data_connect_OdorDiff,Data_connect_PlacDiff,...
            condition1, condition2, testType, windowSize, start_point);
        
        yaxis = [min(min([Data_connect_OdorDiff;Data_connect_PlacDiff]))-5,...
            max(max([Data_connect_OdorDiff;Data_connect_PlacDiff]))+5]; 
        
        %-------Plot configuration-------
        
        Xt = v_FreqAxis;%EjeX; % Time o EjeX
        
        figure1 = roi;
        figure('visible',display_fig,'position', [0, 0, 1400, 700]); hold on;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        shadedErrorBar(Xt,Data_connect_OdorDiff,{@mean,@std},'lineprops', '-b');hold on;
        shadedErrorBar(Xt,Data_connect_PlacDiff,{@mean,@std},'lineprops', '-k');hold on;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xlabel('Time (ms)','FontSize',12,'FontWeight','bold')
        ylabel(['11 - 15.5Hz ' freq],'FontSize',12,'FontWeight','bold')
        %%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
        %ylim([yaxis(1) yaxis(2)])
        legend('Odor','Placebo')
        
        title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
        h = title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
        P = get(h,'Position');
        set(h,'Position',[P(1) P(2)+0.1 P(3)])
        
        ax = gca; % current axes
        ax.XTickMode = 'manual';
        ax.TickDirMode = 'manual';
        ax.TickDir = 'in';
        ax.XColor = 'black';
        ax.YColor = 'black';
        set(gca,'LineWidth',2,'Fontsize',12,'FontWeight','bold','clipping', 'on')
        
        %--- Sombreado--------------
        pmask = stats.p_masked;
        winlim = stats.movwind;
        
        for pv=1:length(pmask)
            
            if pmask(pv) == 1
                p = patch('Faces', [1 2 3 4], 'Vertices', [Xt(winlim(pv)) yaxis(1); Xt(winlim(pv)) yaxis(2);...
                    Xt(winlim(pv+1)) yaxis(2); Xt(winlim(pv+1)) yaxis(1)]);
                set(p,'facealpha',.2,'linestyle','none');
            end
            
        end
        
        plot([x1(1) x1(1)],[yaxis(1)+0.05 yaxis(2)-0.05],'color','k','LineWidth',2,'LineStyle','-');
        hold on;
        set(gca,'units','pix','pos',[100 100 1130 400])
        box on;
        
%         figure
%         shadedErrorBar(v_FreqAxis,Data_connect_OdorDiff,{@mean,@std},'lineprops', '-b');hold on;
%         shadedErrorBar(v_FreqAxis,Data_connect_PlacDiff,{@mean,@std},'lineprops', '-k');
%         title(strcat('pow spectrum area 1 On',ROI1,ROI2))
%         legend('odor', 'placebo');
%         
        
    end
end






