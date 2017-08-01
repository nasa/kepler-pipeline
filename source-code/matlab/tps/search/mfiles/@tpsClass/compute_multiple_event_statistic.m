function [tpsResults, alerts] = compute_multiple_event_statistic(tpsObject, ...
    tpsResults, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [tpsResults, alerts] =
% compute_multiple_event_statistic(tpsObject,tpsResults, alerts, extendedFlux)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription:
% This function computes the multiple events statistic by calling the
% period and phase folding functions.  A model transit pulse train is
% robustly fit to the data and a robust detection statistic is computed.
% The robust detection statistic is the windowed robust fitted depth
% divided by the error in the windowed robust fitted depth.
% If a robust detection is not made then the robust weights are used to gap
% data and the data is refolded.  This process is repeated until either a
% robust detection is made or there are no linear detection
% statistics above threshold or until there are no cadences below the 
% gapping threshold.
%
% Inputs:
%
% Outputs:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


%-------------------------------------------------------------------------
% preliminaries
%-------------------------------------------------------------------------
tic

debugLevel                     = tpsObject.tpsModuleParameters.debugLevel ;
tpsModuleParameters            = tpsObject.tpsModuleParameters ;
tpsTargets                     = tpsObject.tpsTargets ;
randStreams                    = tpsObject.randStreams ;
cadenceTimes                   = tpsObject.cadenceTimes ;
bootstrapParameters            = tpsObject.bootstrapParameters ;
gapFillParameters              = tpsObject.gapFillParameters;
cadencesPerHour                = tpsModuleParameters.cadencesPerHour ;
searchTransitThreshold         = tpsModuleParameters.searchTransitThreshold ;
transitPulseDurationInHours = unique([tpsResults.trialTransitPulseInHours]) ;

startFoldingTime = clock ;

% check for bootstrap diagnostic collection - this never got added as a
% module parameter but it is useful to be able to turn it off for runs
if ~isfield(tpsModuleParameters,'collectBootstrapDiagnostics')
    collectBootstrapDiagnostics = false;
else
    collectBootstrapDiagnostics = tpsModuleParameters.collectBootstrapDiagnostics;
end

% Temporary Fix:  Load the list of cadences associated with reaction wheel
% zero crossing events - these have notoriously aweful cosmic ray cleaning.
% After the fix is implemented and all the data is reprocessed past that
% point in PA then this code should be scrubbed from TPS

zeroCrossingIndices = [] ;
if tpsModuleParameters.deweightReactionWheelZeroCrossingCadences
    zeroCrossingCadences = load_zero_crossing_cadence_list() ;
    zeroCrossingIndices = find(ismember(cadenceTimes.cadenceNumbers, zeroCrossingCadences)) ;
end

% perform detection of sudden pixel sensitivity dropouts, and return a set of
% logicals which indicate the cadences which are to be ignored in the folding

dropoutCadences = detect_pixel_sensitivity_dropouts( tpsObject, tpsResults) ;

debugFlag = debugLevel > 1 ;
nStars = length(tpsTargets) ;
nCadences = length(cat(1, cadenceTimes.midTimestamps)) ;
maxMesAcrossAllPulses = zeros(nStars,1) ;
periodOfMaxMesCadences = zeros(nStars,1) ;

% set up a separate search transit threshold for each target star

searchTransitThreshold = repmat(searchTransitThreshold,nStars,1) ;

% set the max time permitted for each pulse

tpsModuleParameters.maxHrsLoopingPerPulse = tpsObject.taskTimeoutSecs * ...
    get_unit_conversion('sec2hour') * tpsModuleParameters.looperMaxWallTimeFraction ...
    / nStars / length(transitPulseDurationInHours) / tpsObject.tasksPerCore;
maxLoopingHours = tpsModuleParameters.maxHrsLoopingPerPulse * ...
    length(transitPulseDurationInHours) * nStars ;

% search for transits with all trial pulses for each target

totalTimeoutExceeded = false ;

%for kPulse = 1:length(transitPulseDurationInHours)
for kPulse=length(transitPulseDurationInHours):-1:1
    
    if (totalTimeoutExceeded)
        break ;
    end
     
    minPeriodDays = get_min_search_period_days( tpsModuleParameters, ...
        transitPulseDurationInHours(kPulse) ) ;
    maxPeriodDays = get_max_search_period_days( tpsModuleParameters, ...
        transitPulseDurationInHours(kPulse) ) ;
    
%   if a search is even possible, do it now; otherwise move onto the next pulse duration 
    
    if minPeriodDays <= tpsModuleParameters.maximumSearchPeriodInDays && ...
         maxPeriodDays >= tpsModuleParameters.minimumSearchPeriodInDays
         if debugLevel >= 0
           fprintf('    searching for transits with trial transit pulse duration of  %f hours\n', ...
               transitPulseDurationInHours(kPulse)) ;
         end
    else
         if debugLevel >= 0
           disp(['    No valid search periods for ', ...
               num2str(transitPulseDurationInHours(kPulse)),' hour transits, skipping']) ;
         end
         continue ;
    end
        
%   we need to initialize the start time slightly differently for trial transit pulses
%   depending on whether they are odd- or even-cadence length:

    cadence1Timestamp = initialize_search_start_cadence_timestamp( ...
        transitPulseDurationInHours(kPulse), tpsModuleParameters.cadencesPerHour, ...
        tpsObject.cadenceTimes) ;
    
%   initialize possiblePeriodsInCadences to empty; for each pulse duration, the period
%   vector will be set when the first star gets period-folded, and that vector will be
%   reused for all subsequent stars
    
    possiblePeriodsInCadences = [] ;
    
    for jStar = 1:nStars
        
        if totalTimeoutExceeded
            break ;
        end
        
        % initialize rand seed
        randStreams.set_default( tpsTargets(jStar).keplerId ) ;
        
        currentStarIndex = (kPulse-1) * nStars + jStar ;
        tpsResultsForThisStar = tpsResults(currentStarIndex) ;
        tpsResultsForThisStar.nSpsd = length( identify_contiguous_integer_values( ...
            find( dropoutCadences(:,jStar) ) ) ) ;
        tpsResultsForThisStar.spsdIndices = find( dropoutCadences(:,jStar) );
        startTime = clock ;
        tpsModuleParameters.searchTransitThreshold = searchTransitThreshold(jStar) ;
        
%       if the cdppTimeSeries is voided because of the presence of NaN,
%       then skip this star
   
        if(all(tpsResultsForThisStar.cdppTimeSeries == -1)) % iinvalid cdpp time series is filled with -1
                        
            disp( ...
                ['        fold_detection_statistics_time_series: correlation/normalization/CDPP time series not available for \ntarget ' num2str(jStar) ' Kepler Id ' ...
                num2str(tpsTargets(jStar).keplerId) ' for trial transit pulse of ' num2str(transitPulseDurationInHours(kPulse)) ' hours;\nhence not folding statistics']) ;
            
%           add alert

            alerts = add_alert(alerts, 'warning', ...
                ['fold_detection_statistics_time_series: correlation/normalization/CDPP time series not available for \ntarget ' num2str(jStar) ' Kepler Id ' ...
                num2str(tpsTargets(jStar).keplerId) ' for trial transit pulse of ' num2str(transitPulseDurationInHours(kPulse)) ' hours;\nhence not folding statistics']) ;
            disp(alerts(end).message) ;
            continue ;
        end
        
        % re-initialize the deemphasis weights to add in the new indices.
        % The deemphasisParameter must be updated as well since this is
        % what gets used in the search to build the weights
        deemphasisParameter = cadenceTimes.deemphasisParameter ;
        
        [deemphasisWeightSuperResolution, deemphasisWeight, deemphasisParameter] = ...
            initialize_deemphasis_weights( tpsTargets(jStar), deemphasisParameter, tpsModuleParameters, gapFillParameters, ...
            tpsResultsForThisStar.positiveOutlierIndices, find(dropoutCadences(:,jStar)), zeroCrossingIndices(:) ) ;
        
        tpsResultsForThisStar.deemphasisWeightSuperResolution = deemphasisWeightSuperResolution;
        tpsResultsForThisStar.deemphasisWeight = deemphasisWeight;    
        
%       execute robust statistic algorithm to require robust detection
                    
%       execute loop as long as the MES is above threshold and the
%       RS/MES is below threshold and as long as we still have cadences
%       with robust weights below threshold that can be gapped and as
%       long as change in the fitted depth from one iteration to the
%       next is larger than a small percentage of the noise in the
%       fitted depth

%       do the folding to either improve the current transit or
%       find an entirely different transit

%       build a struct for carrying folding-related parameters around

        foldingParameterStruct.trialTransitDurationInCadences = ...
             round(cadencesPerHour * ...
             tpsResultsForThisStar.trialTransitPulseInHours);
         foldingParameterStruct.nCadences = nCadences ;
         foldingParameterStruct.cadence1Timestamp = cadence1Timestamp ;
         foldingParameterStruct.quarters = cadenceTimes.quarters ; 

%       execute folding! 

        [tpsResultsForThisStar, possiblePeriodsInCadences] = ...
            fold_statistics_and_apply_vetoes(tpsResultsForThisStar, ...
            tpsModuleParameters, bootstrapParameters, possiblePeriodsInCadences, ...
            foldingParameterStruct, deemphasisParameter ) ;
        
%       if appropriate, latch the current period and MES for this star; also raise the
%       detection threshold for this star in that case

        if tpsResultsForThisStar.maxMultipleEventStatistic > ...
                maxMesAcrossAllPulses(jStar)              && ...
                tpsResultsForThisStar.isPlanetACandidate  
            maxMesAcrossAllPulses(jStar) = tpsResultsForThisStar.maxMultipleEventStatistic ;
            periodOfMaxMesCadences(jStar) = tpsResultsForThisStar.bestOrbitalPeriodInCadences ;
            searchTransitThreshold(jStar) = maxMesAcrossAllPulses(jStar) ;
        end
        
%       Collect bootstrap diagnostics     
        
        if (isequal(nStars,1) && tpsModuleParameters.debugLevel >= 0 && collectBootstrapDiagnostics)
            tpsResultsForThisStar = collect_bootstrap_diagnostics( tpsResultsForThisStar, ...
                tpsModuleParameters, bootstrapParameters, foldingParameterStruct ) ;
        end
        
%       Record data span and the number of valid cadences for completeness study

        [numValidCadences, dataSpanInCadences] = compute_duty_cycle( ...
            tpsResultsForThisStar.deemphasisWeight ) ;
        tpsResultsForThisStar.numValidCadences = numValidCadences ;
        tpsResultsForThisStar.dataSpanInCadences = dataSpanInCadences ;

        tpsResultsForThisStar.foldingWallTimeHours = etime( clock, startTime ) * ...
            get_unit_conversion( 'sec2hour' ) ;
        tpsResults(currentStarIndex) = tpsResultsForThisStar ;  
        
        if(debugFlag)
            if(tpsResultsForThisStar.maxMultipleEventStatistic >= searchTransitThreshold)
                fprintf('Detected Period = %5.2f\n',...
                    tpsResultsForThisStar.detectedOrbitalPeriodInDays) ;
                fprintf('Detected Phase = %5.2f\n',...
                    tpsResultsForThisStar.timeToFirstTransitInDays) ;
                fprintf('Maximum multiple event detection statistic = %5.2f\n', ...
                    tpsResultsForThisStar.maxMultipleEventStatistic) ;
                fprintf('Maximum single event detection statistic = %5.2f\n', ...
                    tpsResultsForThisStar.maxSingleEventStatistic) ;
                tps_construct_transit_detection_plots(tpsResults(currentStarIndex), ...
                    tpsModuleParameters,possiblePeriodsInCadences) ;
                close all ;
            end
        end
        
%       check against total timeout

        if etime(clock, startFoldingTime) * get_unit_conversion('sec2hour') > ...
                maxLoopingHours
            disp(['    TPS total folding time exceeded on target ', num2str(jStar), ...
                ', pulse duration ', num2str(tpsResultsForThisStar.trialTransitPulseInHours), ...
                ' hours, ending fold/search process']) ;
            totalTimeoutExceeded = true ;
        end
        
    end
end

randStreams.restore_default() ;

timeTakenToFoldTimeSeries = toc ;

% issue a warning with the # of MES time series which contained NaNs

if debugLevel >= 0
   fprintf('... transit search took %f seconds\n',  timeTakenToFoldTimeSeries) ;
end

return

