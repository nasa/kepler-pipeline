function [paResultsStruct] = identify_rw_zero_crossing_cadences(paDataObject,paResultsStruct)
%**************************************************************************
% function [paResultsStruct] = identify_rw_zero_crossing_cadences( ...
%    paDataObject,paResultsStruct)
%**************************************************************************
% This paDataClass method examines the reaction wheel speeds to determine
% which cadences shall be flagged as reaction wheel zero crossing cadences.
% The reaction wheel speeds are supplied as ancillary data through the
% paDataObject. The reaction wheel zero crossing indices are identified and
% returned in the paResultsStruct. Reaction wheel zero crossing indicators
% are saved in pa_state.mat. If the required ancillary data is empty an
% alert is thrown and an empty list of indices is returned in the
% paResultsStruct.
%
% INPUTS:   paDataObject    = data object containing reaction wheel speeds,
%                             cadence numbers and cadence timestamps,
%                             median filter length, 
%           paResultsStruct = results data structure
% OUTPUTS:  paResultsStruct = data structure with reaction wheel zero
%                             crossing cadence indices attached 
%                             paResultsStruct.reactionWheelZeroCrossingIndices
% 
% Methodology:
% 1) Apply a median filter to the reaction wheel speed data for all four
%    wheels. 
% 2) Locate the points where any of the filtered data is zero.
% 3) Locate windows where filtered data is zero.
% 4) Consider only windows with length longer than the median filter length
%    as zero crossing windows. 
% 4) Flag cadences which overlap these zero crossing windows.
% 5) Plot wheel speeds with zero-speed windows indicated.
% 6) Return cadence numbers of flagged cadences.
% 
% This analysis assumes the ancillary data time series for each of the 4
% reaction wheel is the same length and the timestamps are within 1/4
% sampling period of each other.
%
% NOTE that the precision of the wheel speed data is not sufficient to
% conclude that the wheel is motionless when the speed value is zero.
% Assuming the wheel is functional a speed of zero means it is likely to be
% exhibiting low-amplitude jitter, which can have a small but measurable
% effect on the pointing and photometry.
%**************************************************************************
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


% hard coded constants
TIMESTAMP_INTERP_METHOD = 'linear'; % used to interpolate missing cadence timestamps.
SPEED_TO_FLAG = 0;                  % This parameter was useful for testing. It will be set to zero for flight.
CADENCE_MARK_OFFSET = -5;
CADENCE_MARK_SIZE = 10;

% extract reaction wheel speed mnemonics and median filter length
rwMnemonics = paDataObject.reactionWheelAncillaryEngineeringConfigurationStruct.mnemonics;
reactionWheelMedianFilterLength = paDataObject.paConfigurationStruct.reactionWheelMedianFilterLength;

% extract cadence timestamps
startTimestamps = paDataObject.cadenceTimes.startTimestamps;
midTimestamps   = paDataObject.cadenceTimes.midTimestamps;
endTimestamps   = paDataObject.cadenceTimes.endTimestamps;
cadenceNumbers  = paDataObject.cadenceTimes.cadenceNumbers;
gapIndicators   = paDataObject.cadenceTimes.gapIndicators;

% initialize zero crossing flags
reactionWheelZeroCrossingIndicators = false(size(gapIndicators));


% if ancillary data is available find RW zero crossings
if( ~isempty(paDataObject.ancillaryEngineeringDataStruct) )
    
    % extrapolate start, end and mid timestamps to fill gapped cadences
    if( any(gapIndicators) && ~all(gapIndicators) )
        startTimestamps(gapIndicators) = ...
            interp1(cadenceNumbers(~gapIndicators),startTimestamps(~gapIndicators),cadenceNumbers(gapIndicators),TIMESTAMP_INTERP_METHOD,'extrap');
        endTimestamps(gapIndicators)   = ...
            interp1(cadenceNumbers(~gapIndicators),endTimestamps(~gapIndicators),cadenceNumbers(gapIndicators),TIMESTAMP_INTERP_METHOD,'extrap');
        midTimestamps(gapIndicators)   = ...
            interp1(cadenceNumbers(~gapIndicators),midTimestamps(~gapIndicators),cadenceNumbers(gapIndicators),TIMESTAMP_INTERP_METHOD,'extrap');
    end
    
    % find the reaction wheel data in the ancillary data struct
    ancillaryrwMnemonics = {paDataObject.ancillaryEngineeringDataStruct.mnemonic}';
    [rwIndicator, mnemonicIdx] = ismember(rwMnemonics,ancillaryrwMnemonics);
    mnemonicIdx = mnemonicIdx(rwIndicator);
    
    % If data is available build wheel speeds and times arrays, filter,
    % find zero speed windows and flag cadences It is assumed the time
    % series for each of the mnemonics will be the same length
    if( any(rwIndicator) )
        wheelSpeeds = [paDataObject.ancillaryEngineeringDataStruct(mnemonicIdx).values];
        reactionWheelTimeStamps  = [paDataObject.ancillaryEngineeringDataStruct(mnemonicIdx).timestamps];
        reactionWheelTimeStamps  = mean(reactionWheelTimeStamps,2);
        
        % filter wheel speeds
        if( reactionWheelMedianFilterLength > 1 )
            filteredWheelSpeeds = medfilt1_soc(wheelSpeeds, reactionWheelMedianFilterLength);
        else
            filteredWheelSpeeds = wheelSpeeds;
        end
        
        % find windows > filter length where filtered speed matches
        % SPEED_TO_FLAG
        isFlaggedSpeed = filteredWheelSpeeds == SPEED_TO_FLAG;
        if any(any(isFlaggedSpeed,2))
            [zeroCrossingWindowLocations, zeroWindowSize] = find_datagap_locations(any(isFlaggedSpeed,2));
        else
            zeroCrossingWindowLocations = [];
            zeroWindowSize = [];
        end
        validWindowIdx = find(zeroWindowSize > reactionWheelMedianFilterLength);

     
        % loop through the zero speed windows and set flag on cadences
        % which overlap any valid zero crossing window
        for iWindow = 1:length(validWindowIdx)
            
            windowStart = reactionWheelTimeStamps(zeroCrossingWindowLocations(validWindowIdx(iWindow),1));
            windowEnd   = reactionWheelTimeStamps(zeroCrossingWindowLocations(validWindowIdx(iWindow),2));
            
            reactionWheelZeroCrossingIndicators = ...
                reactionWheelZeroCrossingIndicators | (windowStart <= endTimestamps & windowEnd >= startTimestamps);
        end
        
        % Produce plot showing reaction wheel speeds with windows
        % indicating flagged cadences.
        if( ~isempty(reactionWheelTimeStamps) )
            
            close all;
            isLandscapeOrientation = true;
            includeTimeFlag = false;
            printJpgFlag = false;
            
            t0 = floor(min(reactionWheelTimeStamps));
            h1 = figure;
            
            % plot wheel speeds
            plot(reactionWheelTimeStamps - t0,wheelSpeeds);
            grid;
            
            % build up legend entries
            legendEntries = cell(1,length(rwMnemonics));
            for iEntry = 1:length(rwMnemonics)
                % cut off '_' at end of rw mnemonics
                legendEntries{iEntry} = rwMnemonics{iEntry}(1:end-1);
            end            
            
            % mark zero crossing cadences
            if any(reactionWheelZeroCrossingIndicators)
                vline(midTimestamps(reactionWheelZeroCrossingIndicators) - t0,'g');
            end
            
            % mark rw crossing contiguous cadence start and stop times near
            % zero speed
            rwCrossingStartTimestamps = startTimestamps(reactionWheelZeroCrossingIndicators) - t0;
            rwCrossingEndTimestamps = endTimestamps(reactionWheelZeroCrossingIndicators) - t0;
            hold on;
            plot(rwCrossingStartTimestamps, CADENCE_MARK_OFFSET .* ones(size(rwCrossingStartTimestamps)),'ko','MarkerSize',CADENCE_MARK_SIZE);
            plot(rwCrossingEndTimestamps, CADENCE_MARK_OFFSET .* ones(size(rwCrossingEndTimestamps)),'k+','MarkerSize',CADENCE_MARK_SIZE);
            hold off;
            
            % add legend entries
            legendEntries{length(legendEntries) + 1} = 'flagged cadence start';
            legendEntries{length(legendEntries) + 1} = 'flagged cadence stop';

            % overlay filtered speeds on plot
            hold on;
            plot(reactionWheelTimeStamps-t0,filteredWheelSpeeds,'x');
            hold off;
            
            % add legend entries
            legendEntries{length(legendEntries) + 1} = 'filtered speeds';

            % add titles and legend            
            legend(legendEntries,'location','SouthOutside');
            xlabel(['Elapsed Days Since ', mjd_to_utc(t0)]);
            ylabel('wheel speed (RPM)');
            title(['[PA] Reaction Wheel Zero Crossing Cadences (Marked in Green) -- Module ',...
                    num2str(paDataObject.ccdModule),' / Output ',...
                    num2str(paDataObject.ccdOutput)]);
            
            plot_to_file('pa_rw_zero_crossings', isLandscapeOrientation,...
                    includeTimeFlag, printJpgFlag);
                
            close(h1);
        end
        
   else
       
       % no reaction wheel data: issue an alert
       reactionWheelTimeStamps = [];                                                                                        %#ok<NASGU>
       zeroCrossingWindowLocations = [];                                                                                    %#ok<NASGU>
       disp('Warning: Reaction wheel ancillary data not available. Zero crossing indices empty.');
       paResultsStruct.alerts = ...
           add_alert(paResultsStruct.alerts, 'warning', ...
           'Reaction wheel ancillary data not available. Zero crossing indices empty.');
    end
    
else
    
    % no ancillary engineering data: issue an alert
    reactionWheelTimeStamps = [];                                                                                           %#ok<NASGU>
    zeroCrossingWindowLocations = [];                                                                                       %#ok<NASGU>
    disp('Warning: Reaction wheel ancillary data not available. Zero crossing indices empty.');
    paResultsStruct.alerts = ...
        add_alert(paResultsStruct.alerts,'warning','Reaction wheel ancillary data not available. Zero crossing indices empty.');
end

% save zero crossing cadence flags, wheel times and zero window locations
% the state file
save('pa_state.mat','-append','reactionWheelZeroCrossingIndicators','zeroCrossingWindowLocations','reactionWheelTimeStamps');

% attach zero crossing indices to the results struct
paResultsStruct.reactionWheelZeroCrossingIndices = find(reactionWheelZeroCrossingIndicators);
