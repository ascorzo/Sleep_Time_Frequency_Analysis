clf;
% clear;
% close all
filepath = 'C:\Users\lanan\Documents\MATLAB\functions\Scripts Marcos';
addpath(genpath(filepath))
%cd(filepath)
%addpath('C:\Users\lanan\Documents\MATLAB\fieldtrip-20131231');

% disp('                       ')
%% Input params

display_fig = 'on';   % 'on' or 'off'
savefig = 0;           % binario 1 = guardar, 0 = no guardar
% t = 2;                 % COMPARE FREQS (1) OR TASKS (2)
testType = 'signrank'; % type of wilcoxon or statistical test
windowSize = 10;       % non-overlapping window size for test % 32 = 250 ms, 63 = 500 ms,  96 = 750
start_point = 1;     % start sample for testing (usually after baseline), 1537 (500 ms), 126 = 0 189 (500 ms)

error = 'Sem';         % define error

x1 = 0; % events line plots in seconds
% srate = 256;           % sampling rate of data (for resampling, PENDING)
% new_rate = 100;      % for resampling (PENDING)


%% para comparar tareas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v_nscouts = [1 2 3 5 6 9 11 14 15 17 20 21 22 23 24 29 33 34 40 41 42];
%v_nscouts = 23:1:30;
for s_scout = 1:numel(v_nscouts)
    for s_scout2 = s_scout:numel(v_nscouts)
        if (s_scout2 ~= s_scout) %&& (scout<= ceil(numel(scouts)/2))
            % para correr esto es necesario definir que t es distinto de 1 y los rois
            freq = '(coherence)';   % en minusculas           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % HACER ARREGLO CON ROIS, LLAMAR FILA PARA PEGARLA EN MATRIZ ABAJO Y
            % ELEGIR CANALES
            scout = v_nscouts(s_scout);
            scout2 = v_nscouts(s_scout2);
            ROI1 = scouts(scout); ROI2 = scouts(scout2);
            %ROI1 = strrep(ROI1,'_','\_'); ROI2 = strrep(ROI2,'_','\_');
            
            
            roi = strcat(ROI1,{' vs '},ROI2);
            
            condition1 = 'Odor'; condition2 = 'Placebo';
            
            
            %% Load data and average over channels
            % grupo = [condition1 ' and ' condition2 ' - Mean ' freq ' Z-score - SEM - ROI ' roi ];
            grupo = roi;
            
            c1 = squeeze(permute(SpindlePowerCohOdor(:,scout,scout2,:),[2,3,1,4])); % Vector de Condicion 1
            c2 = squeeze(permute(SpindlePowerCohPlac(:,scout,scout2,:),[2,3,1,4])); %Vector de Condicion 2
            
            yaxis = [min(min([c1;c2]))-5 max(max([c1;c2]))+5];        % define yaxis limits

            %% run stats (Wilcoxon ranksum or signed test) and save
            
            % datos david a 256 Hz y total 1025 samples (769 para testear)
            % una ventana de 50 ms son 26 samples
            
            [stats] = test_wilcoxon_cvar(c1, c2, condition1, condition2, testType, windowSize, start_point);
            
            %% Plot configuration
            
            Xt = v_TimeAxisCoh;%EjeX; % Time o EjeX
            
            figure1 = grupo;
            figure('visible',display_fig,'position', [0, 0, 1400, 700]); hold on;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %shadedErrorBar(Xt, mean(c1,1), SEM_calc(c1,error),'b',1); hold on;           % control blue
            %shadedErrorBar(Xt, mean(c2,1), SEM_calc(c2,error),'g',1); hold on;            % cm green
            shadedErrorBar(Xt,c1,{@mean,@std},'lineprops', '-b');hold on;
            shadedErrorBar(Xt,c2,{@mean,@std},'lineprops', '-k');hold on;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xlabel('Time (ms)','FontSize',12,'FontWeight','bold')
            ylabel(['11 - 15.5Hz ' freq],'FontSize',12,'FontWeight','bold')
            %%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
            ylim([yaxis(1) yaxis(2)])
            xlim ([s_baselineStartTime max(Xt)])
            legend('Odor','Placebo')
            
            title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
            h = title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
            P = get(h,'Position');
            set(h,'Position',[P(1) P(2)+0.1 P(3)])
            
            ax = gca; % current axes
            ax.XTickMode = 'manual';
            % ax.XTickLabelMode = 'manual';
            ax.TickDirMode = 'manual';
            ax.TickDir = 'in';
            % ax.XTickLabel = {'-1', '0', '1', '2','3','4'};
            % ax.XTick = [1 1025 2049 3073 4097 5120];
            ax.XColor = 'black';
            ax.YColor = 'black';
            set(gca,'LineWidth',2,'Fontsize',12,'FontWeight','bold','clipping', 'on')
            
            % legend lines, stats lines, mask, events lines
            %L(1) = plot(nan, nan, 'r-','linewidth',1);
            %L(2) = plot(nan, nan, 'k-','linewidth',1);
            %legend(L, {condition1, condition2}); hold on;
            %legend('boxoff')
            
            % g = alphamask(~mask,[0 0 0],0.2); % oscuro es cercano a 1
            % set(g,'YData',[10 0]);
            % set(g);
            
            % plot(Xt(start_point:end),...
            %     double(stats.mask(start_point:end))-2,...
            %     'color','r','LineWidth',3,'LineStyle','-');
            
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
            
            plot([x1(1) x1(1)],[yaxis(1)+0.05 yaxis(2)-0.05],'color','k','LineWidth',2,'LineStyle','-');
            %plot([x1(1) x1(1)],'color','k','LineWidth',2,'LineStyle','-');
            % plot([x1(2) x1(2)],[yaxis(1)+0.05 yaxis(2)-0.05],'color','k','LineWidth',2,'LineStyle',':');
            % plot([x1(3) x1(3)],[yaxis(1)+0.05 yaxis(2)-0.05],'color','k','LineWidth',2,'LineStyle',':');
            hold on;
            set(gca,'units','pix','pos',[100 100 1130 400])
            box on;
            
        end
    end
end


% save to png and tiff 200 dpi transparente sin antializing
% if savefig == 1;
%     export_fig(figure1,'-png','-transparent','-a1','-r200',gca)
%     disp('FIGURE SAVED')
% else
%     disp('FIGURE NOT SAVED - To save figure, change savefig to 1.')
% end

% disp('                           ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save values as a table

% summary = table();
% summary.winstart = Xt(winlim(1:end-1))';
% summary.windend = Xt(winlim(2:end))';
% summary.pvalue = stats.pval';
% summary.pthresh = pmask;
% summary.zval = [stats.statval.zval]';

