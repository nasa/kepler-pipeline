function quarterlyStitchingObject = quarterStitchingClass( quarterlyStitchingStruct )
%
% quarterStitchingClass -- constructor for the quarterlyStitchingClass
%
% quarterlyStitchingObject = quarterStitchingClass( quarterlyStitchingStruct )
%    constructs an object which can perform all of the necessary data conditioning for
%    multi-quarter time series.  The quarterlyStitchingStruct has the following fields:
%
%    timeSeriesStruct                           [struct vector]
%    gapFillParametersStruct                    [struct]
%    harmonicsIdentificationParametersStruct    [struct]
%    quarterStitchingParametersStruct           [struct]
%    cadenceTimes                               [struct]
%
% Second level:  timeSeriesStruct fields
%
%        values                                 [double vector,  nCadences x 1]
%        uncertainties                          [double vector,  nCadences x 1]
%        gapIndicators                          [logical vector, nCadences x 1]
%        fillIndices                            [double vector] [optional]
%        outlierIndices                         [double vector] [optional]
%        harmonicsValues                        [double vector,  nCadences x 1] [optional]
%        dataSegments                           [cell vector]   [optional]
%        gapSegments                            [cell vector]   [optional]
%        medianValues                           [double vector] [optional]
%        keplerId                               [double scalar] [optional]
%        timeSeriesType                         [string]        [optional]
%
% Second level:  gapFillParametersStruct fields
%
%        madXFactor                             [double scalar]
%        maxGiantTransitDurationHours           [double scalar]
%        maxDetrendPolyOrder                    [double scalar]
%        maxArOrderLimit                        [double scalar]
%        maxCorrelationWindowXFactor            [double scalar]
%        gapFillModelIsAddBackPredictionError   [logical scalar]
%        waveletFamily                          [string]
%        waveletFilterLength                    [string]
%        cadenceDurationInMinutes               [double scalar] [optional]
%        giantTransitPolyFitChunkLengthInHours  [double scalar]
%        removeEclipsingBinariesOnList          [logical scalar]
%  
% Second level:  harmonicsIdentificationParametersStruct fields
%
%        medianWindowLengthForTimeSeriesSmoothing   [double scalar]
%        medianWindowLengthForPeriodogramSmoothing  [double scalar]
%        movingAverageWindowLength                  [double scalar]
%        falseDetectionProbabilityForTimeSeries'    [double scalar]
%        minHarmonicSeparationInBins'               [double scalar]
%        maxHarmonicComponents                      [double scalar]
%        timeOutInMinutes                           [double scalar]
%
% Second level:  quarterStitchingParametersStruct fields
%
%        debugLevel                             [double scalar]
%        medianNormalizationFlag                [logical scalar]
%        applyAttitudeTweakCorrection           [logical scalar]
%        cadencesPerHour                        [double scalar] [optional]
%        cadencesPerDay                         [double scalar] [optional]
%
% Second level:  cadenceTimes fields
%
%        startTimestamps                        [double vector,  nCadences x 1]
%        midTimestamps                          [double vector,  nCadences x 1]
%        endTimestamps                          [double vector,  nCadences x 1]
%        gapIndicators                          [logical vector, nCadences x 1]
%        requantEnabled                         [logical vector, nCadences x 1]
%        cadenceNumbers                         [double vector,  nCadences x 1]
%        isSefiAcc                              [logical vector, nCadences x 1]
%        isSefiCad                              [logical vector, nCadences x 1]
%        isLdeOos                               [logical vector, nCadences x 1]
%        isFinePnt                              [logical vector, nCadences x 1]
%        isMmntmDmp                             [logical vector, nCadences x 1]
%        isLdeParEr                             [logical vector, nCadences x 1]
%        isScrcErr                              [logical vector, nCadences x 1]
%        dataAnomalyTypes                       [cell vector,    nCadences x 1]
%        quarters                               [double vector,  nCadences x 1]
%        lcTargetTableIds                       [double vector,  nCadences x 1] 
%
% The constructor will proceed to perform the following operations:
% 
% ==> Add and populate the optional fields if missing
% ==> Remove any extra fields in quarterStitchingParametersStruct
% ==> Sort all fields in all structs into alphabetical order
% ==> Check that all expected fields are present
% ==> fill timestamps which are zero in the cadenceTimes fields
% ==> Instantiate the quarterlyStitchingClass object.
%
% Version date:  2011-February-16.
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

%
% Modification History:
%
%    2011-February-16, PT:
%        update header comments and field checking to match current organization of
%        harmonics removal and gap fill parameters structs.
%    2010-October-12, PT:
%        add medianValues optional field to timeSeriesStruct.
%    2010-September-22, PT:
%        add keplerId and timeSeriesType optional subfields in timeSeriesStruct.
%
%=========================================================================================

% step 1:  test for existence of all mandatory fields; while we're at it convert any row
% vectors to column vectors and remove excess fields in the quarterly stitching parameters
% struct

  quarterlyStitchingStruct = check_existence_of_mandatory_fields( quarterlyStitchingStruct ) ;
  
% step 2:  add the optional fields, if they are not present 

  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'dataSegments' )
      quarterlyStitchingStruct.timeSeriesStruct(1).dataSegments = cell(0) ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'gapSegments' ) 
      quarterlyStitchingStruct.timeSeriesStruct(1).gapSegments = cell(0) ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'fillIndices' )
      quarterlyStitchingStruct.timeSeriesStruct(1).fillIndices = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'outlierIndices' )
      quarterlyStitchingStruct.timeSeriesStruct(1).outlierIndices = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'medianValues' )
      quarterlyStitchingStruct.timeSeriesStruct(1).medianValues = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'harmonicsValues' )
      quarterlyStitchingStruct.timeSeriesStruct(1).harmonicsValues = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'keplerId' )
      quarterlyStitchingStruct.timeSeriesStruct(1).keplerId = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'timeSeriesType' )
      quarterlyStitchingStruct.timeSeriesStruct(1).timeSeriesType = char([]) ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'outlierFillValues' )
      quarterlyStitchingStruct.timeSeriesStruct(1).outlierFillValues = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'outlierIndicators' )
      quarterlyStitchingStruct.timeSeriesStruct(1).outlierIndicators = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.timeSeriesStruct, 'fittedTrend' )
      quarterlyStitchingStruct.timeSeriesStruct(1).fittedTrend = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.gapFillParametersStruct, ...
          'cadenceDurationInMinutes' )
      quarterlyStitchingStruct.gapFillParametersStruct.cadenceDurationInMinutes = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.quarterStitchingParametersStruct, ...
          'cadencesPerDay' )
      quarterlyStitchingStruct.quarterStitchingParametersStruct.cadencesPerDay = [] ;
  end
  if ~isfield( quarterlyStitchingStruct.quarterStitchingParametersStruct, ...
          'cadencesPerHour' )
      quarterlyStitchingStruct.quarterStitchingParametersStruct.cadencesPerHour = [] ;
  end
  
% add a field to the quarterStitchingParametersStruct to manage whether to do edge
% detrending only at quarterly boundaries or at all safe modes and earth points

  if ~isfield( quarterlyStitchingStruct.quarterStitchingParametersStruct, ...
          'edgeDetrendWithinQuarters' )
      quarterlyStitchingStruct.quarterStitchingParametersStruct.edgeDetrendWithinQuarters = true ;
  end
  
% re-sort the structs which have had fields added

  quarterlyStitchingStruct.timeSeriesStruct = orderfields( ...
      quarterlyStitchingStruct.timeSeriesStruct ) ;
  quarterlyStitchingStruct.gapFillParametersStruct = orderfields( ...
      quarterlyStitchingStruct.gapFillParametersStruct ) ; 
  quarterlyStitchingStruct.quarterStitchingParametersStruct = orderfields( ...
      quarterlyStitchingStruct.quarterStitchingParametersStruct ) ;
    
% step 3:  instantiate the object

  quarterlyStitchingObject = class( quarterlyStitchingStruct, 'quarterStitchingClass' ) ;
  
% step 4:  fill the timestamps for gapped cadences

  quarterlyStitchingObject = fill_timestamps_for_gapped_cadences( ...
      quarterlyStitchingObject ) ;
  
% step 5:  fill the optional field values

  quarterlyStitchingObject = fill_optional_field_values( quarterlyStitchingObject ) ;
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which performs the existence check of mandatory fields, and also removes
% excess fields from the parameters struct and orders the fields

function quarterlyStitchingStruct = check_existence_of_mandatory_fields( ...
    quarterlyStitchingStruct )

% define the expected fields at each level: name, class, shape

  topLevelRequiredFields = { 'timeSeriesStruct' , ...
      'gapFillParametersStruct' , ...
      'harmonicsIdentificationParametersStruct' , ...
      'quarterStitchingParametersStruct' , ...
      'cadenceTimes', 'randStreams' } ;
  
  timeSeriesRequiredFields = { 'values', 'uncertainties', 'gapIndicators' } ;

  gapFillRequiredFields = { 'madXFactor', 'maxGiantTransitDurationInHours', ...
      'maxDetrendPolyOrder', 'maxArOrderLimit', 'maxCorrelationWindowXFactor', ...
      'gapFillModeIsAddBackPredictionError', 'waveletFamily', 'waveletFilterLength', ...
      'giantTransitPolyFitChunkLengthInHours' } ;
  
  harmonicsIdentificationRequiredFields = { 'medianWindowLengthForTimeSeriesSmoothing', ...
      'medianWindowLengthForPeriodogramSmoothing', 'movingAverageWindowLength', ...
      'falseDetectionProbabilityForTimeSeries', 'minHarmonicSeparationInBins', ...
      'maxHarmonicComponents', 'timeOutInMinutes' } ;
  
  parametersStructRequiredFields = { 'debugLevel', 'medianNormalizationFlag', ...
      'applyAttitudeTweakCorrection','deemphasizePeriodAfterTweakInCadences', ...
      'varianceWindowLengthMultiplier'} ;
  
  cadenceTimesRequiredFields = { 'startTimestamps', 'midTimestamps', 'endTimestamps', ...
      'gapIndicators', 'requantEnabled', 'cadenceNumbers', 'isSefiAcc', 'isSefiCad', ...
      'isLdeOos', 'isFinePnt', 'isMmntmDmp', 'isLdeParEr', 'isScrcErr', ...
      'dataAnomalyFlags', 'quarters', 'lcTargetTableIds' } ;

% for backwards compatibility, replace dataAnomalyTypes in cadenceTimes with
% dataAnomalyFlags and add applyAttitudeTweakCorrection

  quarterlyStitchingStruct.cadenceTimes = ...
      replace_data_anomaly_types_with_flags( quarterlyStitchingStruct.cadenceTimes ) ;
  
  if ~isfield(quarterlyStitchingStruct.quarterStitchingParametersStruct, ...
          'applyAttitudeTweakCorrection')
      quarterlyStitchingStruct.quarterStitchingParametersStruct.applyAttitudeTweakCorrection = false ;
  end
  
% start with the top-level of the struct

  quarterlyStitchingStruct = check_and_order_fields( quarterlyStitchingStruct, ...
      topLevelRequiredFields ) ;
  
% go through each of the next-level-down substructs

  quarterlyStitchingStruct.timeSeriesStruct = check_and_order_fields( ...
      quarterlyStitchingStruct.timeSeriesStruct, timeSeriesRequiredFields ) ;
  quarterlyStitchingStruct.gapFillParametersStruct = check_and_order_fields( ...
      quarterlyStitchingStruct.gapFillParametersStruct, gapFillRequiredFields ) ;
  quarterlyStitchingStruct.harmonicsIdentificationParametersStruct = check_and_order_fields( ...
      quarterlyStitchingStruct.harmonicsIdentificationParametersStruct, ...
      harmonicsIdentificationRequiredFields ) ;
  quarterlyStitchingStruct.quarterStitchingParametersStruct = check_and_order_fields( ...
      quarterlyStitchingStruct.quarterStitchingParametersStruct, ...
      parametersStructRequiredFields ) ;
  quarterlyStitchingStruct.cadenceTimes = check_and_order_fields( ...
      quarterlyStitchingStruct.cadenceTimes, cadenceTimesRequiredFields ) ;
  
% remove the excess fields, if they are present, from the parameter struct, since it is
% probably descended from a TPS parameter struct

  fieldsToRemove = { 'trialTransitPulseInHours', 'storeCdppFlag', ...
      'searchPeriodStepControlFactor', 'minimumSearchPeriodInDays', ...
      'searchTransitThreshold', 'maximumSearchPeriodInDays', 'waveletFamily', ...
      'waveletFilterLength', 'superResolutionFactor', 'madXFactorForSimpleMatchedFilter', ...
      'deemphasizePeriodAfterSafeModeInDays', ...
      'robustStatisticThreshold', ...
      'robustWeightGappingThreshold', 'robustStatisticConvergenceTolerance' } ;
  
  fieldsIndicator = ismember( fieldsToRemove, fieldnames( ...
      quarterlyStitchingStruct.quarterStitchingParametersStruct ) ) ;
  fieldsToRemove = fieldsToRemove( fieldsIndicator ) ;
 
  if ~isempty( fieldsToRemove )
      quarterlyStitchingStruct.quarterStitchingParametersStruct = rmfield( ...
          quarterlyStitchingStruct.quarterStitchingParametersStruct, ...
          fieldsToRemove ) ;
  end
  
% convert all vector fields to column vectors if they are currently row vectors

  quarterlyStitchingStruct.timeSeriesStruct = quarterlyStitchingStruct.timeSeriesStruct(:) ;
  
  quarterlyStitchingStruct.cadenceTimes = convert_fields_to_column_vectors( ...
      quarterlyStitchingStruct.cadenceTimes ) ;
  
  for iTarget = 1:length( quarterlyStitchingStruct.timeSeriesStruct )
      quarterlyStitchingStruct.timeSeriesStruct(iTarget) = ...
          convert_fields_to_column_vectors( ...
          quarterlyStitchingStruct.timeSeriesStruct(iTarget) ) ;
  end
      
return 
  
%=========================================================================================

% subfunction to do the check-and-order process on the fields in a struct

function checkedStruct = check_and_order_fields( originalStruct, fieldNameCellArray )

% check to see whether they are there

  fieldPresent = isfield( originalStruct, fieldNameCellArray ) ;
  if any( ~fieldPresent )
      error( 'quarterlyStitchingClass:missingField', ...
          'quarterlyStitchingClass:  required fields missing from instantiation struct' ) ;
  end
  
% perform the sort

  checkedStruct = orderfields( originalStruct ) ;
  
return

%=========================================================================================

% subfunction which performs the conversion to column vector where necessary

function outStruct = convert_fields_to_column_vectors( inStruct )

  outStruct = inStruct ;
  fieldNames = fieldnames(outStruct) ;
  for iField = fieldNames'
      if isvector( outStruct.(iField{1}) ) && ~ischar( outStruct.(iField{1}) )
          outStruct.(iField{1}) = outStruct.(iField{1})(:) ;
      end
  end
  
return
