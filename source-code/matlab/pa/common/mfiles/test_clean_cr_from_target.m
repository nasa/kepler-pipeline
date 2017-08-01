% This script performs a simple test of cosmic ray cleaning on a specified
% target with gaps in the loaded data set.  Create the required data sets
% by the following process:
% edit make_pa_test_data to point at an ETEM output directory
% execute make_pa_test_data, which creates targetStarStruct
% execute moduleOutputMotionPolyStruct = module_output_motion(targetStarStruct)
% save moduleOutputMotionPolyStruct.mat moduleOutputMotionPolyStruct
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

close all;
clear targetStarStruct moduleOutputMotionPolyStruct;

load paTestData_run1000_700cadences
load gapVsNogapMotionPoly.mat moduleOutputMotionPolyStruct

% target = 1087; % mag 15 star
target = 388; % good mag 13.6 large transit in 700 cadences
% target = 996; % good mag 14.88 large transit in 700 cadences
% targetStruct = targetStarStruct(target);
cosmicRayConfigurationStruct = build_cr_configuration_struct();

nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
nCadences = length(targetStarStruct(target).pixelTimeSeriesStruct(1).timeSeries);
% introduce (pre-assigned) data gaps
preGapSeries = zeros(nPixels, nCadences);
for pixel = 1:nPixels
%     targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList = [];
    preGapSeries(pixel, :) = targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries;
    gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
    targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
end
% % remove (pre-assigned) data gaps
% for pixel = 1:nPixels
%     targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList = [];
% end


% % add an anti-transit
% antiTransit = ones(size(targetStarStruct(target).pixelTimeSeriesStruct(1).timeSeries));
% % make it 8 hours = 16 transits long
% antiTransitStart = fix(rand(1,1)*(length(antiTransit) - 30)) + 10;
% antiTransit(antiTransitStart:antiTransitStart+16) = ...
%     antiTransit(antiTransitStart:antiTransitStart+16) + 5e-4;
% for pixel = 1:nPixels
%     targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries = ...
%         antiTransit.*targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries;
% end

tic;
targetStruct = ...
    clean_cosmic_ray_from_target(targetStarStruct(target), ...
    moduleOutputMotionPolyStruct, cosmicRayConfigurationStruct);
toc

if 1
    pixval = zeros(nPixels, nCadences);
    cleanedPixval = zeros(nPixels, nCadences);
    for pixel = 1:nPixels 
        pixval(pixel, :) = ...
            targetStruct.pixelTimeSeriesStruct(pixel).timeSeries;
        cleanedPixval(pixel, :) = ...
            targetStruct.pixelTimeSeriesStruct(pixel).crCleanedSeries;
    end
    flux  = sum(pixval, 1); 
    cleanedFlux  = sum(cleanedPixval, 1); 
    preGapFlux  = sum(preGapSeries, 1); 

    figure;
    plot(1:nCadences, preGapFlux , 1:nCadences, flux, '+', 1:nCadences, cleanedFlux, 'r--');
    legend('pre-gap flux', 'flux', 'cleaned flux');
end
