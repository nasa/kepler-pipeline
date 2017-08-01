%% pdc_convert_81_data_to_82
%
% function [pdcInputStruct] = pdc_convert_81_data_to_82(pdcInputStruct)
%
% Update 8.1-era PDC input structures to 8.2. This is useful when testing
% with existing data sets.
%%
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

function [pdcInputStruct] = pdc_convert_81_data_to_82(pdcInputStruct)

% First call all previous conversion files
% Theses should iteratively call each other on down
[pdcInputStruct] = pdc_convert_80_data_to_81(pdcInputStruct);

% Don't be vocal about when to set a field
verbosity = false;

% New struct: pdcBlob
pdcInputStruct         = assert_field(pdcInputStruct,           'pdcBlobs', struct(), verbosity);
pdcInputStruct.pdcBlobs = assert_field(pdcInputStruct.pdcBlobs, 'blobFilenames', [], verbosity);
pdcInputStruct.pdcBlobs = assert_field(pdcInputStruct.pdcBlobs, 'gapIndicators', [], verbosity);
pdcInputStruct.pdcBlobs = assert_field(pdcInputStruct.pdcBlobs, 'blobIndices', [], verbosity);
pdcInputStruct.pdcBlobs = assert_field(pdcInputStruct.pdcBlobs, 'startCadence', [], verbosity);
pdcInputStruct.pdcBlobs = assert_field(pdcInputStruct.pdcBlobs, 'endCadence', [], verbosity);

% New fields for pdcModuleParameters
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'bandSplittingEnabled', true, verbosity);
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'stellarVariabilityRemoveEclipsingBinariesEnabled', true, verbosity);
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'mapSelectionMethod', 'noiseVariabilityEarthpoints', verbosity);
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'mapSelectionMethodCutoff', 0.8, verbosity);
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'mapSelectionMethodMultiscaleBias', 0.1, verbosity);

% New fields for mapConfigurationStruct
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'svdSnrCutoff', 5, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'svdMaxOrder', 8, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'fitNormalizationMethod', {'mean' 'mean' 'std' 'noiseFloor'}, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'svdNormalizationMethod', {'noiseFloor' 'mean' 'std' 'noiseFloor'}, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'quickMapEnabled', false, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'quickMapVariabilityCutoff', 1.0, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'priorPdfGoodnessGain', [1.0 1.0 20.0 20.0], verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'goodnessMetricIterationsEnabled', [true false], verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'goodnessMetricIterationsCutoff', 0.8, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'goodnessMetricIterationsPriorWeightStepSize', 2.0, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'goodnessMetricMaxIterations', 50, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'forceRobustFit', [false true false false], verbosity);

% Field removed from mapConfigurationStruct
if (isfield(pdcInputStruct.mapConfigurationStruct, 'debugRun'))
    rmfield(pdcInputStruct.mapConfigurationStruct, 'debugRun');
end

% New fields for goodnessMetricConfigurationStruct
pdcInputStruct.goodnessMetricConfigurationStruct= ...
    assert_field(pdcInputStruct.goodnessMetricConfigurationStruct, 'earthPointScale', 1.0, verbosity);

% bandSplittingConfigurationStruct
if (~isfield(pdcInputStruct,'bandSplittingConfigurationStruct'))
    pdcInputStruct.bandSplittingConfigurationStruct = bsDataClass.create_default_config_struct();
end
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'numberOfBands' , 3 );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'splittingMethod' , 'wavelet' );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'waveletFamily' , 'daubechies' );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'numberOfWaveletTaps' , 12 );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'groupingMethod' , 'manual' );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'groupingManualBandBoundaries' , [ 1023 3 ] );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'edgeEffectMitigationMethod' , 'expointmirrortaper' );
pdcInputStruct.bandSplittingConfigurationStruct = ...
    assert_field( pdcInputStruct.bandSplittingConfigurationStruct, 'edgeEffectMitigationExtrapolationRange' , 500 );

% spsdDetectionConfigurationStruct
pdcInputStruct.spsdDetectionConfigurationStruct = assert_field( pdcInputStruct.spsdDetectionConfigurationStruct, 'quickSpsdEnabled', false, verbosity );

% Parse data anomaly types.
if isfield(pdcInputStruct.cadenceTimes, 'dataAnomalyTypes')
    if ~isfield(pdcInputStruct.cadenceTimes, 'dataAnomalyFlags')
        [pdcInputStruct.cadenceTimes.dataAnomalyFlags] = ...
            parse_data_anomaly_types(pdcInputStruct.cadenceTimes.dataAnomalyTypes);
    end % if
    pdcInputStruct.cadenceTimes = rmfield(pdcInputStruct.cadenceTimes, 'dataAnomalyTypes');
end % if

if isfield(pdcInputStruct.longCadenceTimes, 'dataAnomalyTypes')
    if ~isfield(pdcInputStruct.longCadenceTimes, 'dataAnomalyFlags')
        [pdcInputStruct.longCadenceTimes.dataAnomalyFlags] = ...
            parse_data_anomaly_types(pdcInputStruct.longCadenceTimes.dataAnomalyTypes);
    end % if
    pdcInputStruct.longCadenceTimes = rmfield(pdcInputStruct.longCadenceTimes, 'dataAnomalyTypes');
end % if

return
