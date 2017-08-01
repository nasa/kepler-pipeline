function [thrusterFiringDataStruct, thrusterFiringEvents] = process_K2_thruster_firing_data(inputsStruct)
%==========================================================================
% The main purpose of this code is to parse the thruster firing data, which
% is sampled every 8 (or 16 seconds) to provide cadence-by-cadence
% information, for short or long cadence K2 data.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

% The primary output is the struct thrusterFiringEvents, with flags
% indicating definite and possible thruster firing events in each cadence
% See descriptions under Outputs, Part I, below.

% The secondary output is the struct thrusterFiringDataStruct, which 
% reports the presence and cumulative firing time for a the standard
% thruster firing patterns named fineTweak1, fineTweak2, mamaBearTweak1,
% mamaBearTweak2, and resatTweak. See descriptions under Outputs, Part II,
% below.

% Detailed comments interspersed in the code below serve to document the
% algorithms that have been used to determined the flags and other data
% fields.

%==========================================================================
% Inputs:
%   inputsStruct from either PA or PDC
%   From inputsStruct, we use only three fields:
%       inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct
%       inputsStruct.ancillaryEngineeringDataStruct, and
%       inputsStruct.cadenceTimes

%==========================================================================
% Outputs, Part I
%   To be persisted by JAVA side in PA only:
%   outputsStruct.thrusterFiringEvents struct, with fields
%   definiteThrusterActivityIndicators [logical]
%       Indicates, for each cadence, whether or not a thruster definitely fired
%   possibleThrusterActivityIndicators [logical]
%       Indicates, for each cadence, whether
%       or not it is possible that a thruster *could* have fired during
%       each cadence, given that definiteThrusterActivityIndicators is
%       false

%   Note: 
%       At a cadence for which definiteThrusterActivityIndicators is false,
%       possibleThrusterActivityIndicators could be either true or false.
%       If definiteThrusterActivityIndicators is true for a cadence, then
%       by definition, possibleThrusterActivityIndicators is false for that
%       cadence.

%==========================================================================
% Outputs, Part II
%   To be used within PDC and possibly PA :
%   thrusterFiringDataStruct -- thruster firing information during long (or
%   short) cadences;
%   thrusterFiringDataStruct is a struct with fields
%   thrusterFiringFlag: [921x8 double]
%       There is one column for each thruster
%       Each column provides a time series of values of 1 or 0 indicating
%       whether or not the corresponding thruster fired during that
%       cadence.
%   thrusterFiringDuration: [921x8 double]
%       There is one column for each thruster
%       Each column provides a time series of values indicating
%       the cumulative firing time for the corresponding thruster, in
%       seconds, up to the current cadence.
%   fineTweak1Flag: [921x1 double]
%       Provides a time series of values of 1 or 0 indicating
%       whether or not the "fine tweak1" thruster firing pattern occrred
%       during that cadence.
%   fineTweak1Duration: [921x1 double]
%       Provides a time series of values indicating
%       the cumulative "fine tweak1" duration in seconds, 
%       up to the current cadence.
%   fineTweak2Flag: [921x1 double]
%       Provides a time series of values of 1 or 0 indicating
%       whether or not the "fine tweak2" thruster firing pattern occrred
%       during that cadence.
%   fineTweak2Duration: [921x1 double]
%       Provides a time series of values indicating
%       the cumulative "fine tweak2" duration in seconds,
%       up to the current cadence.
%   mamaBearTweak1Flag: [921x1 double]
%       Provides a time series of values of 1 or 0 indicating
%       whether or not the "mama bear tweak1" thruster firing pattern occrred
%       during that cadence.
%   mamaBearTweak1Duration: [921x1 double]
%       Provides a time series of values indicating
%       the cumulative "mama bear tweak1" duration in seconds,
%       up to the current cadence.
%   mamaBearTweak2Flag: [921x1 double]
%       Provides a time series of values of 1 or 0 indicating
%       whether or not the "mama bear tweak2" thruster firing pattern occrred
%       during that cadence.
%   mamaBearTweak2Duration: [921x1 double]
%       Provides a time series of values indicating
%       the cumulative "mama bear tweak2" duration in seconds,
%       up to the current cadence.
%   resatTweakFlag: [921x1 double]
%       Provides a time series of values of 1 or 0 indicating
%       whether or not the "resat tweak" thruster firing pattern occrred
%       during that cadence.
%   resatTweakDuration: [921x1 double]
%       Provides a time series of values indicating
%       the cumulative "resat tweak" duration in seconds,
%       up to the current cadence.
%   unknownTweakFlag: [921x1 double]
%       Provides a time series of values of 1 or 0 indicating
%       whether or not a thruster firing pattern different from fine, mama
%       bear, and resat occurred during that cadence.
%   possibleThrusterActivityIndicators: [921x1 logical]
%       Indicates, for each cadence, whether
%       or not it is possible that a thruster *could* have fired during
%       each cadence, given that definiteThrusterActivityIndicators is
%       false

%   Note: all output fields have a length in cadences corresponding to the
%   length of inputsStruct.cadenceTimes

%==========================================================================
% Reference KSOC-3991 & KSOC-4186 (JAVA side) and KSOC-3952 (MATLAB)
% (1) Modify test function to read thruster firing data from PA or PDC
%      inputsStruct, as per KSOC-4186 -- DONE
% (2) Synchronize to long (or short) cadences -- DONE
% (3) Flag cadences when thruster firings occur and identify the type of
%       adjustment, for use within PA and PDC -- DONE
% (4) Make possibleThrusterActivityIndicators -- DONE
% (5) Create thrusterFiringDataStruct, to be used in PDC and/or PA -- DONE
% (6) Create thrusterFiringEvents struct, with fields definiteThrusterActivityIndicators [logical],
%     (indicating that at least one thruster is known to have fired),
%     and possibleThrusterActivityIndicators [logical],
%     (indicating that a thruster possibly fired) for each cadence.
%     Currently thrusterFiringEvents struct is created only if PA is
%     processing K2 data. This struct is to be persisted in PA by the JAVA side.
%     side as specified in KSOC-4186 -- DONE
% (7) In PA call this function, then tack on thrusterFiringEvents to
%     paResultsStruct -- DONE
% (8) In PDC call this function from pdcInputClass (but don't need thrusterFiringEvents in output) and tack on
%     thrusterFiringDataStruct to the pdcDataObject -- DONE
% (9) Check that the fields in thrusterFiringDataStruct are
%     calculated correctly -- DONE
% (10) Commit final version to svn -- DONE
% (11) Document steps in KSOC-3952 -- DONE
% (12) Close KSOC-3952 -- DONE
% (13) Reopen KSOC-4685. Modify code to accept
%      the module parameter thrusterFiringDataCadenceSeconds and use it to
%      test for presence of thruster samples in a cadence. 
%      -- DONE. Closed KSOC-4685.

%==============================
% Initialize thrusterFiringDataStruct
thrusterFiringDataStruct = struct('thrusterFiringFlag',[],...
    'thrusterFiringDuration',[],...
    'fineTweak1Flag',[],'fineTweak1Duration',[],...
    'fineTweak2Flag',[],'fineTweak2Duration',[],...
    'mamaBearTweak1Flag',[],'mamaBearTweak1Duration',[],...
    'mamaBearTweak2Flag',[],'mamaBearTweak2Duration',[],...
    'resatTweakFlag',[],'resatTweakDuration',[],...
    'unknownTweakFlag',[],'possibleThrusterActivityIndicators',[]);

% Initialize thrusterActivityIndicatorAlgorithm: 'original' or 'corrected'
% Hardwired to 'corrected' now.
thrusterActivityIndicatorAlgorithm = 'corrected';

% Initialize thrusterFiringEvents
thrusterFiringEvents = struct('definiteThrusterActivityIndicators',[],'possibleThrusterActivityIndicators',[]);

% 1. Get the thruster-firing data from the inputsStruct, provided by JAVA
% side
% !!!!! Switch for option to test code using thrusterFiringTable from C0 part2;
% After testing phase, switch will ultimately be hardwired to false (or
% removed altogether)
testUsingThrusterFiringTable = false; % Hardwired to false. Do not change.
plotThrusterFiringData = true;
fprintf('Processing thruster firing data...\n');
switch testUsingThrusterFiringTable
    case true
        
        % Read the long cadence data from the thruster firing report.
        isK2DataPresent = true;
        if(isK2DataPresent)
            
            % Set the location of the thruster firing data table
            dataDir = '/codesaver/work/thruster_firing_data/';
            tableFile = strcat(dataDir,'kplr2014150221515_tfr.txt');
            % The thruster firing table has nine columns.
            % The first column is the MJD
            % The second throught ninth columns give the duration in seconds
            % for firing of thrusters 1 - 8
            % SPACECRAFT_TIME (MJD)
            % KP ADTHR1CNTNIC (sec)
            % KP ADTHR2CNTNIC (sec)
            % KP ADTHR3CNTNIC (sec)
            % KP ADTHR4CNTNIC (sec)
            % KP ADTHR5CNTNIC (sec)
            % KP ADTHR6CNTNIC (sec)
            % KP ADTHR7CNTNIC (sec)
            % KP ADTHR8CNTNIC (sec)
            % Start at (zero-based) row 2, column 0,
            % skipping the two-line header describing the columns
            thrusterTable = csvread(tableFile,2,0);
            nThrusters = 8;
            
            % Reorganize the data into a struct
            thrusterFiringInputStruct = struct('timestamps',[],'deltaDurationSec',[]);
            thrusterFiringInputStruct.timestamps = thrusterTable(:,1);
            thrusterFiringInputStruct.deltaDurationSec = repmat(struct('values',[]),1,nThrusters);
            for iThruster = 1:nThrusters
                thrusterFiringInputStruct.deltaDurationSec(iThruster).values = thrusterTable(:,iThruster+1);
            end
            
            % Get the thruster firing timestamps
            thrusterFiringTimeStamps = thrusterFiringInputStruct.timestamps;
            
        else
            % Exit and return empty structs
            return
            
        end
        
    case false
        
        % Get thruster firing data from inputsStruct in PA or PDC
        % inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct
        % has fields 'mnemonics', 'modelOrders', 'quantizationLevels',
        % 'intrinsicUncertainties', and 'interactions'; here we will use only the 'mnemonics'
        % field, which is a cell array of strings with the names of the
        % thruster data elements if this is K2 data;
        % the 'mnemonics' field will be empty for K prime data
        
        % Test whether K2 data is present
        isK2DataPresent = ~isempty(inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct.mnemonics);
        % If we have K2 data, re-organize the thruster firing data
        % If we have K prime data, return output structs with empty values
        % Actually, this function should never even be called from PDC or
        % PA in the case of K prime data; a successful test for K2 data should be done
        % before this function is called.
        if(isK2DataPresent)
            % Thruster mnemonics
            thrusterMnemonics = inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct.mnemonics;
            
            % Number of thrusters
            nThrusters = length(thrusterMnemonics);
            
            % The thruster firing data will be stored (by the JAVA side) in
            % inputsStruct.ancillaryEngineeringDataStruct,
            % which has fields that are named according to the mnemonics
            % (which will include other mnemonics besides
            % thruster mnemonics). Each mnemonic field has subfields
            % timestamps [double], and values [single]
            % But note that the timestamps field derives from the first column
            % of the raw thruster table; there is not a timestamps field for each
            % thruster.
            if(isfield(inputsStruct,'ancillaryEngineeringDataStruct'))
                
                % Build a thrusterFiringInputStruct to contain re-organized thruster firing
                % data from the inputsStruct
                thrusterFiringInputStruct = struct('timestamps',[],'deltaDurationSec',[]);
                thrusterFiringInputStruct.deltaDurationSec = repmat(struct('values',[]),1,nThrusters);
                
                % Populate the thrusterFiringInputStruct with the re-organized thruster firing data
                % from the inputsStruct
                for iThruster = 1:nThrusters
                    thrusterMnemonic = thrusterMnemonics{iThruster};
                    
                    % Loop through the values in inputsStruct.ancillaryEngineeringDataStruct(:).mnemonic
                    % to find the index of the mnemonic value that matches thrusterMnemonic
                    iMnemonic = [];
                    for iArray = 1:length(inputsStruct.ancillaryEngineeringDataStruct)
                        % Is there a match?
                        if(strcmp(thrusterMnemonic,inputsStruct.ancillaryEngineeringDataStruct(iArray).mnemonic))
                            % Success!
                            iMnemonic = iArray;
                        end
                    end
                    
                    % Throw error if no matching mnemonic was found
                    assert(~isempty(iMnemonic),'No matching mnemonic for %s was found in inputsStruct.ancillaryEngineeringDataStruct(:).mnemonic\n',thrusterMnemonic)
                    
                    % Get the thruster data values
                    thrusterFiringInputStruct.deltaDurationSec(iThruster).values = ...
                        inputsStruct.ancillaryEngineeringDataStruct(iMnemonic).values;
                end
                
                % Get the thruster firing timestamps from the first thruster
                % Note -- timestamps are the same for each thruster
                thrusterFiringInputStruct.timestamps = inputsStruct.ancillaryEngineeringDataStruct(iMnemonic).timestamps;
                thrusterFiringTimeStamps = thrusterFiringInputStruct.timestamps;
                
            else
                error('dataCheck:missingAncillaryEngineeringDataStruct','no ancillaryEngineeringDataStruct field in inputsStruct')
            end
        else
            
            % Exit and return empty structs
            return
            
        end
end

%==========================================================================
% 2. Get cadence times for the long cadence (or short cadence) flux data

% Test: use with specific taskfiles corresponding to
% thrusterFiringTable
if(testUsingThrusterFiringTable)
    
    % Option to test with either (1) a specific PA input data set,
    % or (2) test with the supplied inputsStruct
    testOption = 2;
    switch testOption
        case 1
            % Use test case input data instead of the supplied inputsStruct
            
            % Corresponding K2 data from Campaign 0, part2 -- cf. KSOP-2020
            K2PaTaskFilesDir = '/path/to/ksop-2020-c0-part2/pa/';
            
            % Choose data by modout
            copyfile([K2PaTaskFilesDir,'/pa-matlab-269-5782/g-0/st-0/pa-inputs-0.mat'],'.')
            load('pa-inputs-0.mat')
            
        case 2
            % Use the supplied inputsStruct
    end
end

% Long or short cadence Time Stamps
cadenceTimes = inputsStruct.cadenceTimes;

% Start and End times for cadence data
cadenceDataStartTime = cadenceTimes.startTimestamps(1);
cadenceDataEndTime = cadenceTimes.endTimestamps(end);

% NOTE: Timestamps of start and end of flux observations
% are set to zero inside data gaps
% Create gap-filled timestamps
[gapFilledCadenceStartTimeStamps, ~, gapFilledCadenceEndTimeStamps] = ...
    pdc_fill_start_mid_end_cadence_times (cadenceTimes);
nCadences = length(gapFilledCadenceStartTimeStamps);

%==========================================================================
% 3. Identify the portion of thruster firing data that overlaps
%    long-cadence (or short-cadence) flux data

% Identify the section of the Thruster Firing (TF) data that spans the long cadence (LC) or short cadence (SC) data,
% That is: from the closest TF timestamp after or at the start of LC (or SC) data to the closest TF
% timestamp before or at the end of LC (or SC) data.
thrusterFiringTimeIsDuringCadenceData = (thrusterFiringTimeStamps>=cadenceDataStartTime)&(thrusterFiringTimeStamps<=cadenceDataEndTime);

% TF times spanning the cadence data
thrusterFiringOverlapTimes = thrusterFiringTimeStamps(thrusterFiringTimeIsDuringCadenceData);
nOverlapTimes = length(thrusterFiringOverlapTimes);

% Truncate thrusterFiringInputStruct to the TF times spanning the cadence data
% Note: The variable name thrusterDeltaDurationSec is misleading and should really be
% thrusterCumulativeDurationSec: it represents the total amount of time in seconds that the
% thrusters have fired up to the current timestamp.  It's too late to change the
% name now, because it is used in the output struct.
thrusterDeltaDurationSec = zeros(nOverlapTimes,nThrusters);
for iThruster = 1:nThrusters
    values = thrusterFiringInputStruct.deltaDurationSec(iThruster).values;
    thrusterDeltaDurationSec(:,iThruster) = values(thrusterFiringTimeIsDuringCadenceData);
end

%=========================================================================
% 4. Plot overlapping thruster telemetry
if(plotThrusterFiringData)
    figure;
    hold on
    plot(thrusterDeltaDurationSec(:,1),'k-')
    plot(thrusterDeltaDurationSec(:,2),'r-')
    plot(thrusterDeltaDurationSec(:,3),'b-')
    plot(thrusterDeltaDurationSec(:,4),'g-')
    plot(thrusterDeltaDurationSec(:,5),'m-')
    plot(thrusterDeltaDurationSec(:,6),'k-.')
    plot(thrusterDeltaDurationSec(:,7),'r-.')
    plot(thrusterDeltaDurationSec(:,8),'b-.')
    xlabel('sample number')
    ylabel('Cumulative thruster firing time, seconds')
    title('Thruster firing data')
    legend('T1','T2','T3','T4','T5','T6','T7','T8','Location','NorthEast')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12);
    saveas(gcf, 'rawThrusterFiringTimeSeries', 'fig');
    saveas(gcf, 'rawThrusterFiringTimeSeries', 'png');
    close(gcf);
end
%==========================================================================
% 5. Look for patterns. Form duration differences to detect thruster firing times
% Note that the timestamps for the differences are advanced by one cadence
% relative to the thruster
thrusterFiringDurationTmpRaw = diff(thrusterDeltaDurationSec);
% Prepend  a row of zeros to the differences to sync with thruster data sampling times
% thrusterFiringDurationRaw is interpreted as the thruster firing duration relative to the
% previous sample, with the first entry defined to be zero.
thrusterFiringDurationRaw = [zeros(1,nThrusters);thrusterFiringDurationTmpRaw];

% Indicator for whether each thruster fired relative to the previous sample
thrusterFiringIndicatorRaw = thrusterFiringDurationRaw>0;

% Count the total number of thrusters that fired during each sample
thrusterFiringSum = sum(thrusterFiringIndicatorRaw,2);

%==========================================================================
% 6. Identify events related to known (and unknown) thruster firing patterns: get indicators and
% durations

% fineTweak1 pattern: thrusters 1, 2
fineTweak1IndicatorRaw = ...
    thrusterFiringIndicatorRaw(:,1)&...
    thrusterFiringIndicatorRaw(:,2)&...
    ~thrusterFiringIndicatorRaw(:,3)&...
    ~thrusterFiringIndicatorRaw(:,4)&...
    ~thrusterFiringIndicatorRaw(:,5)&...
    ~thrusterFiringIndicatorRaw(:,6)&...
    ~thrusterFiringIndicatorRaw(:,7)&...
    ~thrusterFiringIndicatorRaw(:,8);

% fineTweak2 pattern: thrusters 3, 4
fineTweak2IndicatorRaw = ...
    thrusterFiringIndicatorRaw(:,3)&...
    thrusterFiringIndicatorRaw(:,4)&...
    ~thrusterFiringIndicatorRaw(:,1)&...
    ~thrusterFiringIndicatorRaw(:,2)&...
    ~thrusterFiringIndicatorRaw(:,5)&...
    ~thrusterFiringIndicatorRaw(:,6)&...
    ~thrusterFiringIndicatorRaw(:,7)&...
    ~thrusterFiringIndicatorRaw(:,8);

% mamaBearTweak1 pattern: thrusters 3, 6
mamaBearTweak1IndicatorRaw = ...
    thrusterFiringIndicatorRaw(:,3)&...
    thrusterFiringIndicatorRaw(:,6)&...
    ~thrusterFiringIndicatorRaw(:,1)&...
    ~thrusterFiringIndicatorRaw(:,2)&...
    ~thrusterFiringIndicatorRaw(:,4)&...
    ~thrusterFiringIndicatorRaw(:,5)&...
    ~thrusterFiringIndicatorRaw(:,7)&...
    ~thrusterFiringIndicatorRaw(:,8);

% mamaBearTweak2 pattern: thrusters 2, 7
mamaBearTweak2IndicatorRaw = ...
    thrusterFiringIndicatorRaw(:,2)&...
    thrusterFiringIndicatorRaw(:,7)&...
    ~thrusterFiringIndicatorRaw(:,1)&...
    ~thrusterFiringIndicatorRaw(:,3)&...
    ~thrusterFiringIndicatorRaw(:,4)&...
    ~thrusterFiringIndicatorRaw(:,5)&...
    ~thrusterFiringIndicatorRaw(:,6)&...
    ~thrusterFiringIndicatorRaw(:,8);

% resat pattern: 2, 3, 5, 8
resatTweakIndicatorRaw = ...
    thrusterFiringIndicatorRaw(:,2)&...
    thrusterFiringIndicatorRaw(:,3)&...
    thrusterFiringIndicatorRaw(:,5)&...
    thrusterFiringIndicatorRaw(:,8)&...
    ~thrusterFiringIndicatorRaw(:,1)&...
    ~thrusterFiringIndicatorRaw(:,4)&...
    ~thrusterFiringIndicatorRaw(:,6)&...
    ~thrusterFiringIndicatorRaw(:,7);

% Unknown tweak indicator: if some combination of thrusters has fired, but
% not one of the known patterns listed above
unknownTweakIndicatorRaw = thrusterFiringSum>0&...
    ~fineTweak1IndicatorRaw&...
    ~fineTweak2IndicatorRaw&...
    ~mamaBearTweak1IndicatorRaw&...
    ~mamaBearTweak2IndicatorRaw&...
    ~resatTweakIndicatorRaw;

%==========================================================================
% 7. Sync to short or long cadence data and generate PA/PDC data product
% for each cadence

% thrusterFiringFlag indicates whether each thruster fired during a cadence
% thrusterFiringDuration accumulates firing duration for each thruster
thrusterFiringFlag = zeros(nCadences,nThrusters);
thrusterFiringDuration = zeros(nCadences,nThrusters);
thrusterFiringNumberOfEvents= zeros(nCadences,nThrusters);

% Flags and durations for known and unknown tweak patterns
fineTweak1Flag = zeros(nCadences,1);
fineTweak1Duration = zeros(nCadences,1);
fineTweak2Flag = zeros(nCadences,1);
fineTweak2Duration = zeros(nCadences,1);
mamaBearTweak1Flag = zeros(nCadences,1);
mamaBearTweak1Duration = zeros(nCadences,1);
mamaBearTweak2Flag = zeros(nCadences,1);
mamaBearTweak2Duration = zeros(nCadences,1);
resatTweakFlag = zeros(nCadences,1);
resatTweakDuration = zeros(nCadences,1);
unknownTweakFlag = zeros(nCadences,1);
possibleThrusterActivityIndicators = false(nCadences,1);
definiteThrusterActivityIndicators = false(nCadences,1);

% NOTE: Maximum acceptable gap between thruster firing samples and
% cadence data start and end times. This is based on median of gaps between
% thruster firing samples of 8.0352 sec, from K2 Campaign 0, part 2
% thrusterFiringTable. Only 24 out of 415974 timestamps had next timestamp
% more than 8.04 sec later, and these were in the range of 10 - 16 sec
% NOTE: for C1 thruster data it is found that of 858077 thruster sample
% time differences, 36 were < 7.94 sec and 18 were > 8.04 sec.
% So 8.04 sec is a reasonable maximum expected sample time difference
% NOTE: thruster firing data is collected at 8 second cadence in C0, C1 and
% C2, while it is collected at 16 second cadence in all other campaigns
% This cadence interval is now captured in a module parameter called thrusterFiringDataCadenceSeconds
% which is a field in
% inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct, whether
% this code is running on PA data or PDC data.
% maxThrusterSampleTimeDiffSec = 8 sec for C0 and C1, 16 sec for C2 and
% later
% Add a margin of 0.1 seconds
maxThrusterSampleTimeDiffSec = inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct.thrusterFiringDataCadenceSeconds + 0.1;
secondsPerDay = 24*3600;
maxThrusterSampleTimeDiffDays = maxThrusterSampleTimeDiffSec/secondsPerDay;

% Loop over cadences and set
% thrusterFiringNumberOfEvents
% thrusterFiringFlag
% thrusterFiringDuration
% fineTweak1Flag
% fineTweak1Duration
% fineTweak2Flag
% fineTweak2Duration
% mamaBearTweak1Flag
% mamaBearTweak1Duration
% mamaBearTweak2Flag
% mamaBearTweak2Duration
% resatTweakFlag
% resatTweakDuration
% unknownTweakFlag
% possibleThrusterActivityIndicators (for thruster firing data during this cadence)

for iCadence = 1:nCadences
    
    % Start and end times for this cadence (in days)
    thisCadenceStartTime = gapFilledCadenceStartTimeStamps(iCadence);
    thisCadenceEndTime = gapFilledCadenceEndTimeStamps(iCadence);
    
    % Index for thruster samples that occurred during this cadence
    thrusterSampleIsInThisCadenceIdx = thrusterFiringOverlapTimes >= thisCadenceStartTime & thrusterFiringOverlapTimes <= thisCadenceEndTime;
    
    % Identify times within this cadence at which there are thruster firing
    % telemetry samples
    thrusterSampleTimesInThisCadence = thrusterFiringOverlapTimes(thrusterSampleIsInThisCadenceIdx);
    
    % Sum of thruster firing events for each thruster that occurred during this cadence
    thrusterFiringNumberOfEvents(iCadence,:) = sum(thrusterFiringIndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1);
    
    % Logical flags indicate whether each thruster fired during this cadence
    thrusterFiringFlag(iCadence,:) = thrusterFiringNumberOfEvents(iCadence,:) > 0;

    % Total thruster firing durations during this cadence
    
    % Index each sample in this cadence for which the thruster
    % firing duration relative to the previous sample is nonzero
    idx = thrusterSampleIsInThisCadenceIdx&any(thrusterFiringIndicatorRaw,2);
    totalDurationsThisCadence = sum(thrusterFiringDurationRaw(idx,:),1);
    thrusterFiringDuration(iCadence,:) = totalDurationsThisCadence;    
    
    % Get cumulative thruster firing duration information from previous, next, and current cadences
    % (1) Last cumulative thruster firing duration vector
    %     (thrusterDeltaDurationSec) from the previous cadence
    % (2) First cumulative thruster firing duration vector
    %     from the next cadence
    % (3) First cumulative thruster firing duration vector from this
    %     cadence
    % (4) Last cumulative thruster firing duration vector from this cadence
    
    % Previous cadence
    if(iCadence > 1)
        
        % End time for previous cadence (in days)
        previousCadenceStartTime = gapFilledCadenceStartTimeStamps(iCadence-1);
        previousCadenceEndTime = gapFilledCadenceEndTimeStamps(iCadence-1);
        
        % Last cumulative thruster firing duration vector during previous cadence
        previousCadenceOverlapTimes = thrusterFiringOverlapTimes( ...
            thrusterFiringOverlapTimes >= previousCadenceStartTime & ...
            thrusterFiringOverlapTimes <= previousCadenceEndTime);
        % Deal with corner case of no overlap times in previous cadence 
        if(~isempty(previousCadenceOverlapTimes))
            cumulativeThrusterFiringDurationAtEndOfPreviousCadence = thrusterDeltaDurationSec(thrusterFiringOverlapTimes == max(previousCadenceOverlapTimes),:);
        else
            cumulativeThrusterFiringDurationAtEndOfPreviousCadence = NaN;
        end
        
    end % previous cadence
    
    % Next cadence
    if(iCadence < nCadences)
                
        % Start time for next cadence (in days)
        nextCadenceStartTime = gapFilledCadenceStartTimeStamps(iCadence+1);
        nextCadenceEndTime = gapFilledCadenceEndTimeStamps(iCadence+1);
               
        % First cumulative thruster firing duration vector during next cadence
        nextCadenceOverlapTimes = thrusterFiringOverlapTimes( ...
            thrusterFiringOverlapTimes >= nextCadenceStartTime & ...
            thrusterFiringOverlapTimes <= nextCadenceEndTime);
        % Deal with corner case of no overlap times in next cadence 
        if(~isempty(nextCadenceOverlapTimes))
            cumulativeThrusterFiringDurationAtStartOfNextCadence = thrusterDeltaDurationSec(thrusterFiringOverlapTimes == min(nextCadenceOverlapTimes),:);
        else
            cumulativeThrusterFiringDurationAtStartOfNextCadence = NaN;
        end
        
    end % next cadence
    
    % First and last cumulative thruster firing duration vectors for this cadence
    % Deal with corner case of no overlap times in this cadence
    thisCadenceOverlapTimes = thrusterFiringOverlapTimes(thrusterSampleIsInThisCadenceIdx);
    if(~isempty(thisCadenceOverlapTimes))
        cumulativeThrusterFiringDurationAtStartOfThisCadence = thrusterDeltaDurationSec(thrusterFiringOverlapTimes == min(thisCadenceOverlapTimes),:);
        cumulativeThrusterFiringDurationAtEndOfThisCadence = thrusterDeltaDurationSec(thrusterFiringOverlapTimes == max(thisCadenceOverlapTimes),:);
    else
        % If there is no thruster firing telemetry during this cadence,
        % then we do not know, so signal this by a NaN value.
        cumulativeThrusterFiringDurationAtStartOfThisCadence = NaN;
        cumulativeThrusterFiringDurationAtEndOfThisCadence = NaN;
    end
    
    %======================================================================
    % Part I. Set thruster firing flags
    
    switch thrusterActivityIndicatorAlgorithm
        
        case 'original'
                        
            % definiteThrusterActivityIndicators
            definiteThrusterActivityIndicators(iCadence)  = any(thrusterFiringFlag(iCadence,:));
            
            % possibleThrusterActivityIndicators
            % If the first and last thruster firing telemetry samples in this
            % cadence are not BOTH within maxThrusterSampleTimeDiffDays of the
            % cadence boundary, then we *provisionally* set possibleThrusterActivityIndicators
            % to 'true' for this cadence. 
            if( (thrusterSampleTimesInThisCadence(1) - thisCadenceStartTime > maxThrusterSampleTimeDiffDays) || ...
                (thisCadenceEndTime - thrusterSampleTimesInThisCadence(end) > maxThrusterSampleTimeDiffDays) )
                possibleThrusterActivityIndicators(iCadence) = true;
            end
            % NOTE: We want possibleThrusterActivityIndicators == true to mean that we cannot determine
            % unequivocally if thrusters fired during this cadence. Therefore, if
            % definiteThrusterActivityIndicators is true, possibleThrusterActivityIndicators must be false.
            % We enforce that condition later in the code.
            
        case 'corrected'
            
            % =============================================================
            % Simplified algorithm to set thruster firing flags -- see
            % KSOC-4690
            
            % After closely reading the code, I find that a much cleaner algorithm
            % than the one described in KSOC-4734 can be used to set the flags, 
            % by directly using the cumulative thruster firing time
            % telemetry instead of relying on intermediate indicators and other variables
            % that I created in the code. With the new algorithm, we do not even need
            % to use the module parameter
            % thrusterDataAncillaryEngineeringConfigurationStruct.thrusterFiringDataCadenceSeconds.
            
            % Pseudocode for the simplified algorithm:
            
            % 1. definiteThrusterActivityIndicators:
            
            %    If the cumulative thruster firing times telemetry shows an increase for
            %    *any* of the thrusters during a cadence, set definiteThrusterActivityIndicators to 'true'
            
            % 2. possibleThrusterActivityIndicators:
            
            %     A. For the first (last) cadence:
            %         If the first thruster telemetry sample timestamp is later than the start of the first cadence
            %         (last thruster telemetery sample timestamp is earlier than the end of the last cadence)
            %         then we can't rule out the possibility that thrusters fired before the first (after the last)
            %         thruster sample.
            %         Therefore we *provisionally* set possibleThrusterActivityIndicators to 'true'
            
            %     B. If a thruster fired between the last sample of this cadence and the first sample of the
            %          next cadence, then *provisionally* set possibleThrusterActivityIndicators to 'true'
            %          for this cadence and the next cadence.
            
            %     C. If a thruster fired between the last sample of the previous cadence and the first sample
            %          of this cadence, then *provisionally* set possibleThrusterActivityIndicators to 'true' for
            %          this cadence and the previous cadence.
            
            %     D. Finalize the *provisional* determination of possibleThrusterActivityIndicators:
            %          possibleThrusterActivityIndicators true means that we cannot determine for
            %          sure if thrusters fired during this cadence.
            %          Therefore, for any cadence in which definiteThrusterActivityIndicators is true, 
            %          possibleThrusterActivityIndicators is set to 'false'.
            
            %==============================================================
            % Implementation of the algorithm to set thruster activity
            % indicators
            
            % 1. Set definiteThrusterActivityIndicators if the cumulative
            % thruster firing times telemetry shows an increase for *any*
            % thruster during this cadence.
            % Corner case:
            % If cumulativeThrusterFiringDurationAtStartOfThisCadence is NaN
            % (unknown) then definiteThrusterActivityIndicators will be set
            % to false for this cadence.
            definiteThrusterActivityIndicators(iCadence)  = any(cumulativeThrusterFiringDurationAtStartOfThisCadence < cumulativeThrusterFiringDurationAtEndOfThisCadence);
            
            % 2A. For the first (last) cadence:
            %    If the first thruster telemetry sample timestamp is *after* the start of the first cadence
            %    (last thruster telemetery sample timestamp is *before* the end of the last cadence) 
            %    then we can't rule out the possibility that thrusters fired before the first (after the last)
            %    thruster sample, therefore we *provisionally* set
            %    possibleThrusterActivityIndicators to true.
            if( isempty(thisCadenceOverlapTimes) )
                possibleThrusterActivityIndicators(iCadence) = true;
            elseif( iCadence == 1 && thisCadenceOverlapTimes(1) > thisCadenceStartTime )
                possibleThrusterActivityIndicators(iCadence) = true;
            elseif( iCadence == nCadences && thisCadenceOverlapTimes(end) < thisCadenceEndTime  )
                possibleThrusterActivityIndicators(iCadence) = true;
            end
            
            % 2B. If a thruster fired between the last sample of this cadence
            % and the first sample of the next cadence,
            % or if we don't know because there was no thruster firing
            % telemetry in the next cadence,
            % then *provisionally* set possibleThrusterActivityIndicators to
            % true for this cadence and the next cadence
           if(iCadence < nCadences)
                if( any( isnan(cumulativeThrusterFiringDurationAtStartOfNextCadence) ) || ... 
                        any( cumulativeThrusterFiringDurationAtEndOfThisCadence < cumulativeThrusterFiringDurationAtStartOfNextCadence ) )
                    possibleThrusterActivityIndicators(iCadence) = true;
                    possibleThrusterActivityIndicators(iCadence+1) = true;
                end 
            end
            
            % 2C. If a thruster fired between the last sample of the
            % previous cadence and the first sample of this cadence,
            % or if we don't know because there was no thruster firing
            % telemetry in the previous cadence
            % then *provisionally* set possibleThrusterActivityIndicators to
            % true for this cadence and the previous cadence
            if(iCadence > 1)
                if( any( isnan(cumulativeThrusterFiringDurationAtEndOfPreviousCadence) ) ||... 
                        any(cumulativeThrusterFiringDurationAtEndOfPreviousCadence < cumulativeThrusterFiringDurationAtStartOfThisCadence))
                    possibleThrusterActivityIndicators(iCadence) = true;
                    possibleThrusterActivityIndicators(iCadence-1) = true;
                end
            end
            
            % See section 2D (below) where the *provisional* setting is
            % finalized, if necessary, after the loop is completed. 
                    
    end % switch
    
    %======================================================================
    % Part II. Compute fields for thrusterFiringDataStruct
    
    % A. fineTweak1Flag and fineTweak1Duration
    
    % Flag indicates whether fineTweak1 events occurred during this cadence
    fineTweak1Flag(iCadence,:) = sum(fineTweak1IndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1)>0;
    
    % Total fineTweak1 duration during this cadence
    fineTweak1Duration(iCadence,:) = sum(thrusterFiringDurationRaw...
        (thrusterSampleIsInThisCadenceIdx&fineTweak1IndicatorRaw,1),1);
    
    % B. fineTweak2Flag and fineTweak2Duration
    
    % Flag indicates whether fineTweak1 events occurred during this cadence
    fineTweak2Flag(iCadence,:) = sum(fineTweak2IndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1)>0;
    
    % Total fineTweak1 duration during this cadence
    fineTweak2Duration(iCadence,:) = sum(thrusterFiringDurationRaw...
        (thrusterSampleIsInThisCadenceIdx&fineTweak2IndicatorRaw,3),1);
    
    % C. mamaBearTweak1Flag and mamaBearTweak1Duration
    
    % Flag indicates whether mamaBearTweak1 events occurred during this cadence
    mamaBearTweak1Flag(iCadence,:) = sum(mamaBearTweak1IndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1)>0;
    
    % Total mamaBearTweak1 duration during this cadence
    mamaBearTweak1Duration(iCadence,:) = sum(thrusterFiringDurationRaw...
        (thrusterSampleIsInThisCadenceIdx&mamaBearTweak1IndicatorRaw,3),1);
    
    % D. mamaBearTweak2Flag and mamaBearTweak2Duration
    
    % Flag indicates whether mamaBearTweak2 events occurred during this cadence
    mamaBearTweak2Flag(iCadence,:) = sum(mamaBearTweak2IndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1)>0;
    
    % Total mamaBearTweak2 duration during this cadence
    mamaBearTweak2Duration(iCadence,:) = sum(thrusterFiringDurationRaw...
        (thrusterSampleIsInThisCadenceIdx&mamaBearTweak2IndicatorRaw,2),1);
    
    % E. resatTweakFlag and resatTweakDuration
    
    % Flag indicates whether resatTweak events occurred during this cadence
    resatTweakFlag(iCadence,:) = sum(resatTweakIndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1)>0;
    
    % Total resatTweak duration during this cadence
    resatTweakDuration(iCadence,:) = sum(thrusterFiringDurationRaw...
        (thrusterSampleIsInThisCadenceIdx&resatTweakIndicatorRaw,2),1);
    
    % F. unknownTweakFlag 
    
    % Flag indicates whether events of unknownTweakType occurred during this cadence
    unknownTweakFlag(iCadence,:) = sum(unknownTweakIndicatorRaw(thrusterSampleIsInThisCadenceIdx,:),1)>0;
    
end

% Populate thrusterFiringEvents struct with definiteThrusterActivityIndicators [logical]
% and possibleThrusterActivityIndicators [logical] fields;
% thrusterFiringEvents is added to outputsStruct in PA and is
% persisted by JAVA side
% definiteThrusterActivityIndicators = any(thrusterFiringFlag,2);
thrusterFiringEvents.definiteThrusterActivityIndicators = definiteThrusterActivityIndicators;

% 2D. Finalize provisional determination of possibleThrusterActivityIndicators
% possibleThrusterActivityIndicators true means that we cannot determine for
% sure if thrusters fired during this cadence. Therefore, if
% definiteThrusterActivityIndicators is true, possibleThrusterActivityIndicators must be false.
possibleThrusterActivityIndicators = possibleThrusterActivityIndicators&~definiteThrusterActivityIndicators;
thrusterFiringEvents.possibleThrusterActivityIndicators = possibleThrusterActivityIndicators;

% Populate thrusterFiringDataStruct
thrusterFiringDataStruct.thrusterFiringFlag = thrusterFiringFlag;
thrusterFiringDataStruct.thrusterFiringDuration = thrusterFiringDuration;
thrusterFiringDataStruct.fineTweak1Flag =  fineTweak1Flag;
thrusterFiringDataStruct.fineTweak2Flag =  fineTweak2Flag;
thrusterFiringDataStruct.fineTweak1Duration =  fineTweak1Duration;
thrusterFiringDataStruct.fineTweak2Duration =  fineTweak2Duration;
thrusterFiringDataStruct.mamaBearTweak1Flag = mamaBearTweak1Flag;
thrusterFiringDataStruct.mamaBearTweak2Flag = mamaBearTweak2Flag;
thrusterFiringDataStruct.mamaBearTweak1Duration = mamaBearTweak1Duration;
thrusterFiringDataStruct.mamaBearTweak2Duration = mamaBearTweak2Duration;
thrusterFiringDataStruct.resatTweakFlag = resatTweakFlag;
thrusterFiringDataStruct.resatTweakDuration = resatTweakDuration;
thrusterFiringDataStruct.unknownTweakFlag = unknownTweakFlag;
thrusterFiringDataStruct.possibleThrusterActivityIndicators = possibleThrusterActivityIndicators;

% Report progress
fprintf('Finished processing thruster firing data\n');

end
