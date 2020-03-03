clf;
% clear;
% close all
filepath = 'C:\Users\lanan\Documents\MATLAB\functions\Scripts Marcos';
addpath(genpath(filepath))

%% Input params

display_fig = 'on';   % 'on' or 'off'
savefig = 0;           % binario 1 = guardar, 0 = no guardar
testType = 'signrank'; % type of wilcoxon or statistical test
windowSize = 10;       % non-overlapping window size for test % 32 = 250 ms, 63 = 500 ms,  96 = 750
start_point = 1;     % start sample for testing (usually after baseline), 1537 (500 ms), 126 = 0 189 (500 ms)
error = 'Sem';         % define error
x1 = 0; % events line plots in seconds

%% comparison %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Specify scouts or brain regions to plot, from the scouts vector.

%v_nscouts = [1 2 3 5 6 9 11 14 15 17 20 21 22 23 24 29 33 34 40 41 42];
v_nscouts = [9 34];
%v_nscouts = [22 23 33 29 41 42];
%v_nscouts = 23:1:30;

for s_scout = 1:numel(v_nscouts)
    for s_scout2 = s_scout:numel(v_nscouts)%s_scout:numel(v_nscouts)
        if (s_scout2 ~= s_scout)
            % para correr esto es necesario definir que t es distinto de 1 y los rois
            Meassure = '(coherence)';   % en minusculas          
            % HACER ARREGLO CON ROIS, LLAMAR FILA PARA PEGARLA EN MATRIZ ABAJO Y
            % ELEGIR CANALES
            scout = v_nscouts(s_scout);
            scout2 = v_nscouts(s_scout2);
            ROI1 = scouts(scout); ROI2 = scouts(scout2);
            %ROI1 = strrep(ROI1,'_','\_'); ROI2 = strrep(ROI2,'_','\_');
            
            Title_roi = strcat(ROI1,{' vs '},ROI2);
            
            condition1 = 'Odor'; condition2 = 'Placebo';
            
            %% Load data 
            % grupo = [condition1 ' and ' condition2 ' - Mean ' freq ' Z-score - SEM - ROI ' roi ];
            grupo = Title_roi;
            
            if scout<scout2
                c1 = squeeze(permute(SpindlePowerCohOdor(:,scout,scout2,:),[2,3,1,4])); % Vector de Condicion 1
                c2 = squeeze(permute(SpindlePowerCohPlac(:,scout,scout2,:),[2,3,1,4])); %Vector de Condicion 2
            else
                c1 = squeeze(permute(SpindlePowerCohOdor(:,scout2,scout,:),[2,3,1,4])); % Vector de Condicion 1
                c2 = squeeze(permute(SpindlePowerCohPlac(:,scout2,scout,:),[2,3,1,4])); %Vector de Condicion 2
            end
            
            yaxis = [10 60];%[min(min([c1;c2]))-5 max(max([c1;c2]))+5];        % define yaxis limits

            %% run stats (Wilcoxon ranksum or signed test) and save
            
            [stats] = test_wilcoxon_cvar(c1, c2, condition1, condition2, testType, windowSize, start_point);
            
            %% Plot configuration
            
            Xt = v_TimeAxisCoh;%EjeX; % Time o EjeX
            
            figure1 = grupo;
            figure%('visible',display_fig,'position', [0, 0, 1000, 500]); hold on;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            p1 = shadedErrorBar(Xt,c1,{@mean,@std},'lineprops', '-b');hold on;
            p2 = shadedErrorBar(Xt,c2,{@mean,@std},'lineprops', '-k');hold on;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xlabel('Time (s)','FontSize',12,'FontWeight','bold')
            ylabel(['11 - 15.5Hz ' Meassure],'FontSize',12,'FontWeight','bold')
            %%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
            ylim([yaxis(1) yaxis(2)])
            xlim ([s_baselineStartTime max(Xt)])
            %legend('Odor','Placebo')
            
            
            title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
            h = title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
            P = get(h,'Position');
            %set(h,'Position',[P(1) P(2)+0.1 P(3)])
            
            ax = gca; % current axes
            ax.XTickMode = 'manual';
            ax.TickDirMode = 'manual';
            ax.TickDir = 'in';
            ax.XColor = 'black';
            ax.YColor = 'black';
            set(gca,'LineWidth',2,'Fontsize',12,'FontWeight','bold','clipping', 'on')
            
                       
            %% Sombreado
            pmask = stats.p_masked;
            winlim = stats.movwind;
            
            for pv=1:length(pmask)
                
                if pmask(pv) == 1
                    p = patch('Faces', [1 2 3 4], 'Vertices', [Xt(winlim(pv)) yaxis(1); Xt(winlim(pv)) yaxis(2);...
                        Xt(winlim(pv+1)) yaxis(2); Xt(winlim(pv+1)) yaxis(1)]);
                    set(p,'facealpha',.2,'linestyle','none');
                end
                
            end
            
            p3 = plot([x1(1) x1(1)],[yaxis(1)+0.05 yaxis(2)-0.05],'color','k','LineWidth',2,'LineStyle','-');
            hold on;
            box on;
       
        end
    end
end

