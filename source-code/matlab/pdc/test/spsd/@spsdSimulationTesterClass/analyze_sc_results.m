function resultsAnalysisStruct = analyze_sc_results(obj, resultsStruct, eventArr)
%==========================================================================
% resultsAnalysisStruct = analyze_sc_results(obj, resultsStruct, eventArr) 
%==========================================================================
% Analyze short-cadence SPSD localization and correction results. 
%
% For each detected SPSD event
%     (1) Is it a hit or false alarm?
%     (2) If it's a hit, how well is it localized?
%
% For each target containing detected events:
%     (1) Does the target contain injected events?
%     (2) Were any of the detected events false alarms?
%     (3) If events were injected, how well were they corrected?
%     (4) if no events were injected, how badly were the data corrupted?
%
% Inputs:
%     resultsStruct         : output from
%                             spsdCorrectedFluxClass.get_resutls() 
%     eventArr              : an array of SPSD parameter structs as defined
%                             in generate_random_events()
%     cleanTargetDataStruct : The ORIGINAL targetDataStruct (without the
%                             simulated SPSDs). All targets are assumed to  
%                             be free of SPSD events.
%
% Outputs:
%
%     resultsAnalysisStruct
%     |
%     |-.simulatedEvents
%     |  |-.keplerId
%     |  |-.cadence
%     |  |-.dropSize
%     |  |-.tDrop
%     |  |-.recoveryFraction
%     |  |-.recoverySpeed
%     |   -.snr                  : Signal-to-noise ratio 
%     |
%     |-.detectedEvents
%     |  |-.keplerId
%     |  |-.cadence
%     |  |-.isFalseAlarm
%     |  |-.simulatedEventInd    : Index of the simulated event (or empty, if false alarm)
%     |  |-.estSensitivityDrop
%     |   -.localization   
%     |
%      -.targetPerformance
%        |-.keplerId
%        |-.simulatedEventIndices  : The simulatedEvents indices of any
%        |                           events injected into this target.
%        |-.detectedEventIndices   : The detectedEvents indices of any
%        |                           events detected in this target.
%        |-.containsFalseAlarms    : True if any of the detected events are
%        |                           false alarms.
%        |-.rmsePercentReduction   : Percent reduction in RMSE for each
%        |                           corrected target containing one or
%        |                           more injected events. 
%         -.corruption             : 
%                  
%
% NOTES:
%
%     Need to update the way correction performance is tracked. It should
%     be done as a struct array with one element for each corrected target.
%     The struct should contain the target's Kepler ID, the RMSE reduction,
%     whether or not any false alarms contributed to the "correction"
%     Note that there may not be a one-to-one correspondence with the array
%     of detected events, since we allow for detected but uncorrected
%     discontinuities.
%
%     False Alarm Rate
%     ----------------
%     Although it might seem that the false alarm rate should be based on
%     the total number of cadences over all targets, the SPSD detector is
%     not actually making a decision at each cadence. To better assess the
%     quality of the decisions being made, false alarm rates are reported
%     as the number of false positives over the total number of decisions.
%     For each target, the detector only considers the cadence
%     corresponding to the maximum standardized filter response.
%
%==========================================================================
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
    DROP_WIN_HALF_WIDTH = 5;
    N_SC_CADENCES_PER_LC = 30;
    
    %----------------------------------------------------------------------
    % Initialize
    %----------------------------------------------------------------------
    scLocalizationTolerance = N_SC_CADENCES_PER_LC * obj.LOCALIZATION_TOLERANCE;
    nTargets = numel(obj.cleanTargetDataStruct);
    nCadences = length(obj.cleanTargetDataStruct(1).values);
    nEventsSimulated = numel(eventArr);
    nDirtyTargets = resultsStruct.spsds.count; % Number of targets in which SPSDs were detected.

    if resultsStruct.spsds.count > 0
        nEventsDetected  = sum([resultsStruct.spsds.targets(:).spsdCount]);
    else
        nEventsDetected  = 0;
    end
    simulatedTargetDataStruct = obj.inject_events( eventArr );

    simulatedEventsArr(nEventsSimulated) = struct( ...
                                 'keplerId', [], ...
                                 'cadence',[], ...
                                 'dropSize', [],  ...
                                 'tDrop', [], ...
                                 'recoveryFraction', [], ...
                                 'recoverySpeed', [], ...
                                 'snr', [] ...
                                 );
                             
    detectedEventsStruct   = struct( ...
                                 'keplerId', [], ...
                                 'cadence', [], ...
                                 'isFalseAlarm', [], ...
                                 'simulatedEventInd', [], ... % Index of the simulated event (or empty, if false alarm)
                                 'estSensitivityDrop', [], ...
                                 'localization', [] ...
                                 );

    targetPerformanceStruct = struct( ...
                                 'keplerId', [], ...
                                 'simulatedEventIndices', [], ...
                                 'detectedEventIndices', [], ...
                                 'containsFalseAlarms', [], ...
                                 'rmsePercentReduction', 0, ...
                                 'corruption', 0 ...
                                  );
                                                            
    resultsAnalysisStruct = ...
        struct( ...
               'hits',[], ...             % Logical array indicating whether corresponding simulated events were detected.
               'falseAlarms',[], ...      % Logical array indicating whether corresponding detected events are false alarms.
               'simulatedEvents', [], ...
               'detectedEvents', [], ...
               'targetPerformance', [] ...
          ); 
      
    hits        = false(nEventsSimulated, 1);
    falseAlarms = false(nEventsDetected,  1);

    %----------------------------------------------------------------------
    % Build simulated events array
    %----------------------------------------------------------------------
    se = simulatedEventsArr;
    for n = 1:nEventsSimulated
        se(n).keplerId         = eventArr(n).keplerId;
        se(n).cadence          = eventArr(n).cadence;
        se(n).dropSize         = eventArr(n).dropSize;
        se(n).tDrop            = eventArr(n).tDrop;
        se(n).recoveryFraction = eventArr(n).recoveryFraction;
        se(n).recoverySpeed    = eventArr(n).recoverySpeed;
        
        % Calculate SNR
        se(n).snr = obj.calculate_spsd_snr(eventArr(n));
    end
    
    %----------------------------------------------------------------------
    % Build detected events array
    %----------------------------------------------------------------------
    unmatchedSimulatedEvents = true(size(se));  % Flags indicating whether each 
                                                % simulated event has already 
                                                % been matched with a detected
                                                % event.  
    de = detectedEventsStruct;
    k = 1;
    for i = 1:nDirtyTargets
        dirtyTarget = resultsStruct.spsds.targets(i);
        for j = 1:dirtyTarget.spsdCount
            de(k).keplerId = dirtyTarget.keplerId;
            de(k).cadence = dirtyTarget.spsdEvents(j).spsdCadence;
            
            targetInd = find([obj.cleanTargetDataStruct.keplerId] == de(k).keplerId);
            dropWin = [max(1, de(k).cadence - DROP_WIN_HALF_WIDTH) : min(nCadences, de(k).cadence + DROP_WIN_HALF_WIDTH)];
            correction = dirtyTarget.spsdEvents(j).correction;
            
            % Estimate sensitivity drop as the max absolute correction in
            % the drop window over the median flux before the step. 
            leftMedianFlux  = median(obj.cleanTargetDataStruct(targetInd).values(dropWin));
            estStepHeight = max(abs(correction(dropWin)));
            de(k).estSensitivityDrop = estStepHeight / leftMedianFlux;
                                   
            % Is the detected event a false alarm? If not, assess the
            % localization performance.
            unmatchedSimulatedEventsInThisTarget = ([se.keplerId] == de(k).keplerId) & unmatchedSimulatedEvents;
            distances = abs([se.cadence] - de(k).cadence);
            candidates = distances <= scLocalizationTolerance & unmatchedSimulatedEventsInThisTarget;
            candidateIndices = find(candidates);
            [~, minInd] = min(distances(candidates));
            bestMatchInd = candidateIndices(minInd);
            if isempty(bestMatchInd) % This is a false positive
                de(k).isFalseAlarm = true;
                de(k).simulatedEventInd = [];
                de(k).localization = NaN;
                falseAlarms(k) = true;
            else                     % This is a hit, within the localization tolerance.
                de(k).isFalseAlarm = false;
                de(k).simulatedEventInd = bestMatchInd;
                de(k).localization = distances(bestMatchInd);
                unmatchedSimulatedEvents(bestMatchInd) = false;
                hits(bestMatchInd) = true;
            end
            
            k = k + 1;
        end
    end
    
 
    %----------------------------------------------------------------------
    % Assess Correction Performance.
    % We measure the "correction" performance for all targets containing
    % detected events, whether or not they are actually SPSDs. This allows
    % us to quantify both how well we do at correcting actual SPSDs and how
    % badly we corrupt light curves in cases of false alarms.
    %----------------------------------------------------------------------
    detectedEventKeplerIds = [de.keplerId];
    targetPerformanceArr = targetPerformanceStruct;
    for i = 1:nDirtyTargets
        targetPerformanceArr(i) = targetPerformanceStruct;
        dirtyTarget     = resultsStruct.spsds.targets(i);
        keplerId        = dirtyTarget.keplerId;            
        targetInd       = find([obj.cleanTargetDataStruct.keplerId] == keplerId);                                
        cleanFlux       = obj.cleanTargetDataStruct(targetInd).values;
        simulatedFlux   = simulatedTargetDataStruct(targetInd).values;
        correctedFlux   = simulatedTargetDataStruct(targetInd).values + dirtyTarget.cumulativeCorrection;
        uncorrectedRmse = sqrt(mean((cleanFlux - simulatedFlux).^2));
        correctedRmse   = sqrt(mean((cleanFlux - correctedFlux).^2));

        % Flag targets containing false alarms.
        if ismember(keplerId, detectedEventKeplerIds(falseAlarms))
            targetPerformanceArr(i).containsFalseAlarms = true;
        else
            targetPerformanceArr(i).containsFalseAlarms = false;
        end
        
        
        if uncorrectedRmse ~= 0 % No error in simulated target == no simulated SPSD
            % Determine the RMS error reduction in targets containing 
            % simulated SPSDs.
            targetPerformanceArr(i).rmsePercentReduction = 100*(1 - correctedRmse / uncorrectedRmse);
        else
            % Quantify the error introduced into targets with false alarms.
            targetPerformanceArr(i).corruption = (sum(correctedFlux) - sum(simulatedFlux)) / sum(simulatedFlux);
        end      
    end
    
    %----------------------------------------------------------------------
    % Build output structure
    %----------------------------------------------------------------------
    resultsAnalysisStruct.hits              = hits;
    resultsAnalysisStruct.falseAlarms       = falseAlarms;    
    resultsAnalysisStruct.simulatedEvents   = se;
    resultsAnalysisStruct.detectedEvents    = de;
    resultsAnalysisStruct.targetPerformance = targetPerformanceArr;
    
end

