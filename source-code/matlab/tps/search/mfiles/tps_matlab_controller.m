function tpsOutputStruct = tps_matlab_controller(tpsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tpsOutputStruct = tps_matlab_controller(tpsInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function forms the MATLAB side of the transiting planet search (TPS)
% algorithms interface and it receives inputs via the structure
% tpsInputStruct and return the results via tpsOutputStruct.
% The following steps describe the steps involved in performing the
% transit search on systematic error corrected flux time series of target
% stars:
%   1. validate_tps_input_structure validates the fields of  the input
%   structure for existence and valid range of data
%   2. tpsClass, the class constructor instanttiates tpsObject which
%   encapsulates the input data
%   3. identify_and_stitch_multiple_quarters_flux checks for the presence
%   of multiple quarters of data and stitches them to avoid discontinuities
%   near the quarter boundary and converts the flux time series to relative
%   flux time series.
%   4. compute_cdpp_time_series computes the CDPP time series as well as
%   the correlation and normalization time series which form the components
%   of the single event statistics time series
%   5. compute_multiple_event_statistic computes the robust multiple event
%   statistics at various orbital periods and flags threshold crossing
%   events as potential planets (this step is performed only if 'tpsLiteEnabled' is
%   set to false.
%   6. validate_tps_output_structure validates the outputs and issues
%   alerts if output fields are outside the valid ranges before the results
%   are returned to the Java side of the controller.
%
% Inputs:
% inputsStruct =
%     tpsModuleParameters: [1x1 struct]
%       gapFillParameters: [1x1 struct]
%              tpsTargets: [1x1775 struct]
%           rollTimeModel: [1x1 struct]
%            cadenceTimes: [1x1 struct]
%
%
% Outputs:
% outputsStruct =
%     tpsResults: [1x5325 struct]
%         alerts: []
%
% outputsStruct.tpsResults(1)
%                          keplerId: 757076
%          trialTransitPulseInHours: 3
%           maxSingleEventStatistic: 2.8831
%          meanSingleEventStatistic: 0.0088
%                           rmsCdpp: 99.1901
%                    cdppTimeSeries: [1639x1 double]
%             correlationTimeSeries: [1639x1 double]
%           normalizationTimeSeries: [1639x1 double]
%                 matchedFilterUsed: 0
%        correlationTimeSeriesHiRes: [4917x1 double]
%      normalizationTimeSeriesHiRes: [4917x1 double]
%               bestPhaseInCadences: 427.3333
%       bestOrbitalPeriodInCadences: 445.0328
%         maxMultipleEventStatistic: 4.5781
%       detectedOrbitalPeriodInDays: 9.0936
%          timeToFirstTransitInDays: 8.7320
%           timeOfFirstTransitInMjd: 5.4973e+004
%                isPlanetACandidate: 0
%      foldedStatisticAtTrialPhases: [1335x1 double]
%                phaseLagInCadences: [1335x1 double]
%     foldedStatisticAtTrialPeriods: [4277x1 double]
%         possiblePeriodsInCadences: [4277x1 double]
%
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

debugLevel = tpsInputStruct.tpsModuleParameters.debugLevel ;
% display progress messages as some of the steps take too long...

if debugLevel >= 0
    fprintf('TPS: Validating input structure..\n');
end
tStartInputValidate = tic;

metricsKey = metrics_interval_start;

import gov.nasa.kepler.common.KeplerSocBranch;

if(~KeplerSocBranch.isRelease())
    tpsInputStruct = tps_convert_91_data_to_92( tpsInputStruct ) ;
    tpsInputStruct = tps_convert_92_data_to_93( tpsInputStruct ) ;
end

tpsInputStruct = validate_tps_input_structure(tpsInputStruct);
metrics_interval_stop('tps.validate_tps_input_structure.execTimeMillis', metricsKey);

timeTakenToValidate = toc(tStartInputValidate);

if debugLevel >= 0
    fprintf('... validating input structure took %f seconds\n',timeTakenToValidate);
end

% step 2

if debugLevel >= 0
    fprintf('TPS: Instantiating tpsClass..\n');
end
tpsScienceObject = tpsClass(tpsInputStruct);

% step 3

metricsKey = metrics_interval_start;
[tpsScienceObject, harmonicTimeSeriesAll, fittedTrendAll] = ...
    perform_quarter_stitching( tpsScienceObject ) ;
metrics_interval_stop('tps.perform_quarter_stitching.execTimeMillis', metricsKey);

% step 4

disp('TPS: Computing CDPP timeseries ...');
tStartCdpp = tic;

metricsKey = metrics_interval_start;
[tpsResults, alerts, whitenedFlux] = compute_cdpp_time_series(...
    tpsScienceObject, harmonicTimeSeriesAll, fittedTrendAll);
metrics_interval_stop('tps.compute_cdpp_time_series.execTimeMillis', metricsKey);

timeTakenToComputeCdpp = toc(tStartCdpp);

if debugLevel >= 0
    fprintf('... Computing CDPP timeseries took %f seconds\n', timeTakenToComputeCdpp);
end

if ~tpsInputStruct.tpsModuleParameters.tpsLiteEnabled
    
    % step 4
    disp('TPS: Searching for transits ...');
    
    % invoke functions for performing full TPS
    metricsKey = metrics_interval_start;
    [tpsResults, alerts] = compute_multiple_event_statistic(tpsScienceObject, ...
        tpsResults, alerts);
    metrics_interval_stop('tps.compute_multiple_event_statistic.execTimeMillis', metricsKey);
    
end

if debugLevel >= 0
    disp('TPS: Writing DAWG information struct ... ') ;
    write_tps_dawg_struct( tpsInputStruct, tpsResults ) ;
end

if debugLevel >= 0
    disp('TPS: Writing diagnostic information struct ... ' ) ;
    write_tps_diagnostic_struct( tpsResults, whitenedFlux ) ;
end

if debugLevel >= 0
    isPlanetACandidate = [tpsResults.isPlanetACandidate];
    if any(isPlanetACandidate)
        disp('TPS: Writing metrics struct ... ') ;
        write_tps_metrics_struct( tpsInputStruct, tpsResults ) ;
    end
end

if debugLevel >= 0
    fprintf('TPS: Preparing output structure to return to module interface...\n');
end

% Remove fields that take up too much memory
tpsResults = remove_large_fields(tpsResults, debugLevel);

tpsOutputStruct.tpsResults = tpsResults;
tpsOutputStruct.alerts = alerts;

% generate a tpsOutputStruct which is functionally identical to the bin-file:

if debugLevel == 0
    write_TpsOutputs( 'tps-outputs-temp.bin', tpsOutputStruct ) ;
    tpsOutputStruct = read_TpsOutputs( 'tps-outputs-temp.bin' ) ;
    delete( 'tps-outputs-temp.bin' ) ;
end

close all;
fclose all;

% convert the cdppTimeSeries to single precision for reduced data volume on the NFS

for iResult = 1:length( tpsOutputStruct.tpsResults )
    tpsOutputStruct.tpsResults(iResult).cdppTimeSeries = ...
        single( tpsOutputStruct.tpsResults(iResult).cdppTimeSeries ) ;
end

return % end of main function

%=========================================================================================
% Remove fields that take up too much memory
%
% debugLevel is passed because when running TPS in DV we want to keep the planetCandidateStruct in tpsResults so that DV can create the tpsDawgStruct.
% In DV debugStruct = -1

function tpsResults = remove_large_fields(tpsResults, debugLevel)

fieldsToRemoveCell = {'correlationTimeSeriesHiRes'; 'normalizationTimeSeriesHiRes'; ...
    'foldedStatisticAtTrialPeriods'; 'possiblePeriodsInCadences';...
    'deemphasizeSuperResolutionCadenceIndicators';'foldedStatisticAtTrialPhases' ;...
    'phaseLagInCadences'; 'deemphasizeAroundSafeModeTweakIndicators'}; % can add addional fields

if (debugLevel ~= -1)
    fieldsToRemoveCell{end+1} = 'planetCandidateStruct';
end

for iField = 1:length(fieldsToRemoveCell)
    if isfield(tpsResults, fieldsToRemoveCell{iField})
        
        tpsResults = rmfield(tpsResults, fieldsToRemoveCell{iField});
    end
end

return

%=========================================================================================
% subfunction which writes the struct full of TPS-DAWG information

function write_tps_dawg_struct( tpsInputStruct, tpsResults )

% collect all the data

tpsDawgStruct = collect_results_for_dawg_file( tpsInputStruct.tpsTargets, tpsResults, ...
    tpsInputStruct.cadenceTimes ) ;

save tps-task-file-dawg-struct tpsDawgStruct ;

return

%=========================================================================================
% subfunction which writes the TPS diagnostic struct

function write_tps_diagnostic_struct( tpsResults, whitenedFlux )

% we only want the kepler ID, harmonic and detrended time series, correlation time series
% and normalization time series

desiredFields = { 'keplerId'; 'harmonicTimeSeries'; 'correlationTimeSeries'; ...
    'normalizationTimeSeries'; 'detrendedFluxTimeSeries' ; 'positiveOutlierIndices'; ...
    'meanMesEstimateForSearchPeriods'; 'validPhaseSpaceFractionForSearchPeriods'; ...
    'mesHistogram'; 'falseAlarmProbabilities'; 'mesBins'; 'bootstrapDiagnosticStruct'} ;

% remove the undesirable fields

resultsFieldNames = fieldnames( tpsResults ) ;
undesiredFields = resultsFieldNames( ~ismember( resultsFieldNames, desiredFields ) ) ;

tpsDiagnosticStruct = rmfield( tpsResults, undesiredFields ) ;

% add the whitened flux time series and deemphasis values

for iStar = 1:size( whitenedFlux, 2 )
    tpsDiagnosticStruct(iStar).whitenedFluxTimeSeries = single(whitenedFlux(:,iStar)) ;
    tpsDiagnosticStruct(iStar).deemphasisWeights = ...
        single(tpsResults(iStar).deemphasisWeight) ;
end

% convert all fields to single precision to limit size of diagnostic struct on disk

diagnosticFieldNames = fieldnames( tpsDiagnosticStruct ) ;
nPulseDurations      = length( tpsDiagnosticStruct ) ;

for iPulse = 1:nPulseDurations
    for iField = 1:length(diagnosticFieldNames)
        if ~isstruct( tpsDiagnosticStruct(iPulse).(diagnosticFieldNames{iField}) )
            tpsDiagnosticStruct(iPulse).(diagnosticFieldNames{iField}) = ...
                single( tpsDiagnosticStruct(iPulse).(diagnosticFieldNames{iField}) ) ;
        end
    end
end

% save the diagnostic struct

save tps-diagnostic-struct tpsDiagnosticStruct

return

%=========================================================================================
% subfunction which writes the struct full of TPS-metrics information

function write_tps_metrics_struct( tpsInputStruct, tpsResults )

% collect the data for the metrics and save it in a file

tpsMetricsStruct = collect_results_for_metrics_file( tpsInputStruct, tpsResults ) ;

save tps-task-file-metrics-struct tpsMetricsStruct ;

return


