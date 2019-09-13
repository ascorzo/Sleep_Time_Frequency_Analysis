% Define some important variables
s_TotalTimeSec = 30; %total number of seconds we are analysing 
s_fs = 1000; % sample frequencyh
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
    'Channel','Source','Source');
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

%% Select Which areas to compare 

if strcmp(ChanVsSource,'Channel')
    FileTemp = load([pathNameChan FilesListChanOdor(1).name]);
    Sources = FileTemp.Channel.label;
    %Asks for selection of multiple channels or sources to calculate the connectivity 
    [indx,tf] = listdlg('PromptString','Select channels to analyze:',...
        'ListSize',[400 400],...
        'ListString',Sources);
    scouts = Sources(indx);  
else
    FileTemp = load([pathNameSource FilesListSourceOdor(1).name]);
    Sources = string({FileTemp.Atlas.Scouts.Label});
    %Asks for selection of multiple channels or sources to calculate the connectivity
    [indx,tf] = listdlg('PromptString','Select sources to analyze:',...
        'ListSize',[400 400],...
        'ListString',Sources);
    scouts = Sources(indx);
end

%% Odor datasets

for subj = 1:length(FilesListSourceOdor)
    
    switch ChanVsSource
        case 'Channel'
            %Set up datasets containing channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = load([pathNameChan FilesListChanOdor(subj).name]);
            s_NumChannels = length(file.Channel.number);
            v_Time = file.Channel.times;
            s_Trials = file.Channel.trials;
            DataOdor = double(file.Channel.data);
            
        case 'Source'
            %Set up datasets containing source data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = load([pathNameSource FilesListSourceOdor(subj).name]);
            s_NumScouts = length(file.Atlas.Scouts); % Detect the number of scouts
            v_Time = file.Time(1:s_TimeSam);
            s_Trials = size(file.Value,2)/s_TimeSam;
            DataOdor = reshape(file.Value,[s_NumScouts,s_TimeSam,s_Trials]);
    end
   
   [CodorOn(subj,:,:,:),CodorOff(subj,:,:,:),...
       PSD_OdorOn(subj,:,:),PSD_OdorOff(subj,:,:),v_FreqAxis] = ...
    f_PSD_Connectivity(scouts,DataOdor,Sources,s_TimeBeforeCero,s_fs);

end

%% Placebo datasets

for subj = 1:length(FilesListSourcePlacebo)
    
    switch ChanVsSource
        case 'Channel'
            %Set up datasets containing channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = load([pathNameChan FilesListChanPlacebo(subj).name]);
            s_NumChannels = length(file.Channel.number);
            v_Time = file.Channel.times;
            s_Trials = file.Channel.trials;
            DataPlacebo = double(file.Channel.data);
            
        case 'Source'
            %Set up datasets containing source data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file = load([pathNameSource FilesListSourcePlacebo(subj).name]);
            s_NumScouts = length(file.Atlas.Scouts); % Detect the number of scouts
            v_Time = file.Time(1:s_TimeSam);
            s_Trials = size(file.Value,2)/s_TimeSam;
            DataPlacebo = reshape(file.Value,[s_NumScouts,s_TimeSam,s_Trials]);
    end
       
    [CPlacOn(subj,:,:,:),CPlacOff(subj,:,:,:),...
        PSD_PlacOn(subj,:,:),PSD_PlacOff(subj,:,:),v_FreqAxis] = ...
    f_PSD_Connectivity(scouts,DataOdor,Sources,s_TimeBeforeCero,s_fs);
end