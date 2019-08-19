function [DeltaPower,ThetaPower,AlphaPower,SpindlePower,BetaPower] = ...
    f_FreqCalc(MeanGabor,v_FreqAxis)

s_fLowDelta = 1;
s_fHighDelta = 4;

s_fLowTheta= 4;
s_fHighTheta = 7.5;

s_fLowAlpha = 8;
s_fHighAlpha = 10.5;

s_fLowSpindle = 7;
s_fHighSpindle = 14;

s_fLowBeta = 16;
s_fHighBeta = 30;

% delta plot
freqsInd = (v_FreqAxis >= s_fLowDelta);
freqsInd = v_FreqAxis.*freqsInd;
freqsInd = (freqsInd <= s_fHighDelta);
freqsInd = freqsInd==1;

DeltaPower = sum(MeanGabor(freqsInd,:),1);


% % Theta plot
freqsInd = (v_FreqAxis >= s_fLowTheta);
freqsInd = v_FreqAxis.*freqsInd;
freqsInd = (freqsInd <= s_fHighTheta);
freqsInd = freqsInd==1;

ThetaPower = sum(MeanGabor(freqsInd,:),1);


% Alpha plot
freqsInd = (v_FreqAxis >= s_fLowAlpha);
freqsInd = v_FreqAxis.*freqsInd;
freqsInd = (freqsInd <= s_fHighAlpha);
freqsInd = freqsInd==1;

AlphaPower = mean(MeanGabor(freqsInd,:),1);


% Spindles plot
freqsInd = (v_FreqAxis >= s_fLowSpindle);
freqsInd = v_FreqAxis.*freqsInd;
freqsInd = (freqsInd <= s_fHighSpindle);
freqsInd = freqsInd==1;

SpindlePower = sum(MeanGabor(freqsInd,:),1);


% Beta plot
freqsInd = (v_FreqAxis >= s_fLowBeta);
freqsInd = v_FreqAxis.*freqsInd;
freqsInd = (freqsInd <= s_fHighBeta);
freqsInd = freqsInd==1;

BetaPower = sum(MeanGabor(freqsInd,:),1);
end

