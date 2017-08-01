% this script creates small test input data for 
% tests for pa/common 
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% build test data sets for time series objects

run = 1000;
runStr = ['run' num2str(run)];

% basic time series file does not exist so create it
[targetStarStruct, backgroundStruct, smearStruct, leadingBlackStruct] = ...
    build_time_series(...
    '/path/to/ETEM/Results/', ...
    run, 'long_cadence_q_black_gcr_', 1000);

% insert data gaps into the targetStarStruct and backgroundStruct
completeness = 0.95;

% build a target time series file
[targetStarStruct, backgroundStruct] = ...
    insert_data_gaps(targetStarStruct, backgroundStruct, completeness);

moduleOutputMotionPolyStruct = module_output_motion(targetStarStruct);
cosmicRayConfigurationStruct = build_cr_configuration_struct();
backgroundConfigurationStruct = build_background_configuration_struct();

testTargetStruct(1) = targetStarStruct(2); % saturated star
testTargetStruct(2) = targetStarStruct(388); % eclipsing binary 
testTargetStruct(3) = targetStarStruct(1600); % dim star

% insert data gaps in the target pixels 
nTargets = length(testTargetStruct);
for target = 1:nTargets
    nPixels = length(testTargetStruct(target).pixelTimeSeriesStruct);
    for pixel = 1:nPixels
        gapList = testTargetStruct(target).pixelTimeSeriesStruct(pixel).gapList;
        testTargetStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
    end
end

save('paCommonTargetTestData.mat', 'testTargetStruct', ...
    'moduleOutputMotionPolyStruct', 'cosmicRayConfigurationStruct');

% build a background time series file
testBackgroundStruct = backgroundStruct(100:110);
% insert data gaps in the background pixels 
nPixels = length(testBackgroundStruct);
for pixel = 1:nPixels
    gapList = testBackgroundStruct(pixel).gapList;
    testBackgroundStruct(pixel).timeSeries(gapList) = 0;
end

testBackgroundStruct = backgroundStruct(100:110);
save('paCommonBackgroundTestData.mat', 'testBackgroundStruct', ...
    'cosmicRayConfigurationStruct', 'backgroundConfigurationStruct');

% build a background polynomial coefficients test file
backgroundCoeffStruct = fit_background_by_time_series(backgroundStruct, ...
    backgroundConfigurationStruct);
save('paCommonBgCoeffTestData.mat', 'backgroundCoeffStruct', ...
    'backgroundConfigurationStruct');

