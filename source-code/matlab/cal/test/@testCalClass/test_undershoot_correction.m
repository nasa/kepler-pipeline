function test_undershoot_correction
%--------------------------------------------------------------------------
%function test_undershoot_correction
% test_undershoot_correction checks the undershoot correction as follows
%
%
% to correct pixels for undershoot, we apply filter function:
%
% y = filter(b,a,X) filters the data in vector X with the filter described by
% numerator coefficient vector b and denominator coefficient vector a.
%
% where a = undershootCoeffts(1,:) = [1.1  2.2  3.3  4.4]
%       b = 1
%
% for this test, we extract the coeffts from FC, and apply the reverse filter
% to the data (a = 1, b = coeffts), then run the data through correct_collateral_pix_for_undershoot
% and compare the results
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testCalCollateralClass('test_undershoot_correction'));
%
% Read in input structure
% Input: A data structure 'calIntermediateStruct' is loaded internally
%
%--------------------------------------------------------------------------
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

% load tmp struct for this test:
load undershootTestData.mat calIntermediateStruct calObject

% save original smear pixels for comparison
mSmearPixelsOriginal = calIntermediateStruct.mSmearPixels;

% extract current module/output
ccdModule = calObject.ccdModule;
ccdOutput = calObject.ccdOutput;

% extract timestamps (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamps = cadenceTimes.timestamps;
nCadences = length(timestamps);

%--------------------------------------------------------------------------
% retrieve undershoot model
%--------------------------------------------------------------------------
undershootModel = calObject.undershootModel;

% create the undershoot object
undershootObject = undershootClass(undershootModel);

% get the coefficients of the undershoot filter
undershootCoeffts = get_undershoot(undershootObject, timestamps, ccdModule, ccdOutput);


% extract logical flags for existence of any masked or virtual smear pixels:
availableMsmearPixels = calIntermediateStruct.availableMsmearPixels;
availableVsmearPixels = calIntermediateStruct.availableVsmearPixels;

%--------------------------------------------------------------------------
% apply forward filter to masked smear pixels for under/overshoot
%--------------------------------------------------------------------------
if (availableMsmearPixels)

    % smear pixels have already been black corrected and linearity corrected
    mSmearPixels = calIntermediateStruct.mSmearPixels;
    mSmearGaps = calIntermediateStruct.mSmearGaps;

    for cadenceIndex = 1:nCadences

        validPixelIndices = ~mSmearGaps(:, cadenceIndex);

        pixelRowToCorrect = mSmearPixels(validPixelIndices, cadenceIndex);

        %--------------------------------------------------------------------------
        % apply reverse filter
        %--------------------------------------------------------------------------
        undershootCorrectedRow = filter(undershootCoeffts(cadenceIndex, :), 1, pixelRowToCorrect);

        %--------------------------------------------------------------------------
        % save corrected pixels
        calIntermediateStruct.mSmearPixels(validPixelIndices, cadenceIndex) = undershootCorrectedRow;
    end
end

%--------------------------------------------------------------------------
% apply filter via correct_collateral_pix_for_undershoot
%--------------------------------------------------------------------------
[calObject, calIntermediateStructNew] = ...
    correct_collateral_pix_for_undershoot(calObject, calIntermediateStruct);

mSmearPixelsCorrected = calIntermediateStructNew.mSmearPixels;

% compare mSmearPixelsOriginal with mSmearPixelsCorrected

if (~isequal(mSmearPixelsOriginal, mSmearPixelsCorrected))
messageOut = 'test_undershoot_correction - undershoot-induced and corrected pixel values are not equal to original pixel values!';
assert_equals(1, 0, messageOut);
end


return;