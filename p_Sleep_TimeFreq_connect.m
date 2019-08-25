% Define some important variables
s_TotalTimeSec = 30; %total number of seconds we are analysing 
s_fs = 1000; % sample frequency
s_TimeSam = s_TotalTimeSec * s_fs; %total time in samples

s_baselineStartTime = -7;
s_baselineEndTime = 0;
s_TimeBeforeCero = 15;
s_TimeAfterCero = 15;

%% Set up user land
% Normally not needed to add slash to end of folder paths. But necessary in
% case of searching for specific extensions.
if contains(computer,'PCWIN')
    slashSys = '\';
else
    slashSys = '/';
end

%Selection of folder where channel data is contained
ChanVsSource = questdlg('Import channel recording data or source-computed cortex data?', ...
    'Channel or Source?', ...
    'Channel','Source','Channel');
%% Create a Files List in order to go through them for the analysis

switch ChanVsSource
    case 'Channel'
        %Containing channel data
        if ~exist('pathNameChan','var') || size(pathNameChan,2) < 3
            % path to datasets containing channel data
            pathNameChan = [uigetdir(cd,'Choose the folder that contains the CHANNEL datasets'), slashSys];
            addpath(pathNameChan)
            FilesListChanOdor = dir([pathNameChan,'*Odor.mat']);
            FilesListChanPlacebo = dir([pathNameChan,'*Placebo.mat']);
            
            FilesList = FilesListChanOdor;
        end
    case 'Source'
        if  ~exist('pathNameSource','var') || size(pathNameSource,2) < 3 
            %path to datasets with source estimation
            pathNameSource = [uigetdir(cd,'Choose the folder that contains the SOURCE datasets'), slashSys];
            addpath(pathNameSource)
            FilesListSourceOdor = dir([pathNameSource,'*Odor.mat']);
            FilesListSourcePlacebo = dir([pathNameSource,'*Placebo.mat']);
            
            FilesList = FilesListSourceOdor;
        end
end
%% Loading Odor sets into memory

for Load2Mem = 1:numel(FilesList)
    if strcmp(ChanVsSource,'Channel')
        subjectFiles{Load2Mem,1} = load([pathNameChan FilesListChanOdor(Load2Mem).name]);
    else
        subjectFiles{Load2Mem,1} = load([pathNameSource FilesListSourceOdor(Load2Mem).name]);
    end
end
 

%% Select Which areas to compare 

if strcmp(ChanVsSource,'Channel')
    FileTemp = load(FilesListChanOdor(1).name);
    Sources = FileTemp.Channel.label;
    %Asks for selection of multiple channels or sources to calculate the connectivity 
    [indx,tf] = listdlg('PromptString','Select channels to analyze:',...
        'ListSize',[400 400],...
        'ListString',Sources);
    scouts = Sources(indx);  
else
    FileTemp = subjectFiles{1};
    Sources = string({FileTemp.Atlas.Scouts.Label});
    %Asks for selection of multiple channels or sources to calculate the connectivity
    [indx,tf] = listdlg('PromptString','Select sources to analyze:',...
        'ListSize',[400 400],...
        'ListString',Sources);
    scouts = Sources(indx);
end

%% Odor datasets

for subj = 1:length(subjectFiles)
    
    switch ChanVsSource
        case 'Channel'
            %Set up datasets containing channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = load(FilesListChanOdor(subj).name);
            s_NumChannels = length(file.Channel.number);
            v_Time = file.Channel.times;
            s_Trials = file.Channel.trials;
            DataOdor = double(file.Channel.data);
            
        case 'Source'
            %Set up datasets containing source data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = subjectFiles{subj};
            s_NumScouts = length(file.Atlas.Scouts); % Detect the number of scouts
            v_Time = file.Time(1:s_TimeSam);
            s_Trials = size(file.Value,2)/s_TimeSam;
            DataOdor = reshape(file.Value,[s_NumScouts,s_TimeSam,s_Trials]);
    end
    
    for s_scout = 1:numel(scouts)
        [MeanTrialSpectraOdor(s_scout,subj,:,:), v_TimeAxis,v_FreqAxis,...
            DeltaPower(s_scout,subj,:), ThetaPower(s_scout,subj,:),...
            AlphaPower(s_scout,subj,:),SpindlePower(s_scout,subj,:),...
            BetaPower(s_scout,subj,:)] = ...
            f_Multitaper_ROI(DataOdor,file,scouts(s_scout),s_baselineStartTime,...
            s_baselineEndTime,s_TimeBeforeCero,ChanVsSource);
    end
    
    [CohNormOdor(subj,:,:,:,:),DeltaPowerCohOdor(subj,:,:,:),...
        ThetaPowerCohOdor(subj,:,:,:),...
        AlphaPowerCohOdor(subj,:,:,:),SpindlePowerCohOdor(subj,:,:,:),...
        BetaPowerCohOdor(subj,:,:,:),v_TimeAxisCoh,v_FreqAxisCoh]= ...
        f_Connectivity(scouts,DataOdor,file,"Odor",s_TimeBeforeCero,...
        s_baselineStartTime,s_baselineEndTime,ChanVsSource); 
end

%% Mean and plots Odor condition

% % -----Plot spectra per scout-------
% 
MeanSubjectsSpectraOdor = squeeze(permute(mean(MeanTrialSpectraOdor,2),[2,1,3,4]));
% 
% % for s_scout = 1:numel(scouts)
% %     figure;
% %     pcolor(v_TimeAxis, v_FreqAxis, squeeze(MeanSubjectsSpectraOdor(s_scout,:,:))); 
% %     xlim([s_baselineStartTime, v_TimeAxis(end)])
% %     colorbar; colormap('jet'); shading interp;
% %     title(strcat(scouts(s_scout),'__ Odor'))
% %     vline(0, 'r')
% % end
% 
MeanSubjectsCohNormOdor = squeeze(mean(CohNormOdor,1));
MeanSubjectBetaCohOdor = squeeze(mean(BetaPowerCohOdor,1));
MeanSubjectSpindlesCohOdor = squeeze(mean(SpindlePowerCohOdor,1));

% 
% for scout = 1:numel(scouts)
%     for scout2 = 1:numel(scouts)
%         if (scout2 ~= scout) && (scout<= ceil(numel(scouts)/2))
%             Coherence = squeeze(squeeze(MeanSubjectsCohNormOdor(scout,scout2,:,:)));
% %             figure
% %             pcolor(v_TimeAxisCoh, v_FreqAxisCoh, Coherence);
% %             xlim([s_baselineStartTime, v_TimeAxis(end)])
% %             colorbar; colormap('jet'); shading interp;
% %             title(strcat(scouts(scout),'vs',scouts(scout2),'__ Odor'))
% %             vline(0, 'r')
%             
%             figure 
%             plot(v_TimeAxisCoh,squeeze(MeanSubjectBetaCohOdor(scout,scout2,:)),'m')
%             hold on
%             plot(v_TimeAxisCoh,squeeze(MeanSubjectSpindlesCohOdor(scout,scout2,:)),'b')
%             title(strcat(scouts(scout),'vs',scouts(scout2),'__ Odor'))
%             vline(0, 'r')
%         end
%     end
% end

%% Loading Placebo sets into memory

for Load2Mem = 1:numel(FilesList)
    if strcmp(ChanVsSource,'Channel')
        subjectFiles{Load2Mem,1} = load([pathNameChan FilesListChanPlacebo(Load2Mem).name]);
    else
        subjectFiles{Load2Mem,1} = load([pathNameSource FilesListSourcePlacebo(Load2Mem).name]);
    end
end

%% Placebo datasets

for subj = 1:length(subjectFiles)
    
    switch ChanVsSource
        case 'Channel'
            %Set up datasets containing channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = load(FilesListChanPlacebo(subj).name);
            s_NumChannels = length(file.Channel.number);
            v_Time = file.Channel.times;
            s_Trials = file.Channel.trials;
            DataPlacebo = double(file.Channel.data);
            
        case 'Source'
            %Set up datasets containing source data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = subjectFiles{subj};
            s_NumScouts = length(file.Atlas.Scouts); % Detect the number of scouts
            v_Time = file.Time(1:s_TimeSam);
            s_Trials = size(file.Value,2)/s_TimeSam;
            DataPlacebo = reshape(file.Value,[s_NumScouts,s_TimeSam,s_Trials]);
    end
    
    for s_scout = 1:numel(scouts)
        [MeanTrialSpectraPlac(s_scout,subj,:,:), v_TimeAxis,v_FreqAxis,...
            DeltaPower(s_scout,subj,:), ThetaPower(s_scout,subj,:),...
            AlphaPower(s_scout,subj,:),SpindlePower(s_scout,subj,:),...
            BetaPower(s_scout,subj,:)] = ...
            f_Multitaper_ROI(DataPlacebo,file,scouts(s_scout),s_baselineStartTime,...
            s_baselineEndTime,s_TimeBeforeCero,ChanVsSource);
    end
    
    [CohNormPlac(subj,:,:,:,:),DeltaPowerCohPlac(subj,:,:,:),...
        ThetaPowerCohPlac(subj,:,:,:),...
        AlphaPowerCohPlac(subj,:,:,:),SpindlePowerCohPlac(subj,:,:,:),...
        BetaPowerCohPlac(subj,:,:,:),v_TimeAxisCoh,v_FreqAxisCoh]= ...
        f_Connectivity(scouts,DataPlacebo,file,"Placebo",s_TimeBeforeCero,...
        s_baselineStartTime,s_baselineEndTime,ChanVsSource); 
end

%% Mean and plots Placebo condition

% -----Plot spectra per scout-------

MeanSubjectsSpectraPlacebo = ...
    squeeze(permute(mean(MeanTrialSpectraPlac,2),[2,1,3,4]));

% for s_scout = 1:numel(scouts)
%     figure;
%     pcolor(v_TimeAxis, v_FreqAxis, squeeze(MeanSubjectsSpectraPlacebo(s_scout,:,:))); 
%     xlim([s_baselineStartTime, v_TimeAxis(end)])
%     colorbar; colormap('jet'); shading interp;
%     title(strcat(scouts(s_scout),'__ Placebo'))
%     vline(0, 'r')
% end
% 
MeanSubjectsCohNormPlac = squeeze(mean(CohNormPlac,1));
MeanSubjectBetaCohPlac = squeeze(mean(BetaPowerCohPlac,1));
MeanSubjectSpindlesCohPlac = squeeze(mean(SpindlePowerCohPlac,1));

% for scout = 1:numel(scouts)
%     for scout2 = 1:numel(scouts)
%         if (scout2 ~= scout) && (scout<= ceil(numel(scouts)/2))
%             Coherence = squeeze(squeeze(MeanSubjectsCohNormPlac(scout,scout2,:,:)));
%             figure
%             pcolor(v_TimeAxisCoh, v_FreqAxisCoh, Coherence);
%             xlim([s_baselineStartTime, v_TimeAxis(end)])
%             colorbar; colormap('jet'); shading interp;
%             title(strcat(scouts(scout),'vs',scouts(scout2),'__ Placebo'))
%             vline(0, 'r')
%             
%             figure 
%             plot(v_TimeAxisCoh,squeeze(MeanSubjectBetaCohPlac(scout,scout2,:)),'m')
%             hold on
%             plot(v_TimeAxisCoh,squeeze(MeanSubjectSpindlesCohPlac(scout,scout2,:)),'b')
%             title(strcat(scouts(scout),'vs',scouts(scout2),'__ Placebo'))
%             vline(0, 'r')
%         end
%     end
% end


%% Plots together

for scout = 1:numel(scouts)
    for scout2 = 1:numel(scouts)
        if (scout2 ~= scout) && (scout<= ceil(numel(scouts)/2))            
            figure 
            
            subplot(2,1,1)
            shadedErrorBar(v_TimeAxisCoh,...
                squeeze(permute(BetaPowerCohOdor(:,scout,scout2,:),[2,3,1,4])),...
                {@mean,@std},'lineprops', '-r');
            %plot(v_TimeAxisCoh,squeeze(MeanSubjectBetaCohPlac(scout,scout2,:)),'m')
            hold on
            shadedErrorBar(v_TimeAxisCoh,...
                squeeze(permute(BetaPowerCohPlac(:,scout,scout2,:),[2,3,1,4])),...
                {@mean,@std},'lineprops', '-b');
            %plot(v_TimeAxisCoh,squeeze(MeanSubjectBetaCohOdor(scout,scout2,:)),'b')     
            vline(0, 'r')
            title('Beta')
            xlim([s_baselineStartTime s_TimeAfterCero])
            legend('Placebo','Odor')
            
            subplot(2,1,2)
            shadedErrorBar(v_TimeAxisCoh,...
                squeeze(permute(SpindlePowerCohOdor(:,scout,scout2,:),[2,3,1,4])),...
                {@mean,@std},'lineprops', '-r');
            %plot(v_TimeAxisCoh,squeeze(MeanSubjectSpindlesCohPlac(scout,scout2,:)),'m')
            hold on
            shadedErrorBar(v_TimeAxisCoh,...
                squeeze(permute(SpindlePowerCohPlac(:,scout,scout2,:),[2,3,1,4])),...
                {@mean,@std},'lineprops', '-b');
            %plot(v_TimeAxisCoh,squeeze(MeanSubjectSpindlesCohOdor(scout,scout2,:)),'b')
            vline(0, 'r')
            title('Spindles')
            xlim([s_baselineStartTime s_TimeAfterCero])
            legend('Placebo','Odor')
            
            ROI1 = scouts(scout); ROI2 = scouts(scout2);
            ROI1 = strrep(ROI1,'_','\_'); ROI2 = strrep(ROI2,'_','\_'); 
            suptitle(strcat(ROI1,{' vs '},ROI2))
        end
    end
end