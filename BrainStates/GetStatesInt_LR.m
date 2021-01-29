function statesint = GetStatesInt_LR(namestatefile)
% Lisa Roux, Mai 2018
% Geoffrey, September 2020 - modify the path to find states.mat file
%
% Provides the time intervals corresponding to each brain states once Sleep
% Scoring has been done on the session
%
% relies on sleep scoring data obtained with TheStateEditor
% requires: suprathresh (Andres)
%
% INPUTS
%  exemple: namestatefile = '7C012-S41';
%
% OUTPUT
% statesint:    structure which stores the intervals for each states
                    % statesint.sws = NREMint;
                    % statesint.wake = WAKint;
                    % statesint.rem = REMint;
                    % statesint.drowzy = Dint;
                    % statesint.inter = Iint;
%
%
% Notes on TheSateEditor: it stores data this way:
% 0 = 'no state', 1 = 'awake', 2 = 'Light/Drowzy', 3 = 'NREM', 4 = 'Intermediate', 5 = 'REM').
% 

%%

% try 
load(namestatefile);
% a = [namestatefile,'-states.mat'];
% load(a)
statesVector = states;
% whos statesVector
% 

% catch
%     disp('Sleep scoring needed')
% end

%% Get NREM epochs
% sum(statesVector == 3); % NREM epochs
NREMint = suprathresh(statesVector == 3, 0.5); % 0 or 1, TH:0.5
% whos NREM
% sum(diff(NREM, [], 2))
% whos NREM

%% Get Awake epochs
% sum(statesVector == 1); % awake epochs
WAKint = suprathresh(statesVector == 1, 0.5); % 0 or 1, TH:0.5


%% Get REM epochs
% sum(statesVector == 5); % REM epochs
REMint = suprathresh(statesVector == 5, 0.5); % 0 or 1, TH:0.5

%% Get Drowzy epochs
% sum(statesVector == 2); % Drowzy epochs
Dint = suprathresh(statesVector == 2, 0.5); % 0 or 1, TH:0.5

%% Get Intermediate epochs
% sum(statesVector == 4); % Intermediate state epochs
Iint = suprathresh(statesVector == 4, 0.5); % 0 or 1, TH:0.5

%% make results

statesint.sws = NREMint;
statesint.wake = WAKint;
statesint.rem = REMint;
statesint.drowzy = Dint;
statesint.inter = Iint;

%% save results

save StatesIntervals statesint


end