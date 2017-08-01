function resultsAnalysisStruct = analyze_lc_results(obj, resultsStruct, eventArr)
%==========================================================================
% function resultsAnalysisStruct = analyze_results(resultsStruct,  ...
%     eventArr, cleanTargetDataStruct, localizationTolerance)
%==========================================================================
% Analyze SPSD detection and correction results.
%
%
% Inputs:
%     resultsStruct         : output from
%                             spsdCorrectedFluxClass.get_resutls() 
%     eventArr              : an array of SPSD parameter structs as defined
%                             in generate_random_events()
%     cleanTargetDataStruct : The ORIGINAL targetDataStruct (without the
%                             simulated SPSDs). All targets are assumed to  
%                             be free of SPSD events.
%     localizationTolerance : A detection is considered a hit if it is
%                             within this many cadences of the beginning of
%                             an SPSD event.
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
%     |  |-.snr                  : Signal-to-noise ratio 
%     |   -.proximities          : (currently not populated)
%     |
%     |-.detectedEvents
%     |  |-.keplerId
%     |  |-.cadence
%     |  |-.simulatedEventInd    : Index of the simulated event (or empty, if false alarm)
%     |  |-.estSensitivityDrop
%     |   -.proximities          : (currently not populated)
%     |
%     |-.performance
%        |-.nSpsds               : nSimulated (ground truth number of SPSDs)
%        |-.nDetections          : nHits + nFalseAlarms
%        |-.nDecisions           : nTargets + nDetections
%        |-.nMeasurements        : nCadences * nTargets
%        |-.hits                 : Logical array indicating whether corresponding simulated events were detected
%        |-.falseAlarms          : Logical array indicating whether corresponding detected events are false alarms
%        |-.nHits                : Number of correctly detected SPSDs
%        |-.nFalseAlarms         : Number of false positives
%        |-.Phit                 : nHits / nSpsds
%        |-.Pfa                  : nFalseAlarms / (nDecisions - nSpsds)
%        |-.decisionMat          : 2x2 decision matrix
%        |-.correctionPerformance   : Stats for corrected targets (does not summarize misses).
%           |-.containsFalseAlarm   :
%           |-.rmsePercentReduction : Percent reduction in RMSE for each corrected target (NOT for individual SPSDs)
%           |-.rmseUncorrected      : RMS flux error before correction
%           |-.rmseCorrected        : RMS flux error after correction
%            -.totalGroundTruthFlux : Total target flux before correction.
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
    MAD_FACTOR = 1.4826;
    WIN_HALF_WIDTH = 96; % Half width of the window in which to analyze the correction (same as full detector half-width)
    DROP_WIN_HALF_WIDTH = 5;

    %----------------------------------------------------------------------
    % Initialize
    %----------------------------------------------------------------------
    nTargets = numel(obj.cleanTargetDataStruct);
    nCadences = length(obj.cleanTargetDataStruct(1).values);
    nEventsSimulated = numel(eventArr);
    if resultsStruct.spsds.count > 0
        nEventsDetected  = sum([resultsStruct.spsds.targets(:).spsdCount]);
    else
        nEventsDetected  = 0;
    end
    dirtyTargetDataStruct = obj.inject_events( eventArr );

    proximitiesStruct = struct( ...
                                 'distToGapBefore', [], ...
                                 'distToGapAfter',[], ...
                                 'distToBeginning', [],  ...
                                 'distToEnd', [] ...
                                  );

    simulatedEventsArr(nEventsSimulated) = struct( ...
                                 'keplerId', [], ...
                                 'cadence',[], ...
                                 'dropSize', [],  ...
                                 'tDrop', [], ...
                                 'recoveryFraction', [], ...
                                 'recoverySpeed', [], ...
                                 'snr', [], ...
                                 'snr_inst', [], ...
                                 'proximities', proximitiesStruct ...
                                 );
                             
    detectedEventsStruct   = struct( ...
                                 'keplerId', [], ...
                                 'cadence', [], ...
                                 'simulatedEventInd', [], ... % Index of the simulated event (or empty, if false alarm)
                                 'estSensitivityDrop', [], ...
                                 'proximities', proximitiesStruct ...
                                 );

    correctionPerformanceStruct = struct( ...
                                 'containsFalseAlarm', [], ...
                                 'rmsePercentReduction',[], ...
                                 'sumAbsErrorUncorrected', [], ...
                                 'sumAbsErrorCorrected', [], ...
                                 'totalGroundTruthFlux', [] ...
                                  );

    performanceStatsStruct = struct( ...
                                 'nSpsds',[], ...           % nSimulated (ground truth number of SPSDs)
                                 'nDetections',[], ...      % nHits + nFalseAlarms
                                 'nDecisions', [],  ...     % nTargets + nDetections
                                 'nMeasurements', [],  ...  % nCadences * nTargets
                                 'hits', [], ...            % Logical array indicating whether corresponding simulated events were detected
                                 'falseAlarms', [], ...     % Logical array indicating whether corresponding detected events are false alarms
                                 'nHits', [], ...           % Number of correctly detected SPSDs
                                 'nFalseAlarms',[], ...     % Number of false positives
                                 'Phit', [], ...            % nHits / nSpsds
                                 'Pfa', [], ...             % nFalseAlarms / (nDecisions - nSpsds)
                                 'decisionMat', [], ...     % 2x2 decision matrix
                                 'correctionPerformance', correctionPerformanceStruct ... 
                                 );
                              
    resultsAnalysisStruct = ...
        struct( ...
               'simulatedEvents', [], ...
               'detectedEvents', [], ...
               'performance', [] ...
          ); 

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
        se(n).snr_inst = obj.calculate_instantaneous_spsd_snr(eventArr(n));
    end
    
    %----------------------------------------------------------------------
    % Build detected events array
    %----------------------------------------------------------------------
    de = detectedEventsStruct;
    nDirtyTargets = resultsStruct.spsds.count; % Number of targets in which one or more SPSDs was detected.
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
                                   
            k = k + 1;
        end
    end
    
    
    %----------------------------------------------------------------------
    % Assess Detection Performance
    %----------------------------------------------------------------------

    % Flag hits and false alarms
    hits        = false(nEventsSimulated, 1);
    falseAlarms = false(nEventsDetected,  1);

    if nEventsDetected > 0
        for i = 1:nEventsSimulated
            detectedEventIndices = find([de.keplerId] == se(i).keplerId);
            cadenceMatches  = find(abs([de(detectedEventIndices).cadence] - se(i).cadence) <= obj.LOCALIZATION_TOLERANCE);
            if ~isempty(cadenceMatches)
                hits(i) = true;
                deInd = detectedEventIndices(cadenceMatches(1));
                de(deInd).simulatedEventInd = i;
            end
        end
    end
    
    for i = 1:nEventsDetected
        if isempty(de(i).simulatedEventInd)
            falseAlarms(i) = true; 
        end
    end
    
    % Gather stats
    nMeasurements = nCadences * nTargets;
    nSpsds        = nEventsSimulated;
    nHits         = sum(hits);
    nFalseAlarms  = sum(falseAlarms);
    nDetections   = nHits + nFalseAlarms;
    nDecisions    = nTargets + nDetections;
    
    % Estimate hit and false alarm rates.
    Phit = nHits / nSpsds;
    Pfa  = nFalseAlarms / (nDecisions - nHits);
           
    
    %----------------------------------------------------------------------
    % Assess Correction Performance.
    % We measure the "correction" performance for all targets containing
    % detected events, whether or not they are actually SPSDs. This allows
    % us to quantify both how well we do at correcting actual SPSDs and how
    % badly we corrupt light curves in cases of false alarms.
    %----------------------------------------------------------------------
    detectedEventKeplerIds = [de.keplerId];
    performanceStatsStruct.correctionPerformance.totalGroundTruthFlux   = zeros(nDirtyTargets, 1);
    performanceStatsStruct.correctionPerformance.sumAbsErrorUncorrected = zeros(nDirtyTargets, 1);
    performanceStatsStruct.correctionPerformance.sumAbsErrorCorrected   = zeros(nDirtyTargets, 1);
    performanceStatsStruct.correctionPerformance.containsFalseAlarm     = false(nDirtyTargets, 1);
    performanceStatsStruct.correctionPerformance.rmsePercentReduction   = zeros(nDirtyTargets, 1);
    for i = 1:nDirtyTargets
        dirtyTarget     = resultsStruct.spsds.targets(i);
        keplerId        = dirtyTarget.keplerId;            
        targetInd       = find([obj.cleanTargetDataStruct.keplerId] == keplerId);                                
        cleanFlux       = obj.cleanTargetDataStruct(targetInd).values;
        dirtyFlux       = dirtyTargetDataStruct(targetInd).values;
        correctedFlux   = dirtyTargetDataStruct(targetInd).values + dirtyTarget.cumulativeCorrection;
        uncorrectedRmse = sqrt(mean((cleanFlux - dirtyFlux).^2));
        correctedRmse   = sqrt(mean((cleanFlux - correctedFlux).^2));

        performanceStatsStruct.correctionPerformance.totalGroundTruthFlux(i)   = sum(cleanFlux);
        performanceStatsStruct.correctionPerformance.sumAbsErrorUncorrected(i) = sum(abs(cleanFlux - dirtyFlux));
        performanceStatsStruct.correctionPerformance.sumAbsErrorCorrected(i)   = sum(abs(cleanFlux - correctedFlux));
        
        if ismember(keplerId, detectedEventKeplerIds(falseAlarms))
            performanceStatsStruct.correctionPerformance.containsFalseAlarm(i) = true;
        end
        
        if uncorrectedRmse ~= 0
            performanceStatsStruct.correctionPerformance.rmsePercentReduction(i) = 100*(1 - correctedRmse / uncorrectedRmse);
        end
    end
    
    
    %----------------------------------------------------------------------
    % Build output structure
    %----------------------------------------------------------------------
    performanceStatsStruct.nSpsds         = nSpsds;
    performanceStatsStruct.nDetections    = nDetections;
    performanceStatsStruct.nDecisions     = nDecisions;
    performanceStatsStruct.nMeasurements  = nMeasurements;
    performanceStatsStruct.hits           = hits;
    performanceStatsStruct.falseAlarms    = falseAlarms;
    performanceStatsStruct.nHits          = nHits;
    performanceStatsStruct.nFalseAlarms   = nFalseAlarms;
    performanceStatsStruct.Phit           = Phit;
    performanceStatsStruct.Pfa            = Pfa;
    performanceStatsStruct.decisionMat    = [nHits, nSpsds - nHits; nFalseAlarms, nDecisions - nSpsds - nFalseAlarms];
    
    resultsAnalysisStruct.simulatedEvents = se;
    resultsAnalysisStruct.detectedEvents  = de;
    resultsAnalysisStruct.performance     = performanceStatsStruct;
    
end

