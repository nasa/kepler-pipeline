function [self] = test_pdc_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_pdc_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test generates or loads a previously generated pdc input data
% structure, and then compares that structure with another obtained by
% writing and reading a binary file.
%
% After generating a pdc results structure with the pdc_matlab_controller,
% this test also compares that structure with another obtained by writing
% and reading a binary file.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'pdcDataStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pdcDataStruct contains the following fields:
%
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                    cadenceType: [string]  'LONG' or 'SHORT'
%                      startCadence: [int]  start cadence index
%                        endCadence: [int]  end cadence index
%                    fcConstants: [struct]  Fc constants
%      spacecraftConfigMap: [struct array]  one or more spacecraft config maps
%                   cadenceTimes: [struct]  cadence times and gap indicators
%               longCadenceTimes: [struct]  long cadence times and gap indicators
%                                           for attitude solution
%            pdcModuleParameters: [struct]  module parameters
% ancillaryEngineeringConfigurationStruct:
%                                 [struct]  config parameters for engineering data
%    ancillaryPipelineConfigurationStruct:
%                                 [struct]  config parameters for pipeline data
%    ancillaryAttitudeConfigurationStruct:
%                                 [struct]  module parameters for attitude solution
%     gapFillConfigurationStruct: [struct]  gap fill config parameters
%       ancillaryEngineeringDataStruct: 
%                           [struct array]  engineering data for cotrending
%          ancillaryPipelineDataStruct: 
%                           [struct array]  pipeline data for contrending
%         attitudeSolutionStruct: [struct]  attitude solution from PPA for cotrending
%         targetDataStruct: [struct array]  target flux to be corrected
%
%--------------------------------------------------------------------------
%   Second level
%
%     cadenceTimes and longCadenceTimes are structs with the following fields:
%
%          startTimestamps: [double array]  cadence start times, MJD
%            midTimestamps: [double array]  cadence mid times, MJD
%            endTimestamps: [double array]  cadence end times, MJD
%           gapIndicators: [logical array]  true if cadence is unavailable
%          requantEnabled: [logical array]  true if requantization was enabled
%              cadenceNumbers: [int array]  absolute cadence numbers
%
%--------------------------------------------------------------------------
%   Second level
%
%     pdcModuleParameters is a struct with the following fields:
%
%                        debugLevel: [int]  level for science debug
%                       sgPolyOrder: [int]  order of Savitzky-Golay filter to
%                                           detect saturated segments
%                       sgFrameSize: [int]  length of Savitzky-Golay frame
%                 satSegThreshold: [float]  threshold for identifying
%                                           saturated segments
%               satSegExclusionZone: [int]  zone for excluding secondary peaks
%          robustCotrendFitFlag: [logical]  robust (vs. SVD LS) fit if true
%                medianFilterLength: [int]  samples in median filter for
%                                           outlier detection
%                   histogramLength: [int]  number of bins in histogram for
%                                           outlier detection
%          histogramCountFraction: [float]  fraction of histogram counts to
%                                           use for estimating mu, sigma
%             outlierScanWindowSize: [int]  number of residuals to use for
%                                           outlier detection
%         outlierThresholdXFactor: [float]  number of sigmas from mu to set
%                                           outlier thresholds
%          normalizationEnabled: [logical]  normalize quarter to quarter
%                                           variations in target flux if true
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringConfigurationStruct is a struct with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders for cotrending
%             interactions: [string array]  array of mnemonic pairs ('|'
%                                           separated) for cotrending interactions
%        quantizationLevels: [float array]  engineering data step sizes
%    intrinsicUncertainties: [float array]  engineering data uncertainties
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineConfigurationStruct and ancillaryAttitudeConfigurationStruct
%     are structs with the following fields:
%
%                mnemonics: [string array]  mnemonic names
%                 modelOrders: [int array]  polynomial orders for cotrending
%             interactions: [string array]  array of mnemonic pairs ('|'
%                                           separated) for cotrending interactions
%
%--------------------------------------------------------------------------
%   Second level
%
%     gapFillConfigurationStruct is a struct with the following fields:
%
%                        madXFactor: [int]  MAD multiplication factor
%  maxGiantTransitDurationInHours: [float]  maximum giant transit duration (hours)
%               maxDetrendPolyOrder: [int]  maximum detrend polynomial order
%                   maxArOrderLimit: [int]  maximum AR order
%       maxCorrelationWindowXFactor: [int]  maximum correlation window
%                                           multiplication factor
%  gapFillModeIsAddBackPredictionError:
%                                [logical]  true if gap fill mode is add back
%                                           prediction error
%                  waveletFamily: [string]  name of wavelet family, e.g. 'daub'
%               waveletFilterLength: [int]  number of wavelet filter coefficients
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryEngineeringDataStruct is an array of structs (one per engineering
%     mnemonic) with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  engineering time tags, MJD
%                    values: [float array]  engineering data values
%
%--------------------------------------------------------------------------
%   Second level
%
%     ancillaryPipelineDataStruct is an array of structs (one per pipeline mnemonic) 
%     with the following fields:
%
%                       mnemonic: [string]  name of ancillary channel
%               timestamps: [double array]  pipeline time tags, MJD
%                    values: [float array]  pipeline data values
%             uncertainties: [float array]  pipeline data uncertainties
%
%--------------------------------------------------------------------------
%   Second level
%
%     attitudeSolutionStruct is a struct (valid for full focal plane) with
%     the following fields:
%
%                       ra: [double array]  attitude solution (Ra, degrees)
%                      dec: [double array]  attitude solution (Dec, degrees)
%                     roll: [double array]  attitude solution (Roll, degrees)
%        maxAttitudeFocalPlaneResidual: 
%                            [float array]  maximum attitude residual
%        covarianceMatrix11: [float array]  series of covariance (1, 1) terms
%        covarianceMatrix22: [float array]  series of covariance (2, 2) terms
%        covarianceMatrix33: [float array]  series of covariance (3, 3) terms
%        covarianceMatrix12: [float array]  series of covariance (1, 2) terms
%        covarianceMatrix13: [float array]  series of covariance (1, 3) terms
%        covarianceMatrix23: [float array]  series of covariance (2, 3) terms
%           gapIndicators: [logical array]  attitude solution gap indicators
%
%--------------------------------------------------------------------------
%   Second level
%
%     targetDataStruct is an array of structs (one per target) with the following
%     fields:
%
%                          keplerId: [int]  kepler target ID
%                       keplerMag: [float]  target magnitude
%          fluxFractionInAperture: [float]  fraction of target flux captured
%                                           in aperture
%                  crowdingMetric: [float]  fraction of total flux in aperture
%                                           due to target
%                    values: [float array]  flux values to be corrected
%             uncertainties: [float array]  uncertainties in flux values
%           gapIndicators: [logical array]  flux gap indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure pdcResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     pdcResultsStruct contains the following fields:
%
%                         ccdModule: [int]  CCD module number
%                         ccdOutput: [int]  CCD output number
%                    cadenceType: [string]  'LONG' or 'SHORT'
%                      startCadence: [int]  start cadence index
%                        endCadence: [int]  end cadence index
%      targetResultsStruct: [struct array]  corrected target flux and outliers
%                   alerts: [struct array]  module alert(s)
%
%--------------------------------------------------------------------------
%   Second level
%
%     targetResultsStruct is an array of structs (one per target) with the
%     following fields:
%
%                          keplerId: [int]  Kepler target ID
%        correctedFluxTimeSeries: [struct]  corrected PDC time series as
%                                           described above
%                       outliers: [struct]  outlier indices and values for
%                                           each target
%
%--------------------------------------------------------------------------
%   Second level
%
%     alerts is an array of structs with the following fields:
%
%                           time: [double]  alert time, MJD
%                        severity [string]  alert severity ('error' or 'warning')
%                        message: [string]  alert message
%
%--------------------------------------------------------------------------
%   Third level
%
%     correctedFluxTimeSeries is a struct with the following fields:
%
%                    values: [float array]  corrected flux values
%             uncertainties: [float array]  uncertainties in corrected flux
%                                           values
%           gapIndicators: [logical array]  indicators for remaining gaps
%               filledIndices: [int array]  indices of filled flux values
%
%--------------------------------------------------------------------------
%   Third level
%
%     outliers is a struct with the following fields:
%
%                    values: [float array]  values of corrected flux outliers
%                     indices: [int array]  indices of outliers
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

%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPdcClass('test_pdc_matlab_controller'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

initialize_soc_variables;
pdcTestDataDir = fullfile(socTestDataRoot, 'pdc', 'unit-tests', 'pdc-matlab-46-6550');

% Generate input test data, or load pre-generated data.
% [pdcInputDataStruct] = generate_pdc_test_data;
load(fullfile(pdcTestDataDir, 'pdc-inputs-0.mat'));
pdcInputDataStruct = inputsStruct;
clear inputsStruct;
% trim the number of targets 
pdcInputDataStruct.targetDataStruct = pdcInputDataStruct.targetDataStruct(1:10);

% Write to, and read from, auto-generated scripts for input.
inputFileName = 'inputs-0.bin';
write_PdcInputs(inputFileName, pdcInputDataStruct);
[pdcInputDataStructNew] = read_PdcInputs(fullfile(pdcTestDataDir, 'pdc-inputs-0.bin'));
delete(inputFileName);

pdcInputDataStructNew.targetDataStruct = pdcInputDataStructNew.targetDataStruct(1:10);

% Convert to floats for assert equals test.
[pdcInputDataStruct] = convert_struct_fields_to_float(pdcInputDataStruct);
[pdcInputDataStructNew] = convert_struct_fields_to_float(pdcInputDataStructNew);

% Compare structures that are written to and read back from a bin file.
messageOut = 'pdc_matlab_controller - data generated and read back by read_PdcInputs are not identical!';
assert_equals(pdcInputDataStructNew, pdcInputDataStruct, messageOut);

%--------------------------------------------------------------------------
% Generate output test data.
%--------------------------------------------------------------------------
[pdcResultsStruct] = pdc_matlab_controller(pdcInputDataStruct);

% Write to, and read from, auto-generated scripts for output.
outputFileName = 'outputs-0.bin';
write_PdcOutputs(outputFileName, pdcResultsStruct);
[pdcResultsStructNew] = read_PdcOutputs(outputFileName);
delete(outputFileName);

% Convert to floats for assert equals test.
[pdcResultsStruct] = convert_struct_fields_to_float(pdcResultsStruct);
[pdcResultsStructNew] = convert_struct_fields_to_float(pdcResultsStructNew);

% Compare structures that are written to and read back from a bin file.
messageOut = 'pdc_matlab_controller - results received and read back by read_PdcOutputs are not identical!';
assert_equals(pdcResultsStruct, pdcResultsStructNew, messageOut);

%{
% Optional: save test results. 
testResults = struct( ...
    'pdcInputDataStruct', pdcInputDataStruct, ... 
    'pdcInputDataStructNew', pdcInputDataStructNew, ...
    'pdcResultsStruct', pdcResultsStruct, ...
    'pdcResultsStructNew', pdcResultsStructNew);
save('test_matlab_controller_results.mat', 'testResults'); 
%}

% Return.
return
