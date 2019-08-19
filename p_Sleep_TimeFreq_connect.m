% Define some important variables
s_TotalTimeSec = 30; %total number of seconds we are analysing 
s_fs = 1000; % sample frequency
s_TimeSam = s_TotalTimeSec * s_fs; %total time in samples

s_baselineStartTime = -7;
s_baselineEndTime = 0;
s_TimeBeforeCero = 15;

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
    %Asks for selection of a channel to detect the Slow Oscillations and
    %assigns to str_ChanSO
    [indx,tf] = listdlg('PromptString','Select a source: for Slow Oscillations',...
        'ListSize',[400 400],...
        'ListString',Sources);
    scouts = Sources(indx);  
else
    FileTemp = subjectFiles{1};
    Sources = string({FileTemp.Atlas.Scouts.Label});
    %Asks for selection of a region to detect the Slow Oscillations and
    %assigns to str_ROI_SO
    [indx,tf] = listdlg('PromptString','Select a source for Slow Oscillations:',...
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
        [MeanTrialSpectra(s_scout,subj,:,:), v_TimeAxis,v_FreqAxis,...
            DeltaPower(s_scout,subj,:), ThetaPower(s_scout,subj,:),...
            AlphaPower(s_scout,subj,:),SpindlePower(s_scout,subj,:),...
            BetaPower(s_scout,subj,:)] = ...
            f_Multitaper_ROI(DataOdor,file,scouts(s_scout),s_baselineStartTime,...
            s_baselineEndTime,s_TimeBeforeCero,ChanVsSource);
    end
    
    [CohNorm(subj,:,:,:,:),DeltaPowerCoh(subj,:,:,:),ThetaPowerCoh(subj,:,:,:),...
        AlphaPowerCoh(subj,:,:,:),SpindlePowerCoh(subj,:,:,:),...
        BetaPowerCoh(subj,:,:,:),v_TimeAxisCoh,v_FreqAxisCoh]= ...
        f_Connectivity(scouts,DataOdor,file,"Odor",s_TimeBeforeCero,...
        s_baselineStartTime,s_baselineEndTime,ChanVsSource); 
end

%% Mean and plots

% -----Plot spectra per scout-------

MeanSubjectsSpectra = squeeze(permute(mean(MeanTrialSpectra,2),[2,1,3,4]));

for s_scout = 1:numel(scouts)
    figure;
    pcolor(v_TimeAxis, v_FreqAxis, squeeze(MeanSubjectsSpectra(s_scout,:,:))); 
    xlim([s_baselineStartTime, v_TimeAxis(end)])
    colorbar; colormap('jet'); shading interp;
    title(strcat(scouts(s_scout),'__ Odor'))
    vline(0, 'r')
end

MeanSubjectsCohNorm = squeeze(mean(CohNorm,1));

for scout = 1:numel(scouts)
    for scout2 = 1:numel(scouts)
        if (scout2 ~= scout) && (scout<= ceil(numel(scouts)/2))
            Coherence = squeeze(squeeze(MeanSubjectsCohNorm(scout,scout2,:,:)));
            figure
            pcolor(v_TimeAxisCoh, v_FreqAxisCoh, Coherence);
            xlim([s_baselineStartTime, v_TimeAxis(end)])
            colorbar; colormap('jet'); shading interp;
            title(strcat(scouts(scout),'vs',scouts(scout2),'__ Odor'))
            vline(0, 'r')
        end
    end
end

