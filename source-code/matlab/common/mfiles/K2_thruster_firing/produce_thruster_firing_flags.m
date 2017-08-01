function [thrusterFiringDataStruct, thrusterFiringEvents, cadenceTimes] = produce_thruster_firing_flags(inputStruct)
% function [thrusterFiringDataStruct, thrusterFiringEvents, cadenceTimes] = produce_thruster_firing_flags(inputStruct)
%
% INPUTS:
%    inputStruct == [struct] containing the following fields:
%                         campaignIdTag == [string] tag which identifies unit of work. Typically first part of header check filename. must end with 'lc or 'sc'
%                                           e.g. 'c0-part1-lc'
%          thrusterFiringReportFilename == [string] full path and filename of thruster firing report
%                                           e.g. './kplr2015233174625_tfr.txt'
%                   headerCheckFileName == [string] full path and filename of header check file
%                                           e.g. './c0-part1-lc-header-check-140411.txt'
%      thrusterFiringDataCadenceSeconds == [int] sampling period for thruster data. C0, C1 == 8 seconds, all others 16 seconds
%    thrusterActivityIndicatorAlgorithm == [string] either 'original' or 'corrected'; default = 'corrected'
%                         produceReport == [boolean] produce csv file and save results to .mat file in run directory
%                           enablePlots == [boolean] produce plots or not and save as .fig and .png in run directory
%                                ksocId == [string], e.g. 'KSOC-5140' for C12 short cadence
%		       campaingIdString == [string], e.g. 'Campaign 12' 
%                           cadenceType == [string], e.g. 'Long', or 'Short'
%                           
%			    
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

% OUTPUTS:
%   thrusterFiringDataStruct == [struct] containing the following fields:
%                                         thrusterFiringFlag == [double array] nCadences x nThrusters
%                                     thrusterFiringDuration == [double array] nCadences x nThrusters
%                                             fineTweak1Flag == [double array] nCadences x 1
%                                         fineTweak1Duration == [double array] nCadences x 1
%                                             fineTweak2Flag == [double array] nCadences x 1
%                                         fineTweak2Duration == [double array] nCadences x 1
%                                         mamaBearTweak1Flag == [double array] nCadences x 1
%                                     mamaBearTweak1Duration == [double array] nCadences x 1
%                                         mamaBearTweak2Flag == [double array] nCadences x 1
%                                     mamaBearTweak2Duration == [double array] nCadences x 1
%                                             resatTweakFlag == [double array] nCadences x 1
%                                         resatTweakDuration == [double array] nCadences x 1
%                                           unknownTweakFlag == [double array] nCadences x 1
%                         possibleThrusterActivityIndicators == [boolean array] nCadences x 1
%                         definiteThrusterActivityIndicators == [boolean array] nCadences x 1
%
%       thrusterFiringEvents == [struct] containing the following fields:
%                         definiteThrusterActivityIndicators == [boolean array] nCadences x 1
%                         possibleThrusterActivityIndicators == [boolean array] nCadences x 1
%
%               cadenceTimes == [struct] containing the following fields:
%                                             cadenceNumbers == [int32 array] nCadences x 1
%                                            startTimestamps == [double array] nCadences x 1
%                                              endTimestamps == [double array] nCadences x 1
%

% Revision history
% 2/9/17 - Original revision
% This function is intended as a replacement for the original function process_K2_thruster_firing_data_TFR.m without the need to adjust hard coded data path and filenames for each new
% campaign. I've cleaned up the front end, sections 0, 1, 2. Removed hard coded campaignId dependent switches, data paths and filenames. These now all come in through the inputStruct.
% The back end, sections 3, 4, 5, 6, 7 remain as in the original code (so the logic that produces the output flags is unchanged). I've added section 8 (Produce report) to archive
% output in a .mat file and produce the thruster firing flags file in csv format. These files were formerly produced outside of the original function from the returned data.
% 
% 5/23/2017 -- added inputStruct fields ksocId,  campaignIdString, and cadenceType, and modified this code to add the required header lines to
%   the output .csv file
%
% See original function for development notes and revision record.
%
% Here are some notes from the original function which may be relevant:
%
% NOTE: Maximum acceptable gap between thruster firing samples and cadence data start and end times. 
% This is based on median of gaps between thruster firing samples of 8.0352 sec, from K2 Campaign 0, part 2
% thrusterFiringTable. Only 24 out of 415974 timestamps had next timestamp more than 8.04 sec later, and
% these were in the range of 10 - 16 sec NOTE: for C1 thruster data it is found that of 858077 thruster sample
% time differences, 36 were < 7.94 sec and 18 were > 8.04 sec. So 8.04 sec is a reasonable maximum expected
% sample time difference NOTE: thruster firing data is collected at 8 second cadence in C0, C1 and C2, while
% it is collected at 16 second cadence in all other campaigns. This cadence interval is captured in a module
% parameter called thrusterPeriod which is a field in inputsStruct.thrusterDataAncillaryEngineeringConfigurationStruct, whether
% this code is running on PA data or PDC data.
% maxThrusterSampleTimeDiffSec = 8 sec for C0 and C1, 16 sec for C2 and later
% Add a margin of 0.1 seconds
%
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
% Start at (zero-based) row 2, column 0, skipping the two-line header describing the columns
%
% For reference, here are the thruster firing tables (*_tfr.txt files) for some of the campaigns already run.     
%     case {'c0-part1-lc', 'c0-part2-lc', 'c0-part1-sc', 'c0-part2-sc'}
%       kplr2015233174625_tfr.txt';
%     case {'c1_part1_lc','c1_part1_sc'}
%       kplr2014199093231_tfr.txt';
%     case {'c1_part2_lc', 'c1_part2_sc'}
%       kplr14199093231_tfr.txt';
%     case {'c2_lc','c2_sc'}
%       kplr2014322213946_tfr.txt';
%     case {'C9a-LC','C9a-SC'}
%       kplr2016142190400_tfr.txt';
%     case {'C9b-LC','C9b-SC'}
%       kplr2016186113231_tfr.txt';
%     case {'C10-LC','C10-SC'}
%       kplr2016267170734_tfr.txt';
%     case {'C12-SC'}
%       kplr2017068020206_updated_20170519T002249_tfr.txt


% constants
NUM_THRUSTERS = 8;
SECONDS_PER_DAY = 24*3600;

% unpack inputs
campaignIdTag       = inputStruct.campaignIdTag;
tfrFileFull         = inputStruct.thrusterFiringReportFilename;
headerFileFull      = inputStruct.headerCheckFilename;
thrusterPeriod      = inputStruct.thrusterFiringDataCadenceSeconds;
thrusterAlgorithm   = inputStruct.thrusterActivityIndicatorAlgorithm;
produceReport       = inputStruct.produceReport;
enablePlots         = inputStruct.enablePlots;
ksocId              = inputStruct.ksocId;
campaignIdString    = inputStruct.campaignIdString;
cadenceType         = inputStruct.cadenceType;



% DO SOME INPUT CHECKING HERE ------------------------------
if ~strcmpi(campaignIdTag(end-1:end),'lc') && ~strcmpi(campaignIdTag(end-1:end),'sc')
    error('The input field "campaignIdTag" must end in "lc" or "sc"');
end
if ~exist(tfrFileFull,'file')
    error('Thruster firing report not found.');
end
if ~exist(headerFileFull,'file')
    error('Header check file not found.');
end
if ~strcmp(thrusterAlgorithm,'corrected') && ~strcmp(thrusterAlgorithm,'original')
    error('The input field "thrusterActivityIndicatorAlgorithm" must be "corrected" or "original".');
end
if thrusterPeriod ~= 8 && thrusterPeriod ~= 16
    error('Acceptable values for "thrusterFiringDataCadenceSeconds" are 8 (C0, C1) or 16 (all other campaigns)');
end

if ~( strcmp(cadenceType,'Short Cadence') || strcmp(cadenceType, 'Long Cadence') )
    error('Acceptable values for "cadenceType" are "Long Cadence" or "Short Cadence"')
end



% Initialize thrusterFiringDataStruct
thrusterFiringDataStruct = struct('thrusterFiringFlag',[],...
    'thrusterFiringDuration',[],...
    'fineTweak1Flag',[],'fineTweak1Duration',[],...
    'fineTweak2Flag',[],'fineTweak2Duration',[],...
    'mamaBearTweak1Flag',[],'mamaBearTweak1Duration',[],...
    'mamaBearTweak2Flag',[],'mamaBearTweak2Duration',[],...
    'resatTweakFlag',[],'resatTweakDuration',[],...
    'unknownTweakFlag',[],'possibleThrusterActivityIndicators',[]);

% Initialize thrusterFiringEvents
thrusterFiringEvents = struct('definiteThrusterActivityIndicators',[],'possibleThrusterActivityIndicators',[]);

% Maximum thruster sample interval
maxThrusterSampleTimeDiffSec = thrusterPeriod + 0.1;
maxThrusterSampleTimeDiffDays = maxThrusterSampleTimeDiffSec/SECONDS_PER_DAY;

% load thruster firing report table
thrusterTable = csvread(tfrFileFull,2,0);

%==========================================================================
% 1. process data from thruster firing report table

% a message!
fprintf('Processing data from the thruster firing report table ...\n');

% Reorganize the data into a struct
thrusterFiringInputStruct = struct('timestamps',[],'deltaDurationSec',[]);
thrusterFiringInputStruct.timestamps = thrusterTable(:,1);
thrusterFiringInputStruct.deltaDurationSec = repmat(struct('values',[]),1,NUM_THRUSTERS);
for iThruster = 1:NUM_THRUSTERS
    thrusterFiringInputStruct.deltaDurationSec(iThruster).values = thrusterTable(:,iThruster+1);
end

% Get the thruster firing timestamps
thrusterFiringTimeStamps = thrusterFiringInputStruct.timestamps;


%==========================================================================
% 2. Get cadence timestamps

% another message!
fprintf('Processing cadence data ...\n');

% get timestamps from header check csv file
if(strcmpi(campaignIdTag(end-1:end),'lc'))
    formatSpec = '%s%s%s%f%f%d%s%f%f%f%c%c%c%c%c%c%c';
    T = readtable(headerFileFull,'Delimiter',',','Format',formatSpec);
    cadenceNumbers = T.LC_INTER;
elseif(strcmpi(campaignIdTag(end-1:end),'sc'))
    formatSpec = '%s%s%s%f%f%d%d%s%f%f%f%c%c%c%c%c%c%c';
    T = readtable(headerFileFull,'Delimiter',',','Format',formatSpec);
    cadenceNumbers = T.SC_INTER;
end
startTimestamps = T.START_TIME;
endTimestamps = T.END_TIME;
nCadences = length(cadenceNumbers);

% Start and End times for cadence data
% Handles corner case if 1st entry in startTimestamps or the last entry in
% endTimestamps is zero
isValidStartTime = startTimestamps ~= 0;
validStartTimestamps = startTimestamps(isValidStartTime);
cadenceDataStartTime = validStartTimestamps(1);

isValidEndTime = endTimestamps ~= 0;
validEndTimestamps = endTimestamps(isValidEndTime);
cadenceDataEndTime = validEndTimestamps(end);

if any(~isValidStartTime) || any(~isValidEndTime)
    fprintf('There are data gaps, i.e. some start or end timestamps are equal to zero!!!!!\n');
end

% Timestamps to be used below
gapFilledCadenceStartTimeStamps = startTimestamps;
gapFilledCadenceEndTimeStamps   = endTimestamps;

% Populate cadenceTimes struct
cadenceTimes = struct('cadenceNumbers',[],'startTimestamps',[],'endTimestamps',[]);
cadenceTimes.cadenceNumbers     = cadenceNumbers;
cadenceTimes.startTimestamps    = startTimestamps;
cadenceTimes.endTimestamps      = endTimestamps;


%==========================================================================
% 3. Identify the portion of thruster firing data that overlaps long-cadence (or short-cadence) flux data

% Identify the section of the Thruster Firing (TF) data that spans the long cadence (LC) or short cadence (SC) data,
% That is: from the closest TF timestamp after or at the start of LC (or SC) data to the closest TF
% timestamp before or at the end of LC (or SC) data.
thrusterFiringTimeIsDuringCadenceData = thrusterFiringTimeStamps >= cadenceDataStartTime & thrusterFiringTimeStamps <= cadenceDataEndTime;

% TF times spanning the cadence data
thrusterFiringOverlapTimes = thrusterFiringTimeStamps(thrusterFiringTimeIsDuringCadenceData);
nOverlapTimes = length(thrusterFiringOverlapTimes);

% Truncate thrusterFiringInputStruct to the TF times spanning the cadence data
% Note: The variable name thrusterDeltaDurationSec is misleading and should really be
% thrusterCumulativeDurationSec: it represents the total amount of time in seconds that the
% thrusters have fired up to the current timestamp.  It's too late to change the
% name now, because it is used in the output struct.
thrusterDeltaDurationSec = zeros(nOverlapTimes,NUM_THRUSTERS);
for iThruster = 1:NUM_THRUSTERS
    values = thrusterFiringInputStruct.deltaDurationSec(iThruster).values;
    thrusterDeltaDurationSec(:,iThruster) = values(thrusterFiringTimeIsDuringCadenceData);
end

%=========================================================================
% 4. Plot overlapping thruster telemetry
if enablePlots
    figure;
    hold on;
    plot(thrusterDeltaDurationSec(:,1),'k-');
    plot(thrusterDeltaDurationSec(:,2),'r-');
    plot(thrusterDeltaDurationSec(:,3),'b-');
    plot(thrusterDeltaDurationSec(:,4),'g-');
    plot(thrusterDeltaDurationSec(:,5),'m-');
    plot(thrusterDeltaDurationSec(:,6),'k-.');
    plot(thrusterDeltaDurationSec(:,7),'r-.');
    plot(thrusterDeltaDurationSec(:,8),'b-.');
    xlabel('sample number');
    ylabel('Cumulative thruster firing time, seconds');
    title('Thruster firing data');
    legend('T1','T2','T3','T4','T5','T6','T7','T8','Location','NorthEast');
    set(gca,'FontSize',12);
    set(findall(gcf,'type','text'),'FontSize',12);
    saveas(gcf, strcat('rawThrusterFiringTimeSeries_',campaignIdTag), 'fig');
    saveas(gcf, strcat('rawThrusterFiringTimeSeries_',campaignIdTag), 'png');
    close(gcf);
end

%==========================================================================
% 5. Look for patterns. Form duration differences to detect thruster firing times. 
% Note that the timestamps for the differences are advanced by one cadence relative to the thruster.
thrusterFiringDurationTmpRaw = diff(thrusterDeltaDurationSec);

% Prepend  a row of zeros to the differences to sync with thruster data sampling times thrusterFiringDurationRaw is interpreted
% as the thruster firing duration relative to the previous sample, with the first entry defined to be zero.
thrusterFiringDurationRaw = [zeros(1,NUM_THRUSTERS);thrusterFiringDurationTmpRaw];

% Indicator for whether each thruster fired relative to the previous sample
thrusterFiringIndicatorRaw = thrusterFiringDurationRaw>0;

% Count the total number of thrusters that fired during each sample
thrusterFiringSum = sum(thrusterFiringIndicatorRaw,2);

%==========================================================================
% 6. Identify events related to known (and unknown) thruster firing patterns: get indicators and durations

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

% Unknown tweak indicator: if some combination of thrusters has fired, but not one of the known patterns listed above
unknownTweakIndicatorRaw = thrusterFiringSum>0&...
    ~fineTweak1IndicatorRaw&...
    ~fineTweak2IndicatorRaw&...
    ~mamaBearTweak1IndicatorRaw&...
    ~mamaBearTweak2IndicatorRaw&...
    ~resatTweakIndicatorRaw;

%==========================================================================
% 7. Sync to short or long cadence data and generate PA/PDC data product for each cadence

% thrusterFiringFlag indicates whether each thruster fired during a cadence
% thrusterFiringDuration accumulates firing duration for each thruster

% initialize thruster event counter, flags, durations and indicators
thrusterFiringFlag = zeros(nCadences,NUM_THRUSTERS);
thrusterFiringDuration = zeros(nCadences,NUM_THRUSTERS);
thrusterFiringNumberOfEvents = zeros(nCadences,NUM_THRUSTERS);
possibleThrusterActivityIndicators = false(nCadences,1);
definiteThrusterActivityIndicators = false(nCadences,1);

% initialize many different flavors of flags and durations for known and unknown tweak patterns
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


% Loop over cadences and set the above flags
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
    if iCadence > 1
        
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
    if iCadence < nCadences
                
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
    if ~isempty(thisCadenceOverlapTimes)
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
    
    switch thrusterAlgorithm
        
        case 'original'
                        
            % definiteThrusterActivityIndicators
            definiteThrusterActivityIndicators(iCadence)  = any(thrusterFiringFlag(iCadence,:));
            
            % possibleThrusterActivityIndicators
            % If the first and last thruster firing telemetry samples in this
            % cadence are not BOTH within maxThrusterSampleTimeDiffDays of the
            % cadence boundary, then we *provisionally* set possibleThrusterActivityIndicators
            % to 'true' for this cadence. 
            if (thrusterSampleTimesInThisCadence(1) - thisCadenceStartTime > maxThrusterSampleTimeDiffDays) || ...
                (thisCadenceEndTime - thrusterSampleTimesInThisCadence(end) > maxThrusterSampleTimeDiffDays)
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
            % thruster during this cadence
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
            if isempty(thisCadenceOverlapTimes)
                possibleThrusterActivityIndicators(iCadence) = true;
            elseif iCadence == 1 && thisCadenceOverlapTimes(1) > thisCadenceStartTime
                possibleThrusterActivityIndicators(iCadence) = true;
            elseif iCadence == nCadences && thisCadenceOverlapTimes(end) < thisCadenceEndTime
                possibleThrusterActivityIndicators(iCadence) = true;
            end
            
            % 2B. If a thruster fired between the last sample of this cadence
            % and the first sample of the next cadence,
            % or if we don't know because there was no thruster firing
            % telemetry in the next cadence,
            % then *provisionally* set possibleThrusterActivityIndicators to
            % true for this cadence and the next cadence            
           if iCadence < nCadences
                if any(isnan(cumulativeThrusterFiringDurationAtStartOfNextCadence)) || ... 
                        any( cumulativeThrusterFiringDurationAtEndOfThisCadence < cumulativeThrusterFiringDurationAtStartOfNextCadence )
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
            if iCadence > 1
                if any(isnan(cumulativeThrusterFiringDurationAtEndOfPreviousCadence)) ||... 
                        any(cumulativeThrusterFiringDurationAtEndOfPreviousCadence < cumulativeThrusterFiringDurationAtStartOfThisCadence)
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
possibleThrusterActivityIndicators = possibleThrusterActivityIndicators & ~definiteThrusterActivityIndicators;
thrusterFiringEvents.possibleThrusterActivityIndicators = possibleThrusterActivityIndicators;

% Populate thrusterFiringDataStruct
thrusterFiringDataStruct.thrusterFiringFlag     = thrusterFiringFlag;
thrusterFiringDataStruct.thrusterFiringDuration = thrusterFiringDuration;
thrusterFiringDataStruct.fineTweak1Flag         = fineTweak1Flag;
thrusterFiringDataStruct.fineTweak2Flag         = fineTweak2Flag;
thrusterFiringDataStruct.fineTweak1Duration     = fineTweak1Duration;
thrusterFiringDataStruct.fineTweak2Duration     = fineTweak2Duration;
thrusterFiringDataStruct.mamaBearTweak1Flag     = mamaBearTweak1Flag;
thrusterFiringDataStruct.mamaBearTweak2Flag     = mamaBearTweak2Flag;
thrusterFiringDataStruct.mamaBearTweak1Duration = mamaBearTweak1Duration;
thrusterFiringDataStruct.mamaBearTweak2Duration = mamaBearTweak2Duration;
thrusterFiringDataStruct.resatTweakFlag         = resatTweakFlag;
thrusterFiringDataStruct.resatTweakDuration     = resatTweakDuration;
thrusterFiringDataStruct.unknownTweakFlag       = unknownTweakFlag;

thrusterFiringDataStruct.possibleThrusterActivityIndicators = possibleThrusterActivityIndicators;
thrusterFiringDataStruct.definiteThrusterActivityIndicators = definiteThrusterActivityIndicators;

% a final message!
fprintf('Finished processing thruster firing data\n');


%==========================================================================
% 8. Produce report
if produceReport
    
    % Save the output file
    fprintf('Saving thruster flags for campaign %s\n',campaignIdTag)
    archiveFileName = strcat('thruster_firing_flags_',campaignIdTag);
    save(archiveFileName,'thrusterFiringEvents','cadenceTimes');
    
    % Make the filename for the csv output file
    csvFileName = strcat('thruster_firing_flags_',campaignIdTag,'.csv');
    
    % Add header information
    dateVector = datestr(now,'yyyy-mm-dd');

    fid = fopen(csvFileName,'w');
    fprintf(fid,'#K2 Thruster Firing Flags\n');
    fprintf(fid,'#%s\n',campaignIdString);
    fprintf(fid,'#%s\n',cadenceType);
    fprintf(fid,'#Col 1: Cadence Number\n');
    fprintf(fid,'#Col 2: Definite Thruster Firing\n');
    fprintf(fid,'#Col 3: Possible Thruster Firing\n');
    fprintf(fid,'#Ticket %s\n',ksocId); 
    fprintf(fid,'#Created on %s\n',dateVector);
    fprintf(fid,'#\n');
  
    % Append the thruster firing data
    outputData =  [cadenceTimes.cadenceNumbers, ...
                  thrusterFiringEvents.definiteThrusterActivityIndicators, ...
                  thrusterFiringEvents.possibleThrusterActivityIndicators];
    dlmwrite(csvFileName,outputData,'precision',9,'-append');
    fclose('all');
end


end
