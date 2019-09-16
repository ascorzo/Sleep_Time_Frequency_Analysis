function [CodorOn,CodorOff,PSD_On,PSD_Off,v_FreqAxis] = ...
    f_PSD_Connectivity_Chunks(scouts,Data,labels,s_TimeBeforeCero,fs)
%% Coh. Params

params.Fs = fs; 
params.tapers = [2 5]; 
params.err = 0;
params.trialave = 1; h
params.fpass = [0 30]; 
params.pad = -1;
s_chunkSize = 2; %chunk size in seconds
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
            [CodorOffTemp,~,~,...
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
            
            %% By Chunks
            ChunkDataOn1 = DataTemp1(:,s_TimeBeforeCero*fs:end,:);
            ChunkDataOn2 = DataTemp1(:,s_TimeBeforeCero*fs:end,:);
            
            ChunkDataOff1 = DataTemp1(:,1:fs*s_TimeBeforeCero,:);
            ChunkDataOff2 = DataTemp1(:,1:fs*s_TimeBeforeCero,:);
                
            for chunk = 1:floor(s_TimeBeforeCero/s_chunkSize)      
                ChunkTempOn1 = ChunkDataOn1(:,((chunk-1)*s_chunkSize)+1:chunk*s_chunkSize,:);
                ChunkTempOn2 = ChunkDataOn2(:,((chunk-1)*s_chunkSize)+1:chunk*s_chunkSize,:); 
                
                ChunkTempOff1 = ChunkDataOn1(:,((chunk-1)*s_chunkSize)+1:chunk*s_chunkSize,:);
                ChunkTempOff2 = ChunkDataOn2(:,((chunk-1)*s_chunkSize)+1:chunk*s_chunkSize,:);
                
                [CodorOnChunk(chunk,:),~,~,...
                    S1OdorOnChunk(chunk,:),~,v_FreqAxis] = ...
                    coherencyc(squeeze(DataTemp1(:,s_TimeBeforeCero*fs:end,:)),...
                    squeeze(DataTemp2(:,s_TimeBeforeCero*fs:end,:)),...
                    params);
                [CodorOffChunk(chunk,:),~,~,...
                    S1OdorOffChunk(chunk,:),~,v_FreqAxis] = ...
                    coherencyc(squeeze(DataTemp1(:,1:fs*s_TimeBeforeCero,:)),...
                    squeeze(DataTemp2(:,1:fs*s_TimeBeforeCero,:)),...
                    params);
            end
            CodorOnTotal = mean(CodorOnChunk,1);
            CodorOffTotal = mean(CodorOffChunk,1);
            S1OdorOntotal = mean(S1OdorOffChunk,1);
        end
        
    end
end
