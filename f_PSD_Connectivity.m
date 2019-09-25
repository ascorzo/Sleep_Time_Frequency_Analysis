function [CodorOn,CodorOff,PSD_On,PSD_Off,v_FreqAxis] = ...
    f_PSD_Connectivity(scouts,Data,labels,s_TimeBeforeCero,fs)
%% Coh. Params

params.Fs = fs; 
params.tapers = [2 5]; 
params.err = 0;
params.trialave = 1; 
params.fpass = [0 30]; 
params.pad = -1;

%% Connectivity Analysis
for scout = 1:numel(scouts)
    
    s_ROI1 = find(strcmp(labels, scouts(scout)));
    
    for scout2 = scout:numel(scouts)
        
        if (scout2 ~= scout) % && (scout<= ceil(numel(scouts)/2))
            
            s_ROI2 = find(strcmp(labels, scouts(scout2)));
            
            DataTemp1 = Data(s_ROI1,:,:);
            DataTemp2 = Data(s_ROI2,:,:);
            
            [CodorOnTemp,~,~,...
                S1OdorOn,~,v_FreqAxis] = ...
                coherencyc(squeeze(DataTemp1(:,s_TimeBeforeCero*fs:end,:)),...
                squeeze(DataTemp2(:,s_TimeBeforeCero*fs:end,:)),...
                params);
            [CodorOffTemp,~,~,...h
                S1OdorOff,~,v_FreqAxis] = ...
                coherencyc(squeeze(DataTemp1(:,1:fs*s_TimeBeforeCero,:)),...
                squeeze(DataTemp2(:,1:fs*s_TimeBeforeCero,:)),...
                params);
            
            CodorOn(scout,scout2,:) = CodorOnTemp;
            CodorOn(scout2,scout,:) = CodorOnTemp;
            
            CodorOff(scout,scout2,:) = CodorOffTemp;
            CodorOff(scout2,scout,:) = CodorOffTemp;
            
            PSD_On(scout,:) = S1OdorOn;
            PSD_Off(scout,:) = S1OdorOff;
        end
        
    end
end