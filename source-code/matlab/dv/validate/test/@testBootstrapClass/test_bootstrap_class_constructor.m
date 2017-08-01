%% test_bootstrap_class_constructor
%
% [self] = test_bootstrap_class_constructor(self)
%
% Tests the outputs of the bootstrap class constructor
%
% Run with:
%   run(text_test_runner, testBootstrapClass('test_bootstrap_class_constructor'));
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
function [self] = test_bootstrap_class_constructor(self)

% Add test-meta-data path
initialize_soc_variables;
testMetaDataRoot = fullfile(socTestMetaDataRoot, 'dv', 'unit-tests', 'bootstrap');
addpath(testMetaDataRoot);

% Generate the bootstrapInputStruct  has 1 struct for singleEventStatistics
bootstrapInputStruct = generate_bootstrapinputstruct_with_soho_data;

%--------------------------------------------------------------------------
% Test degap_ses subfunction and that the two if statements will be
% triggered if there is an anomaly with singleEventStatistics
%--------------------------------------------------------------------------

% Replicate 5 "good" singleEventStatistics from the original
bootstrapInputStruct.singleEventStatistics(2:5) = ...
    bootstrapInputStruct.singleEventStatistics(1);

% Make 1st singleEventStatistics trigger first return in degap_ses
% subfunction.  This represents a case of mismatched gap indicators in 
% correlation and normalization time series.
bootstrapInputStruct.singleEventStatistics(1).correlationTimeSeries.gapIndicators(1:10) = true;

% Make 4th singleEventStatistics trigger second return in degap_ses, this
% represents the case scenario where all datapoints are gapped
bootstrapInputStruct.singleEventStatistics(4).correlationTimeSeries.gapIndicators(1:end)= true; % all gapped
bootstrapInputStruct.singleEventStatistics(4).normalizationTimeSeries.gapIndicators(1:end)= true;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

% numberPulseWidths should now be 3 after eliminating two.
numberPulseWidths = get(bootstrapObject, 'numberPulseWidths');
assert_equals(numberPulseWidths, 3, 'Expected 3 pulse widths');

%--------------------------------------------------------------------------
% Test that numberPulseWidths will be set to zero if all
% singleEventStatistics are anolamous, and that nullTailMaxSigma and
% nullTailMinSigma will not be computed
%--------------------------------------------------------------------------

% Make 2nd  through 5th singleEventStatistics invalid by assigning it the first
% singleEventStatitics, which is already invalid
bootstrapInputStruct.singleEventStatistics(2:5) = ...
    bootstrapInputStruct.singleEventStatistics(1);

bootstrapObject = bootstrapClass(bootstrapInputStruct);

numberPulseWidths = get(bootstrapObject, 'numberPulseWidths');
assert_equals(numberPulseWidths, 0);

% Check that nullTailMaxSigma and nullTailMinSigma remain 0 because code
% does not enter the if section
nullTailMaxSigma  = get(bootstrapObject, 'nullTailMaxSigma');
nullTailMinSigma  = get(bootstrapObject, 'nullTailMinSigma');

assert_equals(nullTailMaxSigma, 0, 'Expected nullTailMax=0');
assert_equals(nullTailMinSigma, 0, 'Expected nullTailMin=0');

%--------------------------------------------------------------------------
% test get_histogram_limits called by the constructor determines the 
% correct nullTailMaxSimga 
%--------------------------------------------------------------------------

clear bootstrapInputStruct

% Regenerate "good" bootstrapInputsStruct
bootstrapInputStruct = generate_bootstrapinputstruct_with_soho_data;

%--------------------------------------------------------------------------
% If max multipleEventStatistics = 8.5945 (if numTransits = 4 for sample SES), 
% and binWidth is at 0.1, and searchTranisThreshold = 7.1, 
% nullTailMaxSigma will be set at 8.60
%--------------------------------------------------------------------------
bootstrapInputStruct.searchTransitThreshold = 7.1;
bootstrapInputStruct.observedTransitCount = 4;
bootstrapInputStruct.histogramBinWidth = 0.1;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

nullTailMaxSigma = get(bootstrapObject, 'nullTailMaxSigma');
assert_equals(nullTailMaxSigma, 8.6, 'Expected nullTailMaxSigma to be 8.6')

%--------------------------------------------------------------------------
% If max multipleEventStatistics = 8.5945 (if numTransits = 4 for sample SES),
% and binWidth is at 0.05, and searchTransitThreshold = 7.100
% nullTailMaxSigma will be set at 8.60
%--------------------------------------------------------------------------
bootstrapInputStruct.searchTransitThreshold = 7.1;
bootstrapInputStruct.observedTransitCount = 4;
bootstrapInputStruct.histogramBinWidth = 0.05;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

nullTailMaxSigma = get(bootstrapObject, 'nullTailMaxSigma');
assert_equals(nullTailMaxSigma, 8.60, 'Expected nullTailMaxSigma to be 8.60')

%--------------------------------------------------------------------------
% If max multipleEventStatistics = 8.5945 (if numTransits = 4 for sample SES),
% and binWidth is at 0.2 and searchTransitThreshold = 7.100
% nullTailMaxSigma will be set at 8.70
%--------------------------------------------------------------------------
bootstrapInputStruct.searchTransitThreshold = 7.1;
bootstrapInputStruct.observedTransitCount = 4;
bootstrapInputStruct.histogramBinWidth = 0.2;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

nullTailMaxSigma = get(bootstrapObject, 'nullTailMaxSigma');
assert_equals(nullTailMaxSigma, 8.70, 'Expected nullTailMaxSigma to be 8.70')

%--------------------------------------------------------------------------
% If max multipleEventStatistics = 8.5945 (if numTransits = 4 for sample SES),
% and binWidth is at 0.1 and searchTransitThreshold = 8.6
% nullTailMaxSigma will be set at 8.6
%--------------------------------------------------------------------------
bootstrapInputStruct.searchTransitThreshold = 8.6;
bootstrapInputStruct.observedTransitCount = 4;
bootstrapInputStruct.histogramBinWidth = 0.1;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

nullTailMaxSigma = get(bootstrapObject, 'nullTailMaxSigma');
assert_equals(nullTailMaxSigma, 8.60, 'Expected nullTailMaxSigma to be 8.60')

%--------------------------------------------------------------------------
% If max multipleEventStatistics = 8.5945 (if numTransits = 4 for sample SES),
% and binWidth is at 0.1 and searchTransitThreshold = 8.5016
% nullTailMaxSigma will be set at 8.6015
%--------------------------------------------------------------------------
bootstrapInputStruct.searchTransitThreshold = 8.5016;
bootstrapInputStruct.observedTransitCount = 4;
bootstrapInputStruct.histogramBinWidth = 0.1;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

nullTailMaxSigma = get(bootstrapObject, 'nullTailMaxSigma');
assert_equals(nullTailMaxSigma, 8.6016, 'Expected nullTailMaxSigma to be 8.6016')

%--------------------------------------------------------------------------
% If max multipleEventStatistics = 8.5945 (if numTransits = 4 for sample SES),
% and binWidth is at 0.05 and searchTransitThreshold = 8.4015
% nullTailMaxSigma will be set at 8.5515
%--------------------------------------------------------------------------
bootstrapInputStruct.searchTransitThreshold = 8.4015;
bootstrapInputStruct.observedTransitCount = 4;
bootstrapInputStruct.histogramBinWidth = 0.05;

bootstrapObject = bootstrapClass(bootstrapInputStruct);

nullTailMaxSigma = get(bootstrapObject, 'nullTailMaxSigma');
assert_equals(nullTailMaxSigma, 8.6015, 'Expected nullTailMaxSigma to be 8.6015')

rmpath(testMetaDataRoot);

return
