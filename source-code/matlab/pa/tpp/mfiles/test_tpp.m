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
clear;
clear classes;

load ../../common/mfiles/paTestData_run1000_100Cadences_nogaps;

backgroundConfigurationStruct = build_background_configuration_struct();
cosmicRayConfigurationStruct = build_cr_configuration_struct();
nCadences = length(targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);
nTargets = length(targetStarStruct);

backgroundBlobStruct(1).blob = struct_to_blob(backgroundCoeffStruct);
backgroundBlobStruct(1).startCadence = 1;
backgroundBlobStruct(1).endCadence = length(backgroundCoeffStruct);

motionBlobStruct(1).blob = struct_to_blob(moduleOutputMotionPolyStruct);
motionBlobStruct(1).startCadence = 1;
motionBlobStruct(1).endCadence = length(moduleOutputMotionPolyStruct);

nTargets = length(targetStarStruct);
for target = 1:nTargets
    nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
    nCadences = length(targetStarStruct(target).pixelTimeSeriesStruct(1).timeSeries);
    % introduce (pre-assigned) data gaps
    preGapSeries = zeros(nPixels, nCadences);
    for pixel = 1:nPixels
        preGapSeries(pixel, :) = targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries;
        gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
    end
end

tppParameterStruct.targetStarStruct = targetStarStruct;
tppParameterStruct.motionBlobStruct = motionBlobStruct;
tppParameterStruct.backgroundBlobStruct = backgroundBlobStruct;
tppParameterStruct.backgroundConfigurationStruct = backgroundConfigurationStruct;
tppParameterStruct.cosmicRayConfigurationStruct = cosmicRayConfigurationStruct;

tppParameterStruct.ancillaryDataStruct.values = [];
tppParameterStruct.ancillaryDataStruct.uncertainties = [];
tppParameterStruct.ancillaryDataStruct.timestamps = [];
tppParameterStruct.ancillaryDataStruct.dataGapIndicators = [];
tppParameterStruct.ancillaryDataStruct.mnemonic = 'test';

tppParameterStruct.tppConfigurationStruct.startCadence = 1;
tppParameterStruct.tppConfigurationStruct.endCadence = nCadences;
tppParameterStruct.tppConfigurationStruct.cadenceType = 1;
tppParameterStruct.tppConfigurationStruct.ccdModule = 18;
tppParameterStruct.tppConfigurationStruct.ccdOutput = 1;
tppParameterStruct.tppConfigurationStruct.cleanCosmicRays = 1;
tppParameterStruct.debugFlag = 0;

tppResultStruct = tpp_matlab_controller(tppParameterStruct);


