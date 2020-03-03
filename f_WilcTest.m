%% Wilcoxon test

function f_WilcTest(ROI,xMeassure,yMeassure,condition1,condition2,data1,data2,x_axis)

% ROI is going to be the name of the channel or scout to include in the
% title (string)
% Meassure is the label for the y-axes (string)
% condition1 is the label for the first condition (string)
% condition2 is the label for the second condition (string)
% data1 is the data for condition 1
% data2 is the data for condition 2
% x_axis is the vector that contains the values for the x-axis

%% Input params

display_fig = 'on';   % 'on' or 'off'
savefig = 0;           % binario 1 = guardar, 0 = no guardar
% t = 2;                 % COMPARE FREQS (1) OR TASKS (2)
testType = 'signrank'; % type of wilcoxon or statistical test
windowSize = 10;       % non-overlapping window size for test % 32 = 250 ms, 63 = 500 ms,  96 = 750
start_point = 1;     % start sample for testing (usually after baseline), 1537 (500 ms), 126 = 0 189 (500 ms)
error = 'Sem';         % define error
x1 = 0; % events line plots in seconds


%----------------------------------------------------------------------
Title_roi = ROI;

%% Load data
% grupo = [condition1 ' and ' condition2 ' - Mean ' freq ' Z-score - SEM - ROI ' roi ];
grupo = Title_roi;


c1 = data1; % Vector de Condicion 1
c2 = data2; %Vector de Condicion 2


yaxis = [min(min([c1;c2]))-0.2, max(max([c1;c2]))+0.2];        % define yaxis limits

%% run stats (Wilcoxon ranksum or signed test) and save

[stats] = test_wilcoxon_cvar(c1, c2, condition1, condition2, testType, windowSize, start_point);

%% Plot configuration

Xt = x_axis;%EjeX; % Time o EjeX

figure1 = grupo;
figure%('visible',display_fig,'position', [0, 0, 1000, 500]); hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = shadedErrorBar(Xt,c1,{@mean,@std},'lineprops', '-b');hold on;
p2 = shadedErrorBar(Xt,c2,{@mean,@std},'lineprops', '-k');hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel([xMeassure],'FontSize',12,'FontWeight','bold')
ylabel([yMeassure],'FontSize',12,'FontWeight','bold')
%%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
ylim([yaxis(1) yaxis(2)])
xlim ([x_axis(1) x_axis(end)])
legend(condition1,condition2);


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

%saveas(fig,char(strcat(ROIp,'.png')));
