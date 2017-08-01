function tpsDawgStruct = collect_results_for_dawg_file( targetStruct, tpsResults, ...
    cadenceTimes )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dawgResults = collect_results_for_dawg_file( inputStruct, outputStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function defines and gathers all the information that needs added to
% the dawg struct. It can pull any info from both the targetStruct and the
% tps results struct.
%
% Inputs:
%   targetStruct: a struct that contains some of the more general info going
%                into the dawg struct
%   tpsResults:  the struct resulting from a TPS run
%
% Outputs:
%   tpsDawgStruct: collected results
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


% define the data we want to collect in the output struct

tpsDawgStruct = struct( 'keplerId', [], 'keplerMag', [], 'harmonicsRemoved', [], ...
    'rmsCdpp', [], 'strongestMes', [],  'maxMes', [], ...
    'maxSes', [], 'minMes', [], 'numSesInMes', [], 'epochKjd', [], 'periodDays', [], ...
    'pulseDurations', [], 'unitOfWorkKjd', [], 'isPlanetACandidate', [],  ...
    'thresholdForDesiredPfa', [], 'robustStatistic', [], 'isOnEclipsingBinaryList', [], ...
    'robustfitFail', [], 'fitSinglePulse', [], ...
    'foldingWallTimeHours', [], 'searchLoopCount', [],  'nSpsd', [], ...
    'exitedOnLoopCountLimit', [], 'exitedOnLoopTimeLimit', [], ...
    'removedFeatureCount', [], 'detectedFeatureCount', [], ...
    'chiSquare1', [], 'chiSquare2', [], 'chiSquare3', [], ...
    'chiSquare4', [], 'chiSquare5', [], 'chiSquare6', [], 'chiSquare7', [], 'chiSquare8', [], ...
    'chiSquare9', [], 'chiSquare10', [], 'chiSquareGof', [], 'chiSquareDof1', [], 'chiSquareDof2', [], ...
    'chiSquareDof3', [], 'chiSquareDof4', [], 'chiSquareDof5', [], 'chiSquareDof6', [], ...
    'chiSquareDof7', [], 'chiSquareDof8', [], 'chiSquareDof9', [], 'chiSquareDof10', [], ...
    'chiSquareGofDof', [], 'sesProbability', [],  'sesProbabilityDof', [], ...
    'numValidCadences', [], 'dataSpanInCadences', [], 'quartersPresent', [], ...
    'sesCombinedToYieldMes', [], 'indexOfSesAdded', [], 'zCompSum', [], 'normCompSum', [], ...
    'fittedDepth', [], 'fittedDepthChi', [], 'frontExponentialPpm', [], 'backExponentialPpm', [], ...
    'mesMeanEstimate', [], 'mesStdEstimate', [], 'falseAlarmProbability', [], ...
    'isThreshForDesiredPfaInterpolated', [], 'isFalseAlarmProbInterpolated', [], ...
    'positiveOutlierIndices', [], 'spsdIndices', [], 'weakSecondaryPhase', [], 'planetCandidateStruct', [] ) ;

% sadly, for some of these fields we are using a different name in the DAWG and the
% results structs, so we need a translation table

% if both inputs are empty then just return the initialized struct

if ( isempty(targetStruct) && isempty(tpsResults) )
    return;
end

% fill the struct

dawgFields = fieldnames(tpsDawgStruct) ;
dawgFields = dawgFields(:) ;
dawgFields = dawgFields' ;

% sadly, for some of these fields we are using a different name in the DAWG and the
% results structs, so we need a translation table

translationTable = { 'strongestMes', 'strongestOverallMultipleEventStatistic' ; ...
    'maxMes', 'maxMultipleEventStatistic' ; ...
    'minMes', 'minMultipleEventStatistic' ; ...
    'periodDays', 'detectedOrbitalPeriodInDays'; ...
    'epochKjd', 'timeOfFirstTransitInMjd' ; ...
    'pulseDurations', 'trialTransitPulseInHours' } ;

% note that there are a small number of fields which require special handling, while the
% rest are just concatenated across results and then converted to single precision

for thisFieldCell = dawgFields
    
    thisField = thisFieldCell{1} ;
    translationIndex = find(strcmp(thisField,translationTable(:,1))) ;
    if ~isempty(translationIndex)
        thisFieldOld = translationTable{translationIndex,2} ;
    else
        thisFieldOld = thisField ;
    end
    switch thisField
        
        case 'keplerId'
            tpsDawgStruct.(thisField) = int32([targetStruct.(thisFieldOld)]) ;
            
        case 'keplerMag'
            if isfield(targetStruct, 'diagnostics')
                % target struct is from TPS input
                diagnostics = [targetStruct.diagnostics] ;
                tpsDawgStruct.(thisField) = single([diagnostics.(thisFieldOld)]) ;
            else
                % target struct is from DV input
                tpsDawgStruct.(thisField) = single([targetStruct.(thisFieldOld).value]) ;
            end
            
        case 'harmonicsRemoved'
            if isfield(tpsResults,'harmonicTimeSeries')
                nTargets = length(tpsDawgStruct.keplerId) ;
                harmonicConcatenation = [tpsResults(1:nTargets).harmonicTimeSeries] ;
                tpsDawgStruct.(thisField) = any(harmonicConcatenation > 0) ;
            else
                tpsDawgStruct = rmfield(tpsDawgStruct,thisFieldOld) ;
            end
            
        case 'quartersPresent'
            tpsDawgStruct.(thisField) = ~[targetStruct.quarterGapIndicators] ;
            
            
        case 'pulseDurations'
            tpsDawgStruct.(thisField) = single(unique([tpsResults.(thisFieldOld)])) ;
            
        case 'unitOfWorkKjd'
            startTimestamps = cadenceTimes.startTimestamps ;
            endTimestamps   = cadenceTimes.endTimestamps ;
            gapIndicators   = cadenceTimes.gapIndicators ;
            startTimestamps(gapIndicators) = interp1( find(~gapIndicators), ...
                startTimestamps(~gapIndicators), find(gapIndicators), 'linear', 'extrap' ) ;
            endTimestamps(gapIndicators) = interp1( find(~gapIndicators), ...
                endTimestamps(~gapIndicators), find(gapIndicators), 'linear', 'extrap' ) ;

            tpsDawgStruct.(thisField) = single( [ startTimestamps(1) ; endTimestamps(end) ] - ...
                kjd_offset_from_mjd ) ;
            
        case 'epochKjd'
            tpsDawgStruct.(thisField) = single( [tpsResults.(thisFieldOld)] - ...
                kjd_offset_from_mjd ) ;

        case 'planetCandidateStruct'
            % Only record the per-iteration veto diagnostics if there is more than one iteration
            iIteration = 0;
            for iTpsResult = 1 : length(tpsResults)
                if (~isempty(tpsResults(iTpsResult).planetCandidateStruct) && length(tpsResults(iTpsResult).planetCandidateStruct.isPlanetACandidate) > 1)

                    % Temp version for easy readibility (no pointers in Matlab!)
                    planetCandidateStruct = tpsResults(iTpsResult).planetCandidateStruct;

                    % Convert double fields to single precision
                    % Convert int32 to int8
                    % Keep logicals as logicals
                    planetCandidateStruct.searchLoopCount           = int8(  planetCandidateStruct.searchLoopCount);
                    planetCandidateStruct.maxMes                    = single(planetCandidateStruct.maxMes);              
                    planetCandidateStruct.periodDays                = single(planetCandidateStruct.periodDays);            
                    planetCandidateStruct.epochKjd                  = single(planetCandidateStruct.epochKjd);              
                    planetCandidateStruct.numSesInMes               = int8(  planetCandidateStruct.numSesInMes);           
                    planetCandidateStruct.robustStatistic           = single(planetCandidateStruct.robustStatistic);       
                    planetCandidateStruct.chiSquare2Statistic       = single(planetCandidateStruct.chiSquare2Statistic);   
                    planetCandidateStruct.chiSquareGofStatistic     = single(planetCandidateStruct.chiSquareGofStatistic); 
                    planetCandidateStruct.maxSesInMesStatistic      = single(planetCandidateStruct.maxSesInMesStatistic);  
                    planetCandidateStruct.thresholdForDesiredPfa    = single(planetCandidateStruct.thresholdForDesiredPfa);
                    planetCandidateStruct.falseAlarmProbability     = single(planetCandidateStruct.falseAlarmProbability); 

                    nNewIterations = length(planetCandidateStruct.isPlanetACandidate);
                    % Initialize the Dawg Struct so that the classes are correct
                    if (isempty(tpsDawgStruct.planetCandidateStruct))
                        tpsDawgStruct.planetCandidateStruct = planetCandidateStruct;

                        tpsDawgStruct.planetCandidateStruct.keplerId        = repmat(int32(tpsResults(iTpsResult).keplerId), [nNewIterations,1]);
                        tpsDawgStruct.planetCandidateStruct.pulseDuration   = repmat(single(tpsResults(iTpsResult).trialTransitPulseInHours), [nNewIterations,1]);
                    else
                        tpsDawgStruct.planetCandidateStruct.keplerId(iIteration+1:iIteration+nNewIterations)      = ...
                                                    repmat(tpsResults(iTpsResult).keplerId, [nNewIterations,1]);
                        tpsDawgStruct.planetCandidateStruct.pulseDuration(iIteration+1:iIteration+nNewIterations) = ...
                                                    repmat(tpsResults(iTpsResult).trialTransitPulseInHours, [nNewIterations,1]);

                    
                        structFieldNames = fieldnames(planetCandidateStruct);
                        for iField = 1 : length(structFieldNames)
                            tpsDawgStruct.planetCandidateStruct.(structFieldNames{iField})(iIteration+1:iIteration+nNewIterations) = ...
                                            [planetCandidateStruct.(structFieldNames{iField})];
                        end
                    end
                    
                    iIteration = iIteration + nNewIterations;

                end
            end


%       there are a few which we can't conveniently fill until later, so skip for now

        case {'maxSes', 'numSesInMes', 'sesCombinedToYieldMes', 'indexOfSesAdded', ...
                'frontExponentialPpm', 'backExponentialPpm', 'positiveOutlierIndices', ...
                'spsdIndices', 'weakSecondaryPhase'}
            continue ;

%       default behavior is concatenation and conversion to single precision
            
        otherwise
            tpsDawgStruct.(thisField) = single([tpsResults.(thisFieldOld)]) ;
            
    end
    
end
            
% get the max SES in each MES
% Note: the field maxSes is mislabeled. It shoudl be maxSesinMes. But since many scripts use the tpsDawgStruct as written we should keep the name or risk
% breaking many scripts.

tpsDawgStruct.maxSes = -1 * ones( size( tpsDawgStruct.maxMes ) ) ;
tpsDawgStruct.numSesInMes = -1 * ones( size( tpsDawgStruct.maxMes ) ) ;
for iResult = 1:length(tpsDawgStruct.maxSes) 
    sesCombinedToYieldMes = tpsResults(iResult).sesCombinedToYieldMes ;
    if ~isempty( sesCombinedToYieldMes )
        tpsDawgStruct.maxSes(iResult) = single( max( sesCombinedToYieldMes ) ) ;
        tpsDawgStruct.numSesInMes(iResult) = single( length( ...
            sesCombinedToYieldMes(sesCombinedToYieldMes ~= 0) ) ) ;
    end
end

% get sesCombinedToYieldMes and indexOfSesAdded

nResults = length( tpsResults ) ;
tpsDawgStruct.sesCombinedToYieldMes = cell( 1, nResults ) ;
tpsDawgStruct.indexOfSesAdded = cell( 1, nResults ) ;
tpsDawgStruct.frontExponentialPpm = cell( 1, nResults ) ;
tpsDawgStruct.backExponentialPpm = cell( 1, nResults ) ;
tpsDawgStruct.positiveOutlierIndices = cell( 1, nResults );
tpsDawgStruct.spsdIndices = cell( 1, nResults );
tpsDawgStruct.weakSecondaryPhase = -1 * ones( 1, nResults);

for i = 1:nResults
    tpsDawgStruct.weakSecondaryPhase(i) = ...
        single(tpsResults(i).weakSecondaryStruct.maxMesPhaseInDays);
    tpsDawgStruct.positiveOutlierIndices{1,i} = ...
        single( tpsResults(i).positiveOutlierIndices );
    tpsDawgStruct.spsdIndices{1,i} = ...
        single( tpsResults(i).spsdIndices );
    tpsDawgStruct.sesCombinedToYieldMes{1,i} = ...
        single( tpsResults(i).sesCombinedToYieldMes ) ;
    tpsDawgStruct.indexOfSesAdded{1,i} = ...
        single( tpsResults(i).indexOfSesAdded ) ;
    if isempty( tpsResults(i).frontExponentialPpm )
        tpsResults(i).frontExponentialPpm = -1 ;
    end
    tpsDawgStruct.frontExponentialPpm{1,i} = ...
        single( tpsResults(i).frontExponentialPpm ) ;
    if isempty( tpsResults(i).backExponentialPpm )
        tpsResults(i).backExponentialPpm = -1 ;
    end
    tpsDawgStruct.backExponentialPpm{1,i} = ...
        single( tpsResults(i).backExponentialPpm ) ;
end
  
return
