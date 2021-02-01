function [UID,Type1,Type2,pval, fmax, TtoPdur,SpkW,wavmean] = CellClassifier_bzLR(UID);
% [Type1,Type2,pval, fmax, TtoPdur] = CellClassifier_bzLR(UID);
%
%   USAGE
%   For a given unit, determines whether it is and INT or a PYR based on spike waveform caracteristics.
%   Script based on buzcode format, scalefactor is computed for Intan
%   recordings (not used at the moment)
% 
%   Uses Eran Stark classifier (based on unit tagging by optical activation
%   and mono-synaptic connectivity) - see Stark et al. 2013
%
% INPUT
% 
% UID:  unit identification number as stored in spikes.UID from bz_GetSpikes
% 
% OUTPUTS
%
% wavmean: 32 values of the mean waveform (on the channel where it is the
% biggest)
% 
% Lisa Roux, Mai 2018: from Eran Stark CellClassifier
% update 31 May 2018: Truncates waveform to match 32 samples
% Lisa, July 2020: add as outputs: SpkW,wavmean, and UID
% Lisa, Fev2021
%%
%
% for Amplipex recordings:
%
        % scalefactor = 1 / 2^par.nBits * p2pvoltage * 1e6 / par.Amplification; % a2d units -> microVolts
        % Because the digitizing card is actually 14 bits, the 10 volts is divided into only 2^14=16384 levels at the time of digitization. 
        % It is true that it is saved as a 16 bit number but that is irrelevant for the scaling. So, in your case, the numbers are:

%         scalefactor = 1 / 2^14 * 10 * 1e6 / 400; % which is approximately 1.53 micro Volts
        
%         % % According to Tony:
%         % scalefactor = 1 / 2^16 * 10 * 1e6 / 400;
%         % which is approximately 0.38 micro Volts


% for Intan recordings
 basePath = pwd;
 baseName = bz_BasenameFromBasepath(basePath);
 
load([baseName,'.sessionInfo.mat'])
scalefactor = 1 / 2^sessionInfo.nBits * sessionInfo.VoltageRange * 1e6 / sessionInfo.Amplification; % in microVolts


%% Get waveform features

% 
% %         unit = [2 2];
%         data = GetSpikeWaveforms(unit); % 3D matrix: (1) indiv spikes, (2) site (x8), (3) sample (x32)
%         test = mean(data,1);
%         testok = squeeze(test); %make a 2D matrix (dimension reduction)
% 
%      
%         % find the value of the trough for each channel
%         
% %             MinAmpRes = zeros(8,1);
% %             for ii=1:8
% %                 MinAmpRes(ii,1)=min(testok(ii,:));
% %             end
% 
%         % faster to take the value 16 on the waveform of each
%         % channel
%       
%          MinAmpRes = testok(:,16);
%         
%        
%         %find the channel where the amplitude of the spike is the largest
%         
% %             ChSelect = 1;
% %             BestVal = MinAmpRes(1,1);
% %             for ii=2:8
% %                 if BestVal > MinAmpRes(ii,1)
% %                     BestVal = MinAmpRes(ii,1);
% %                     ChSelect = ii;
% %                 end
% %             end
%         
%         
%         idx = find(MinAmpRes(:) == min(MinAmpRes));
%         ChSelect = idx;
%         
%         wav = data(:,ChSelect,:)*scalefactor;
%         wav = squeeze(wav);
% 
% %         res = MeanNonan(wav,1);
% 
% 
%         wavmean = mean(wav,1);
%         
        
        
        %% Get waveform info from buzcode format
        
       load([baseName,'.spikes.cellinfo.mat'])

     wavmean = spikes.rawWaveform{UID};
     ChSelect = spikes.maxWaveformCh(UID);
%         figure, PlotXY([v',wavmean'])
     
Fs = sessionInfo.rates.wideband; % sampling frequency of the recording (wide band)
nsamples = size(wavmean,2);

if nsamples > 32
    wavmean = wavmean(:,1:32);
    nsamples = 32;
    disp('Truncates waveform to match 32 samples')
end

        %% from spikes_stats (Eran): set up parameters

% Fs = 20000;
wintype = 'hanning';    % spectrum
nfft = 1024;            % spectrum
% nsamples = 32;

switch wintype
    case 'hanning'
        win = hanning( nsamples );
    case 'rect'
        win = ones( nsamples, 1 );
    case 'hamming'
        win = hamming( nsamples );
end
% From spikes_stats (Eran):
[ pow2 f ] = my_spectrum( wavmean', nfft, Fs, win, 0, 0 ); % correction april 5 2016 based on Gab script
% [ pow2 f ] = my_spectrum( wav, nfft, Fs, win, 0, 0 );

% MY_SPECTRUM           Welch spectrum for multiple signals.
% call                  [ PXX, F ] = MY_SPECTRUM( X, NFFT, FS, WINDOW, NOVERLAP, DFLAG )       

% returns               PXX         column-by-column auto spectrum
%                       F           frequency vector (matches PXX dimensions)
%
% does                  applies the Welch method of spectral estimation to
%                       each column (signal, trial) of X: divide signal
%                       into equal (overlapping) segments. window, fft, and
%                       power spectrum each segment. then average the
%                       spectra.
        
        

            mp = mean( pow2( 2 : end, : ), 2 );
            [ ign, midx ] = max( mp );
            fmax = f( midx ); % peak of spectrum        

%%
%       
% % Gab code: 
%   [powspectra,f2]=my_spectrum(maxmeanwv', 1024, 20000, hanning(32), 0, 0 );
%   SpikeFreq2=f2(powspectra==max(powspectra));
%   invF2=(1/SpikeFreq2)*1000;%(= spike width in ms)
            
%%


%         waveform =  testok(ChSelect,:);
        waveform =  wavmean;
%         nsamples = size(waveform,2);

        % 1- computes value of trough
%         BestVal = testok(idx,16); 
        TroughVal = min(wavmean); 

        % 2- find sample location of the trough
        TroughSample = find(wavmean == TroughVal);

        % 3- consider only waveform after the trough to find the peak:
        waveformPostT = waveform(TroughSample+1:nsamples);
        PeakVal = max(waveformPostT);
        
        % 4- find sample location of the peak 
        PeakSample = find(wavmean == PeakVal);
        
        % 5- Compute the duration between trough and peak:
               
%         bindur = 1/20000;
%         bindur = 1/sessionInfo.rates.wideband; % duration between 2 samples
        bindur = 1/Fs; % duration between 2 samples
        TtoPdur = (PeakSample-TroughSample)*bindur*1000; %in msec

        % 6- Compute Ratio TroughToPeak
        RatioTtoP = abs(TroughVal)/abs(PeakVal);
        
        
        
        %% From spikes_stats (Eran):
%         fmax = f( midx ); % peak of spectrum
%         sst.fmax( i, : ) = fmax;            % peak spectrum (max P2P chan)
%         sst.tp = tp( : );                       % trough-to-peak (PYR long)
%         sst.pyr = classify_waveform( [ sst.fmax sst.tp ] ); % logical vector for pyr/IN classification
        
        % call [ wide pval ] = classify_waveform( xy, ft )
%
% xy is a two column vector:
%   first column peak frequency of the spike spectrum (Hz)
%   second column trough-peak time (ms)
%   both are for unfiltered waveforms
%   classification is by a linear separatrix
%
% alternatively, if ft = 0, then
%   first column is the trough-peak time (ms)
%   second column is the spike width (1/freq*1000)
%   then classification is by GMM and a p-value is assigned
%
% the two methods have about 99% correspondence
        
        Type1 = classify_waveform( [ fmax TtoPdur ] ); % logical vector for pyr/IN classification
        
        SpkW = 1/fmax*1000;
        [ Type2 pval ]= classify_waveform( [ TtoPdur SpkW] , 0 );
        
        
        
        
        end