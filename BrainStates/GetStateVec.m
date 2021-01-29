function states = GetStateVec(baseName)
% DEPRECATED (lisa)

% baseName = 'TC03_Intan_S03_08012017_merged';
load([baseName,'.SleepState.states.mat'])

stateslen = max([max(max(SleepState.ints.NREMstate)) max(max(SleepState.ints.REMstate)) max(max(SleepState.ints.WAKEstate)) max(max(SleepState.ints.MAstate))]);
states = zeros(1,stateslen);

states(find(inttoboolIn(SleepState.ints.WAKEstate))) = 1;
states(find(inttoboolIn(SleepState.ints.MAstate))) = 2;
states(find(inttoboolIn(SleepState.ints.NREMstate))) = 3;
states(find(inttoboolIn(SleepState.ints.REMstate))) = 5;


end

function bool = inttoboolIn(ints,totalpoints)
% Takes a series of start-stop intervals (one row for each int, each row is
% [startpoint stoppoint]) and converts to a boolean with length
% (totalpoints) with zeros by default but 1s wherever points are inside
% "ints".  If totalpoints is not input then length is set by the last point
% in the last int.

warning off

if ~exist('totalpoints','var')
    totalpoints = 1;
end

bool = zeros(1,totalpoints);
for a = 1:size(ints,1);
    bool(round(ints(a,1)):round(ints(a,2))) = 1;
end
end