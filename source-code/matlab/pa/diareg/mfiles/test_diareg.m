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

load ../../common/mfiles/paTestData_run1000_700Cadences_nogaps;
load ../../common/mfiles/backgroundCoeffStruct_run1000_700Cadences_nogaps;

backgroundConfigurationStruct = build_background_configuration_struct();
cosmicRayConfigurationStruct = build_cr_configuration_struct();
nCadences = length(targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);
nTargets = length(targetStarStruct);

backgroundBlobStruct(1).blob = struct_to_blob(backgroundCoeffStruct);
backgroundBlobStruct(1).startCadence = 1;
backgroundBlobStruct(1).endCadence = length(backgroundCoeffStruct);

regRun = 1;
cadenceChunkSize = 400;
for cadence = 1:cadenceChunkSize:nCadences
    thisCadenceChunkSize = cadenceChunkSize;
    if nCadences - cadence < thisCadenceChunkSize
        thisCadenceChunkSize = nCadences - cadence;
    end
    cadenceChunk = cadence:cadence+thisCadenceChunkSize;
    
    chunkTargetStarStruct = targetStarStruct;
    for target = 1:nTargets
        nPixels = length(chunkTargetStarStruct(target).pixelTimeSeriesStruct);
        % introduce (pre-assigned) data gaps
        for pixel = 1:nPixels
            chunkTargetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries = ...
                targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(cadenceChunk);
            chunkTargetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties = ...
                targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties(cadenceChunk);
            
            gapList = intersect(cadenceChunk, targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList) ...
                - cadence + 1;
            chunkTargetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList = gapList;
%             chunkTargetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
        end
        chunkTargetStarStruct(target).gapList = [];
    end
    
    diaregParameterStruct.targetStarStruct = chunkTargetStarStruct;
    diaregParameterStruct.motionBlobStruct = [];
    diaregParameterStruct.backgroundBlobStruct = backgroundBlobStruct;
    diaregParameterStruct.backgroundConfigurationStruct = backgroundConfigurationStruct;
    diaregParameterStruct.cosmicRayConfigurationStruct = cosmicRayConfigurationStruct;
    diaregParameterStruct.diaregConfigurationStruct.startCadence = cadence;
    diaregParameterStruct.diaregConfigurationStruct.endCadence = cadence+thisCadenceChunkSize;
    diaregParameterStruct.diaregConfigurationStruct.iterativeRegistration = 0;
    diaregParameterStruct.diaregConfigurationStruct.cleanCosmicRays = 0;
    diaregParameterStruct.diaregConfigurationStruct.motionPolynomialOrder = 5;
    diaregParameterStruct.debugFlag = 1;

    diaregResultStruct = diareg_matlab_controller(diaregParameterStruct);
    
    motionBlobStruct(regRun).blob = diaregResultStruct.motionCoeffBlob;
    motionBlobStruct(regRun).startCadence = cadence;
    motionBlobStruct(regRun).endCadence = cadence+thisCadenceChunkSize;
    regRun = regRun + 1;
end

