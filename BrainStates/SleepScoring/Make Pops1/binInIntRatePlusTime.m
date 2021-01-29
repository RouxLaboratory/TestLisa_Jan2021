function [binnedRate, binnedTime, intervals, binnedCounts] = binInIntRatePlusTime(spikes, cells, intervals, varargin);
%function [binnedRate, binnedTime, intervals] = binInIntRatePlusTime(spikes, cells, intervals, timeType ('min'|mean, default 'min), minCells(optional));
%
% intervals corresponds to the output Ct of makePopStdbyNREMSimple1
% spikes correspond to s in makePopStdbyNREMSimple1 ???
% idem for cells (list of pyr indices)
%
% 'min' gives the time of the first spike in event (not relative to the
% beginning of the event but to the global time frame)
% 0 if no firing
%
% 'mean' gives the mean time of all the spikes in the event
% 0 if no firing
% 
% Outputs:
% binnedRate = one row per event i, one column per cell, gives the mean
% firing rate during event i
% 
% binnedTime = one row per event i, one column per cell, gives the mean
% time or the time of the first spike in event i




timeType = 'min';
minCells = [];
if ~isempty(varargin)
    if length(varargin) == 1
    timeType = varargin{1};
    else
        if length(varargin) == 2
            timeType = varargin{1};
            minCells = varargin{2};
        end
    end
end

spikes{1} = spikes{1}/20000;
binnedRate = [];
binnedRate(size(intervals, 1), length(cells)) = 0;
binnedTime = binnedRate;
binnedCounts = binnedRate; % added by Lisa 02 oct 2015


for I = 1:length(cells)
%     I
    [indexes, counts] = inInterval(intervals, spikes{1}(spikes{2} == cells(I)));
    binnedRate(:, I) = counts./diff(intervals, [], 2);
    binnedCounts(:,I) = counts;
    if nargout > 1
        s = spikes{1}(spikes{2} == cells(I));
        a = zeros(length(counts), 1);
        k = find(counts > 0);
        for i = 1:length(k)
            switch timeType
                case 'min'
                    a(k(i)) = (min(s(indexes == k(i))) - intervals(k(i), 1))*1000 + 1;
                case 'mean'
                    a(k(i)) = (mean(s(indexes == k(i))) - intervals(k(i), 1))*1000 + 1;
            end
        end
        binnedTime(:, I) = a;
    end    
end

if ~isempty(minCells)
	k = find(sum(binnedRate > 0, 2) >= minCells);
    binnedRate = binnedRate(k, :);
    binnedTime = binnedTime(k, :);
    binnedCounts = binnedCounts(k, :);
    intervals = intervals(k, :);
end