function GetRatesInStates_LR_GT(basename)
%add accumulate time of states was not working and save info in
%FiringRates.mat
% Geoffrey 14 April 2020

% Lisa Roux Mai 2018
% 
% retrieves firing rate of each units in the different brain states
% (obtained with TheStateEditor)
% Note: uses buzcode format and [baseName,'.spikes.cellinfo.mat']
%
% INPUTS
% ex basename = 'TC03_Intan_S03_08012017';
% % % % ex namestatefile = 'TC03_Intan_S03_08012017_merged-states.mat'
% % % % 1- Compute duration spent in each brain state
% % % % 
% % % % % namestatefile = 'TC03_Intan_S03_08012017_merged-states.mat'
% % % % cd StateEditor
% % % % statesint = GetStatesInt_LR(namestatefile);
% % % % cd ..
% % % % 
% % % 
% % % % totSWS = AccumulateTimeInt(statesint.sws);
% % % % totWAKE = AccumulateTimeInt(statesint.wake);
% % % % % todo : other states
basepath = pwd; basename = bz_BasenameFromBasepath(basepath);
%% 2- Retrieve rates 
load([basename,'.spikes.cellinfo.mat'])
% load('TC03_Intan_S03_08012017.spikes.cellinfo.mat')
% spikes

Ncells = size((spikes.UID),2);
Nstates = 5;
Res = nan(Ncells,Nstates);

load('StatesIntervals.mat')
% NREM
int = statesint.sws;
IntState = length(int(:,1));
for i = 1:IntState
    TimeState = int(i,2)-int(i,1);
    totState(i,:)= [TimeState];
end
durState = sum(totState);

StateID = 1;

for UID = 1:Ncells
    tsp = spikes.times{UID};
    tspState = Restrict(tsp,int);
    totspkState = size(tspState,1);
    rateState = totspkState/durState;
    Res(UID,StateID)= rateState;
end


% REM
int = statesint.rem;
IntState = length(int(:,1));
for i = 1:IntState
    TimeState = int(i,2)-int(i,1);
    totState(i,:)= [TimeState];
end
durState = sum(totState);
StateID = 2;

for UID = 1:Ncells
    tsp = spikes.times{UID};
    tspState = Restrict(tsp,int);
    totspkState = size(tspState,1);
    rateState = totspkState/durState;
    Res(UID,StateID)= rateState;
end


% Wake
int = statesint.wake;
IntState = length(int(:,1));
for i = 1:IntState
    TimeState = int(i,2)-int(i,1);
    totState(i,:)= [TimeState];
end
durState = sum(totState);
StateID = 3;

for UID = 1:Ncells
    tsp = spikes.times{UID};
    tspState = Restrict(tsp,int);
    totspkState = size(tspState,1);
    rateState = totspkState/durState;
    Res(UID,StateID)= rateState;
end

FiringRatesStates = Res;
save FiringRatesStates FiringRatesStates
end



% % function AccumulateTimeInt(Intervals)
% % 
% % % Intervals should be a list of [start stop] intervals
% % 
% % 
% % % Intervals = MovIntPre;
% % 
% % IntNB = length(Intervals(:,1));
% % 
% % TotTime = 0;
% % 
% % for ii = 1:IntNB
% %     TimeInt = Intervals(ii,2)-Intervals(ii,1);
% %     TotTime = TotTime + TimeInt;
% % end
% % 
% % end