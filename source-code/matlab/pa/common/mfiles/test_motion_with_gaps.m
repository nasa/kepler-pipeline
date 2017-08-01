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
clear;
load paTestData_run1000_700Cadences_targetGaps targetStarStruct

nTargets = length(targetStarStruct);
for target = 1:nTargets
    nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
    for pixel = 1:nPixels 
        gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;    
    end
end
motionPolyTargetGaps = module_output_motion(targetStarStruct, 5);

load gapVsNogapMotionPoly.mat motionPolyGaps moduleOutputMotionPolyStruct

% save gapVsNogapMotionPoly.mat motionPolyGaps motionPolyTargetGaps moduleOutputMotionPolyStruct

%%
load gapVsNogapMotionPoly.mat motionPolyTargetGaps moduleOutputMotionPolyStruct

test_ccd_motion(motionPolyTargetGaps, moduleOutputMotionPolyStruct);


%%

load gapVsNogapMotionPoly.mat motionPolyGaps motionPolyTargetGaps moduleOutputMotionPolyStruct
load paTestData_run1000_700Cadences targetStarStruct
cosmicRayConfigurationStruct = build_cr_configuration_struct;

numPixels = 0;
for target = 1:length(targetStarStruct)
    targetStruct = targetStarStruct(target);
    for pixel = 1:length(targetStruct.pixelTimeSeriesStruct);
        numPixels = numPixels + length(targetStruct.pixelTimeSeriesStruct(pixel));
    end
end
numPixels
stdRatio = zeros(numPixels, 1);
stdRatioTargetGaps = zeros(numPixels, 1);
pixNum = 1;
for target = 1:length(targetStarStruct)
    targetStruct = targetStarStruct(target);
    for pixel = 1:length(targetStruct.pixelTimeSeriesStruct);
        p = targetStruct.pixelTimeSeriesStruct(pixel);
        fitStruct_nomotion = detrend_time_series(p.timeSeries, p.row, p.column, [], cosmicRayConfigurationStruct);
        fitStruct_gaps = detrend_time_series(p.timeSeries, p.row, p.column, motionPolyGaps, cosmicRayConfigurationStruct);
        fitStruct_nogaps = detrend_time_series(p.timeSeries, p.row, p.column, moduleOutputMotionPolyStruct, cosmicRayConfigurationStruct);
        fitStruct_targetgaps = detrend_time_series(p.timeSeries, p.row, p.column, motionPolyTargetGaps, cosmicRayConfigurationStruct);
        stdnoGaps(pixNum) = std(fitStruct_nogaps.residual);
        stdPixelGaps(pixNum) = std(fitStruct_gaps.residual);
        stdTargetGaps(pixNum) = std(fitStruct_targetgaps.residual);
        stdNoMotion(pixNum) = std(fitStruct_nomotion.residual);
        pixNum = pixNum + 1;
    end
end

save gapVsNogapMotionPoly.mat motionPolyGaps motionPolyTargetGaps moduleOutputMotionPolyStruct stdnoGaps stdPixelGaps stdTargetGaps stdNoMotion

%%

load gapVsNogapMotionPoly.mat motionPolyGaps motionPolyTargetGaps moduleOutputMotionPolyStruct stdnoGaps stdPixelGaps stdTargetGaps stdNoMotion
load paTestData_run1000_700Cadences targetStarStruct

pixNum = 1;
for target = 1:length(targetStarStruct)
    targetStruct = targetStarStruct(target);
    for pixel = 1:length(targetStruct.pixelTimeSeriesStruct);
        targetMap(pixNum) = target;
        pixNum = pixNum + 1;
    end
end
stdRatio = stdPixelGaps./stdnoGaps;
stdRatioTargetGaps = stdTargetGaps./stdnoGaps;
stdRatioNoMotion = stdNoMotion./stdnoGaps;

close all

figure
plot([stdNoMotion', stdTargetGaps', stdnoGaps'])
title('standard deviation of each pixel');
legend('no motion regression', 'target-level gaps filled', 'no gaps');

figure
hist(stdRatio, 1000)
title('pixel level gaps');
figure
hist(stdRatioTargetGaps, 1000)
title('target level gaps');
figure
hist(stdRatioNoMotion, 1000)
title('no motion detrend');

highRatio2 = stdRatio > 3;
highRatio = stdRatio > 1.5;
lowRatio = stdRatio < 1.1;
lowRatio2 = stdRatio < 1.3;
display('pixel level gaps:');
display([num2str(100*sum(lowRatio)/length(stdRatio)) '% have a std ratio < 1.1']);
display([num2str(100*sum(lowRatio2)/length(stdRatio)) '% have a std ratio < 1.3']);
display([num2str(100*sum(highRatio)/length(stdRatio)) '% have a std ratio > 1.5']);
display([num2str(100*sum(highRatio2)/length(stdRatio)) '% have a std ratio > 3']);

highRatio2 = stdRatioTargetGaps > 3;
highRatio = stdRatioTargetGaps > 1.5;
lowRatio = stdRatioTargetGaps < 1.1;
lowRatio2 = stdRatioTargetGaps < 1.3;
display('target level gaps:');
display([num2str(100*sum(lowRatio)/length(stdRatioTargetGaps)) '% have a std ratio < 1.1']);
display([num2str(100*sum(lowRatio2)/length(stdRatioTargetGaps)) '% have a std ratio < 1.3']);
display([num2str(100*sum(highRatio)/length(stdRatioTargetGaps)) '% have a std ratio > 1.5']);
display([num2str(100*sum(highRatio2)/length(stdRatioTargetGaps)) '% have a std ratio > 3']);

highRatio2 = stdRatioNoMotion > 3;
highRatio = stdRatioNoMotion > 1.5;
lowRatio = stdRatioNoMotion < 1.1;
lowRatio2 = stdRatioNoMotion < 1.3;
display('no motion detrend:');
display([num2str(100*sum(lowRatio)/length(stdRatioTargetGaps)) '% have a std ratio < 1.1']);
display([num2str(100*sum(lowRatio2)/length(stdRatioTargetGaps)) '% have a std ratio < 1.3']);
display([num2str(100*sum(highRatio)/length(stdRatioTargetGaps)) '% have a std ratio > 1.5']);
display([num2str(100*sum(highRatio2)/length(stdRatioTargetGaps)) '% have a std ratio > 3']);
