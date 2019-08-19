function [MeanSpectra,v_TimeAxis, v_FreqAxis]= ...
    f_MultitaperAnalysis(str_ROI,Data,file,s_baselineStart,s_baselineEnd,...
    s_TimeBeforeCero,ChanVsSource)

if strcmp(ChanVsSource,'Channel')
    s_ROI = find(strcmp(file.Channel.label, str_ROI));
else
    s_ROI = strcmp({file.Atlas.Scouts.Label},str_ROI);
end
   
%% Set default parameters

params.tapers = [3 5]; 
params.Fs = 1000;
params.err = 0;
params.fpass = [1 30]; %Frequency limits
params.pad = 1; 
params.trialave =0;

winsize = 4;
winstep = 0.4; 
v_MovingWin = [winsize winstep]; 

N_Trials = size(Data,3);

for Trial = 1:N_Trials
    DataTemp = squeeze(permute(Data(s_ROI,:,Trial),[3,1,2]));
    [m_Spectrum_Temp,v_TimeAxis,v_FreqAxis]= mtspecgramc(DataTemp,v_MovingWin,params); 
    m_Spectrum_Temp = m_Spectrum_Temp';
    %-----------Normalization----------------------------------------------
    v_TimeAxis = v_TimeAxis - s_TimeBeforeCero;
    [~, idx1] = min(abs(v_TimeAxis - s_baselineStart)); 
    [~, idx2] = min(abs(v_TimeAxis - s_baselineEnd)); 
    
    m_meanSpectrumBl = repmat(median(m_Spectrum_Temp(:,idx1:idx2),2),[1, size(m_Spectrum_Temp,2)]); 
    
    m_Spectrum_Norm = pow2db(m_Spectrum_Temp./m_meanSpectrumBl);
    AllSpectra(:,:,Trial) = m_Spectrum_Norm;   
end

%Mean across trials
MeanSpectra = mean(AllSpectra,3);

% figure;
% pcolor(v_TimeAxis, v_FreqAxis, MeanSpectra); xlim([s_baselineStart, v_TimeAxis(end)])
% colorbar; colormap('jet'); shading interp;
% title()

end
