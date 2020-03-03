clear;

main = 'C:\Users\lanan\Documents\Sleep Project\Sleep_Time_Frequency_Analysis'; 

cd([main,filesep,'dataOdor']); 
load([main, filesep, 'labels']);
files = dir('*.mat'); fnames = {files.name};

%% 1. Data Params
fs = 1000;
s_NumScouts = 105;
s_TimeSam = 30*fs;

%% 2. Coh. Params

roi(1) = 37; 
roi(2) = 102; 

params.Fs = fs; 
params.tapers = [2 5]; 
params.err = 0;
params.trialave = 1; 
params.fpass = [0 30]; 
params.pad = -1;

%%
for s=1:length(fnames)

load(fnames{s})
s_Trials = size(data,2)/s_TimeSam;

data = reshape(data, [s_NumScouts,s_Trials, s_TimeSam]); 

[CodorOn(s,:),~,~,S1OdorOn(s,:),S2OdorOn(s,:),f] = coherencyc(squeeze(data(roi(1),:,15*fs:end))',squeeze(data(roi(2),:,15*fs:end))',...
    params);
[CodorOff(s,:),~,~,S1OdorOff(s,:),S2OdorOff(s,:),f] = coherencyc(squeeze(data(roi(1),:,1:fs*15))',squeeze(data(roi(2),:,1:fs*15))',...
    params);

clear data
end 
%%
CodorOnAll = squeeze(mean(CodorOn,1)); 
CodorOffAll = squeeze(mean(CodorOff,1)); 

S1OdorOnAll = squeeze(mean(S1OdorOn,1)); 
S1OdorOffAll = squeeze(mean(S1OdorOff,1)); 

S2OdorOnAll = squeeze(mean(S2OdorOn,1)); 
S2OdorOffAll = squeeze(mean(S2OdorOff,1)); 

figure
subplot(2,2,1);
plot(f, log10(S1OdorOnAll),'b'); hold on; 
plot(f, log10(S1OdorOffAll), 'r');
title('pow spectrum area 1')
legend('odor ON', 'odor OFF');

subplot(2,2,2);
plot(f, log10(S2OdorOnAll),'b'); hold on; 
plot(f, log10(S2OdorOffAll), 'r');
title('pow spectrum area 2')
legend('odor ON', 'odor OFF');

subplot(2,2,[3,4]); 
plot(f,smooth(CodorOnAll),'b'); hold on;
plot(f, smooth(CodorOffAll),'r');
title('coh spectrum');
legend('odor ON', 'odor OFF');
