function self = test_compare_stored_and_generated_long_gap_fill_results(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_compare_stored_and_generated_results(self)
% This test loads stored verified results and also loads the same input
% sructure and compares the generated results with the verified results.
%
%
% If the regression test fails, an error condition occurs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testPdcClass('test_compare_stored_and_generated_long_gap_fill_results'));
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

% load saved results
randn('state', 0);
load longGapFillResultsSaved.mat;

% This loads the following structures: (1) gapFillParametersStruct
% (2) pdcLongGapFillInputs (3) pdcLongGapFillOutputs

% gapFillParametersStruct =
%                                   MAD_X_FACTOR: 10
%            MAX_GIANT_TRANSIT_DURATION_IN_HOURS: 72
%                         MAX_DETREND_POLY_ORDER: 25
%                             MAX_AR_ORDER_LIMIT: 25
%                MAX_CORRELATION_WINDOW_X_FACTOR: 5
%                    CADENCE_DURATION_IN_MINUTES: 30
%     GAP_FILL_MODE_IS_ADD_BACK_PREDICTION_ERROR: 1

% pdcLongGapFillInputs = 
%                          flux: [4464x5 double]
%                  fluxWithGaps: [4464x5 double]
%                   indexEarths: 2
%                 indexJupiters: 5
%                 indexRefLight: 3
%                  indexBgStars: 4
%                indexSaturated: 1
%             dataGapIndicators: [4464x1 logical]
%                      gapSizes: [1152x1 double]
%                     debugFlag: 0
%     scalingFilterCoefficients: [12x1 double]

% pdcLongGapFillOutputs = 
%     fluxWithGapsFilled: [4464x5 double]



dataGapIndicators = pdcLongGapFillInputs.dataGapIndicators;
debugFlag = pdcLongGapFillInputs.debugFlag;
[nCadences, nFlux] = size(pdcLongGapFillInputs.flux);

pdcLongGapFillOutputsNew.fluxWithGapsFilled = zeros(nCadences, nFlux);
scalingFilterCoefficients = pdcLongGapFillInputs.scalingFilterCoefficients;
powerOfTwoLengthFlag = pdcLongGapFillInputs.powerOfTwoLengthFlag ;


for ii = 1:nFlux

    fluxWithGaps = pdcLongGapFillInputs.fluxWithGaps(:,ii);
    

    indexOfAstroEvents = 0;
    [reconstructedFilledTimeSeries] = ...
        fill_long_data_gaps(fluxWithGaps, dataGapIndicators,  indexOfAstroEvents, scalingFilterCoefficients, debugFlag, gapFillParametersStruct, powerOfTwoLengthFlag);

    pdcLongGapFillOutputsNew.fluxWithGapsFilled(:,ii) =   reconstructedFilledTimeSeries(1:nCadences);

   
end


messageOut = 'Regression test failed - stored results and generated results are not identical!';
assert_equals(pdcLongGapFillOutputsNew, pdcLongGapFillOutputs, messageOut);
