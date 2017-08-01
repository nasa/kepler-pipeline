function performanceStatsStruct = assess_performance(obj, resultsStruct )
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

    correctionPerformanceStruct = struct( ...
        'containsFalseAlarm', [], ...
        'rmsePercentReduction',[] ...
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
                              
    se = resultsStruct.simulatedEvents;
    de = resultsStruct.detectedEvents;
    nEventsSimulated = numel(se);
    nEventsDetected  = numel(de);    

    nTargets = numel(obj.cleanTargetDataStruct);
    nCadences = length(obj.cleanTargetDataStruct(1).values);
    
    nDirtyTargets = length(unique([de.keplerId])); % Number of targets in which at least one event was detected. 
    dirtyTargetDataStruct = obj.inject_events( se );

    
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
    Pfa  = nFalseAlarms / (nDecisions - nSpsds);
           
    
    %----------------------------------------------------------------------
    % Assess Correction Performance.
    % We measure the "correction" performance for all targets containing
    % detected events, whether or not they are actually SPSDs. This allows
    % us to quantify both how well we do at correcting actual SPSDs and how
    % badly we corrupt light curves in cases of false alarms.
    %----------------------------------------------------------------------
    detectedEventKeplerIds = [de.keplerId];
    performanceStatsStruct.correctionPerformance.containsFalseAlarm   = false(nDirtyTargets, 1);
    performanceStatsStruct.correctionPerformance.rmsePercentReduction = zeros(nDirtyTargets, 1);
    for i = 1:nDirtyTargets
        dirtyTarget     = resultsStruct.spsds.targets(i);
        keplerId        = dirtyTarget.keplerId;            
        targetInd       = find([obj.cleanTargetDataStruct.keplerId] == keplerId);                                
        cleanFlux       = obj.cleanTargetDataStruct(targetInd).values;
        dirtyFlux       = dirtyTargetDataStruct(targetInd).values;
        correctedFlux   = dirtyTargetDataStruct(targetInd).values + dirtyTarget.cumulativeCorrection;
        uncorrectedRmse = sqrt(mean((cleanFlux - dirtyFlux).^2));
        correctedRmse   = sqrt(mean((cleanFlux - correctedFlux).^2));

        if ismember(keplerId, detectedEventKeplerIds(falseAlarms))
            performanceStatsStruct.correctionPerformance.containsFalseAlarm(i) = true;
        end
        
        if uncorrectedRmse ~= 0
            performanceStatsStruct.correctionPerformance.rmsePercentReduction(i) = 100*(1 - correctedRmse / uncorrectedRmse);
        end
    end
    
    %----------------------------------------------------------------------
    % Assess light curve corruption due to false alarms
    %----------------------------------------------------------------------

    
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
    
end

