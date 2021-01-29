function out = fixStateGaps(epochs, maxGapInSec)
%function out = fixStateGaps(epochs, maxGapInSec)

m = maxGapInSec;
[~, i] = sort(mean(epochs, 2));
epochs = epochs(i, :);

out = epochs(1, :);

for i = 2:size(epochs, 1)
    if epochs(i, 1) - out(end, 2) <= m
        out(end, 2) = epochs(i, 2);
    else
        out = [out; epochs(i, :)];
    end
end