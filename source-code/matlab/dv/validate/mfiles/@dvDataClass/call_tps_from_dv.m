function [thresholdCrossingEvent, singleEventStatistics, tpsResultsStruct, varargout] = ...
    call_tps_from_dv( dvDataObject, dvResultsStruct, iTarget, tpsTaskTimeoutSecs )
%
% call_tps_from_dv -- obtain updated threshold crossing event and single event statistics
% information on a DV target.
%
% [thresholdCrossingEvent, singleEventStatistics, tpsOutputStruct] = call_tps_from_dv( dvDataObject,
%    dvResultsStruct, iTarget ) calls TPS using the residualFluxTimeSeries for the
%    selected target and returns the resulting threshold crossing event and the single
%    event statistics, along with the tps results struct.
%
% Version date:  2013-December-16.
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

% Modification History:
%
%    2014-January-09, JT:
%       Remove sesProbability, sesProbabilityDof in thresholdCrossingEvent structure
%    2013-December-16, JL:
%       Add fields chiSquareGof, chiSquareGofDof, sesProbability, sesProbabilityDof in
%       thresholdCrossingEvent structure
%    2013-April-11, jcat
%       Pass tpsInputStruct as an output argument -- it is needed to build metricsStruct.
%    2013-March-05, JL:
%        add input 'tpsTaskTimeoutSecs'
%    2012-November-14, PT:
%        add support for new tpsTargets vector quarterGapIndicators.
%    2012-January-27, SS:
%        Added the tps Results as an output so they can be gathered and
%        saved as a DAWG file.  This is necessary for the completeness
%        study.
%    2011_July-05, JL:
%        output thresholdCrossingEvent struct with maximum MES of all valid TCEs.
%        thresholdCrossingEvent struct is empty when there is no valid TCE.
%    2010-October-06, PT:
%        eliminate obsolete distributionCenterFlag.  Modify to be consistent with current
%        calling procedure for multi-quarter TPS.
%    2010-August-20, PT:
%        set debugLevel for TPS to -1 to suppress lots of unhelpful diagnostic messages.
%    2009-December-10, PT:
%        fill maxSingleEventSigma in thresholdCrossingEvent from TPS-returned
%        sesCombinedToYieldMes, rather than from maxSingleEventStatistic.
%    2009-November-23, PT:
%        eliminate call to tps_controller_for_dv.
%    2009-November-09, PT:
%        add call to tps_matlab_controller_for_dv for use when we want to improve the TCE.
%    2009-September-25, PT:
%        bugfix to subfunction which finds the center of the distribution.
%    2009-September-15, PT:
%        add capability to get a TCE which finds the center of the folded statistic
%        distributions, rather than the peak value.
%
%
%=========================================================================================

% Set constant
MINUTES_PER_HOUR = get_unit_conversion('hour2min');

% DV v1.0: retrieve crowdingMetric value from 1st target table
iTargetTable = 1;

% Get parameter cadenceDurationInMinutes
cadenceDurationInMinutes = dvDataObject.gapFillConfigurationStruct.cadenceDurationInMinutes;

% Set tpsInputStruct fields with corresponding dvDataObject fields
tpsInputStruct.tpsModuleParameters               = dvDataObject.tpsConfigurationStruct;
tpsInputStruct.gapFillParameters                 = dvDataObject.gapFillConfigurationStruct;
tpsInputStruct.harmonicsIdentificationParameters = dvDataObject.tpsHarmonicsIdentificationConfigurationStruct;
tpsInputStruct.bootstrapParameters               = dvDataObject.bootstrapConfigurationStruct;
tpsInputStruct.rollTimeModel                     = dvDataObject.raDec2PixModel.rollTimeModel;
tpsInputStruct.cadenceTimes                      = dvDataObject.dvCadenceTimes;

% restore the original cadence times structure just in case
tpsInputStruct.cadenceTimes.quarters = ...
    tpsInputStruct.cadenceTimes.originalQuarters;
tpsInputStruct.cadenceTimes.lcTargetTableIds = ...
    tpsInputStruct.cadenceTimes.originalLcTargetTableIds;
tpsInputStruct.cadenceTimes = ...
    rmfield(tpsInputStruct.cadenceTimes, {'originalQuarters', 'originalLcTargetTableIds'});

% we don't need to perform quarter stitching, since the time series was quarter-stitched
% at the start of DV execution
tpsInputStruct.tpsModuleParameters.performQuarterStitching = false ;

% Run full TPS by setting tpsLiteEnabled flag to false
tpsInputStruct.tpsModuleParameters.tpsLiteEnabled = false;

% set the debug level for TPS to -1
tpsInputStruct.tpsModuleParameters.debugLevel = -1 ;

% tpsInputStruct.tpsTargets is a structure containing information of the given target:
% keplerId, kepMag are set with corresponding dvDataObject fields;
% validKepMag is set to false;
% crowingMetric IS SET TO THE VALUE IN FIRST TARGET TABLE, IGNORING SEASONAL TRANSITIONS (FOR DV v1.0)
keplerId                                 = dvDataObject.targetStruct(iTarget).keplerId;
tpsInputStruct.tpsTargets.keplerId       = keplerId;

tpsInputStruct.tpsTargets.diagnostics.keplerMag      = dvDataObject.targetStruct(iTarget).keplerMag.value;
tpsInputStruct.tpsTargets.diagnostics.validKeplerMag = false;
tpsInputStruct.tpsTargets.diagnostics.crowdingMetric = dvDataObject.targetStruct(iTarget).targetDataStruct(iTargetTable).crowdingMetric;

% Add skygroup
tpsInputStruct.skyGroup = dvDataObject.skyGroupId;

% populate the tpsTargets quarterGapIndicators vector
tpsInputStruct.tpsTargets.quarterGapIndicators = false ;

% quartersInUnitOfWork = [dvDataObject.targetTableDataStruct.quarter] ;
% quartersObserved     = [dvDataObject.targetStruct(iTarget).targetDataStruct.quarter] ;
% quartersIndicators   = ismember( quartersInUnitOfWork(:), quartersObserved(:) ) ;
% tpsInputStruct.tpsTargets.quarterGapIndicators = ~quartersIndicators(:) ;

% tpsInputStruct.tpsTargets.kepMag         = dvDataObject.targetStruct(iTarget).keplerMag.value;
% tpsInputStruct.tpsTargets.validKepMag    = false;
% tpsInputStruct.tpsTargets.crowdingMetric = dvDataObject.targetStruct(iTarget).targetDataStruct(iTargetTable).crowdingMetric;

% fluxValue, uncertainty, gapIndices and fillIndices are set with corresponding fields of residualFluxTimeSeries of the given target.
% Note that gapIndices, fillIndices, outlierIndices and discontinuityIndices are 0-based in tpsInputStruct.
tpsInputStruct.tpsTargets.fluxValue            = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.values;
tpsInputStruct.tpsTargets.uncertainty          = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.uncertainties;
tpsInputStruct.tpsTargets.gapIndices           = find(dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.gapIndicators) - 1;     % 0-based
tpsInputStruct.tpsTargets.fillIndices          = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.filledIndices       - 1;     % 0-based
tpsInputStruct.tpsTargets.outlierIndices       = dvDataObject.targetStruct(iTarget).outliers.indices                                     - 1;     % 0-based
tpsInputStruct.tpsTargets.discontinuityIndices = dvDataObject.targetStruct(iTarget).discontinuityIndices                                 - 1;     % 0-based

% Define new gap indices as union of gap indices and fill indices in TPS input and change the new gap indices to 1-based
newGapIndicesOneBased = union(tpsInputStruct.tpsTargets.gapIndices, tpsInputStruct.tpsTargets.fillIndices) + 1;                             % 1-based

% Set TPS taskTimeoutSecs and tasksPerCore
tpsInputStruct.taskTimeoutSecs = tpsTaskTimeoutSecs;
tpsInputStruct.tasksPerCore = 1;

% Pass tpsInputStruct as an argument if the call to the function has
% nargout == 4
if(nargout == 4)
    varargout{1} = tpsInputStruct;
end
    

% Call TPS
tpsOutputStruct = tps_matlab_controller( tpsInputStruct ) ;
tpsResultsStruct = tpsOutputStruct.tpsResults ;

% Set default values of gapIndicators
nCadences = length(tpsInputStruct.tpsTargets.fluxValue);
gapIndicators = false(nCadences, 1);
gapIndicators(newGapIndicesOneBased) = true;

% Update singleEventStatistics of the given target
for iTrial=1:length(tpsResultsStruct)

    % Update fields of singleEventStatistics structure with TPS results
    singleEventStatistics(iTrial).trialTransitPulseDuration      = tpsResultsStruct(iTrial).trialTransitPulseInHours;
    singleEventStatistics(iTrial).correlationTimeSeries.values   = tpsResultsStruct(iTrial).correlationTimeSeries;
    singleEventStatistics(iTrial).normalizationTimeSeries.values = tpsResultsStruct(iTrial).normalizationTimeSeries;
    singleEventStatistics(iTrial).deemphasisWeights.values       = tpsResultsStruct(iTrial).deemphasisWeight;
      
    % Update gapIndicators field of singleEventStatistics structure 
    singleEventStatistics(iTrial).correlationTimeSeries.gapIndicators   = gapIndicators;
    singleEventStatistics(iTrial).normalizationTimeSeries.gapIndicators = gapIndicators;
    
end

% Determine maximum multiple event statistic of all trial transit pulse durations and the correponding index
% [maxStatisticInTrial,indexTrial] = max([tpsOutputStruct.tpsResults.maxMultipleEventStatistic]);

thresholdCrossingEvent = [];

% Output thresholdCrossingEvent struct with maximum MES of all valid TCEs.
% thresholdCrossingEvent struct is empty when there is no valid TCEs.
isPlanetACandidate          = [tpsResultsStruct.isPlanetACandidate];
detectedOrbitalPeriodInDays = [tpsResultsStruct.detectedOrbitalPeriodInDays];
validIndices                = find( isPlanetACandidate & detectedOrbitalPeriodInDays>0 );

if ~isempty(validIndices)

    maxMultipleEventStatistic       = [tpsResultsStruct.maxMultipleEventStatistic];
    validMaxMes                     = maxMultipleEventStatistic(validIndices);
    [maxStatisticIgnored, indexBuf] = max( validMaxMes );
    indexTrial                      = validIndices(indexBuf);

    % Update fields of thresholdCrossingEvent structure with TCE information from TPS outputs
    thresholdCrossingEvent.keplerId                   = keplerId;
    thresholdCrossingEvent.trialTransitPulseDuration  = tpsResultsStruct(indexTrial).trialTransitPulseInHours;
    thresholdCrossingEvent.epochMjd                   = tpsResultsStruct(indexTrial).timeOfFirstTransitInMjd;
    thresholdCrossingEvent.orbitalPeriod              = tpsResultsStruct(indexTrial).detectedOrbitalPeriodInDays;
    thresholdCrossingEvent.maxSesInMes                = tpsResultsStruct(indexTrial).maxSesInMes;
    thresholdCrossingEvent.maxSingleEventSigma        = tpsResultsStruct(indexTrial).maxSesInMes;
    thresholdCrossingEvent.maxMultipleEventSigma      = tpsResultsStruct(indexTrial).maxMultipleEventStatistic;
    thresholdCrossingEvent.robustStatistic            = tpsResultsStruct(indexTrial).robustStatistic;
    thresholdCrossingEvent.chiSquare1                 = tpsResultsStruct(indexTrial).chiSquare1;
    thresholdCrossingEvent.chiSquareDof1              = tpsResultsStruct(indexTrial).chiSquareDof1;
    thresholdCrossingEvent.chiSquare2                 = tpsResultsStruct(indexTrial).chiSquare2;
    thresholdCrossingEvent.chiSquareDof2              = tpsResultsStruct(indexTrial).chiSquareDof2;
    thresholdCrossingEvent.chiSquareGof               = tpsResultsStruct(indexTrial).chiSquareGof;
    thresholdCrossingEvent.chiSquareGofDof            = tpsResultsStruct(indexTrial).chiSquareGofDof;
    thresholdCrossingEvent.weakSecondaryStruct        = tpsResultsStruct(indexTrial).weakSecondaryStruct;
    thresholdCrossingEvent.deemphasizedNormalizationTimeSeries ... 
                                                      = tpsResultsStruct(indexTrial).deemphasizedNormalizationTimeSeries;
    thresholdCrossingEvent.thresholdForDesiredPfa     = tpsResultsStruct(indexTrial).thresholdForDesiredPfa;


end

return

% and that's it!

%
%
%

