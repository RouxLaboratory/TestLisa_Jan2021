function Ct = makePopStdbyNREMSimple1(spikes, cells,  NREMepochsInSec, triggerStd)
%function out = makePopStdbyNREM(spikes, cells, NREMepochs, triggerStd (usually 3))
%
% spikes{1} == RES (spike times in 20kHz sampling rate); % does not include
% clusters 0 and 1, list of timestamps (in nb of samples) as given by Res file (has to be
% divided by 20000 to have the tsp in sec)
% 
% spikes{2} == Clu % identity of the units corresponding to the timestamps
% (each cell has a unique index). 
% RES and Clu have the same length:
% length(spikes{1}) must == length(spikes{2})
%
% cells: list of the indices corresponding to the pyramidal cells
%
% NREMepochsInSec(optional): two column vector of NREM start and end times
% obtained with TheStateEditor, will be used to compute the baseline (not a
% restriction on these time periods)
%
% minLength = 0.05;
% maxLength = 0.5;
% gaussWin = makeGaussStd2(80, 20);
% baseStd = 0;

baseStd = 0;
minLength = 0.05; % minimal event length (sec)
% maxLength = 1;  % max event length % Andres's setting
maxLength = 0.50;  % max event length
% gaussWin = makeGaussStd2(60, 15); % Gaussian, 60ms width, 15ms STD, will be used for the convolution of the spike train % Andres setting
gaussWin = makeGaussStd2(60, 10);
minGap = 50; % mininal gap allowed between two events (merged otherwise)


params.triggerStd = triggerStd;
params.baseStd = baseStd;
params.gaussWin =  gaussWin;
out = [];

% takes only the spikes of the pyramidal cells
s = spikes{1}(ismember(spikes{2}, cells))/20; % divided by 20 to have the tsp in milliseconds (20000Hz/20)
NREM = NREMepochsInSec;


% bin the spikes in 1ms bins
msSpikeBins = histc(s, 0:max(spikes{1}/20));
% convolve the spike train
msSpikeBins = convtrim(msSpikeBins, gaussWin);

% build a time vector with 1ms time bins
% will be used to select the time periods corresponding to NREM
t = 0:0.001:(max(spikes{1})/20000);
if ~isempty(NREM)
    
    id = inInterval(NREM, t);
    mean1 = mean(msSpikeBins(id ~= 0));
    std1 = std(msSpikeBins(id ~= 0));
    msSpikeBins = (msSpikeBins - mean1)/std1; % make the zscore
else
    msSpikeBins = zscore(msSpikeBins);
end

edges1 = suprathresh(msSpikeBins, baseStd);

peaks1 = suprathresh(msSpikeBins, triggerStd);

[~, counts] = inInterval(edges1, mean(peaks1, 2));

Ct = edges1(counts >= 1, :);

Ct = fixStateGaps(Ct, minGap)/1000; %%%%Now in seconds



Ct = Ct(diff(Ct, [], 2) >= minLength & diff(Ct, [], 2) <= maxLength, :);

% [Cr, Co] = binInIntRatePlusTime(spikes, cells, Ct);

%     c = sum(Cr > 0, 2);
%     out.(pNames{I}).Ct = Ct(c >= minCells, :);
%     out.(pNames{I}).Cr = Cr(c >= minCells, :);
%     out.(pNames{I}).Co = Co(c >= minCells, :);
%     out.(pNames{I}).params = params;
