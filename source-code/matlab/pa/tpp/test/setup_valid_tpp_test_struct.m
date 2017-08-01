function tppParameterStruct = setup_valid_tpp_test_struct()
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

nCadences = 10;
for target = 1:3
    targetStarStruct(target).referenceRow = fix(900*rand(1,1) + 30);
    targetStarStruct(target).referenceColumn = fix(900*rand(1,1) + 30);
    targetStarStruct(target).gapList = [];
    for pixel=1:4
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).row = ...
            targetStarStruct(target).referenceRow + fix(pixel/2) - 1;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).column = ...
            targetStarStruct(target).referenceColumn + fix((pixel+1)/2) - 1;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries = ...
            1e6 + 1e4*randn(1,1) + 1e2*randn(nCadences,1);
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties = ...
            sqrt(targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries);
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList = sort(unique(ceil(8*rand(3,1))));
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).isInOptimalAperture = 1;
    end
end

% replace gap values with zero
nTargets = length(targetStarStruct);
for target = 1:nTargets
    nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
    nCadences = length(targetStarStruct(target).pixelTimeSeriesStruct(1).timeSeries);
    % introduce (pre-assigned) data gaps
    for pixel = 1:nPixels
        gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
    end
end

tppParameterStruct.targetStarStruct = targetStarStruct;
tppParameterStruct.backgroundConfigurationStruct = build_background_configuration_struct();
tppParameterStruct.cosmicRayConfigurationStruct = build_cr_configuration_struct();
tppParameterStruct.debugFlag = 0;

for f=1:3
    tppParameterStruct.ancillaryDataStruct(f).values = 1e2*randn(nCadences,1);
    tppParameterStruct.ancillaryDataStruct(f).uncertainties = randn(nCadences,1);
    tppParameterStruct.ancillaryDataStruct(f).timestamps = 30*60*(1:nCadences); % seconds
    tppParameterStruct.ancillaryDataStruct(f).dataGapIndicators = zeros(nCadences);
    tppParameterStruct.ancillaryDataStruct(f).mnemonic = ['test' num2str(f)];
end

tppParameterStruct.tppConfigurationStruct.startCadence = 1;
tppParameterStruct.tppConfigurationStruct.endCadence = nCadences;
tppParameterStruct.tppConfigurationStruct.cadenceType = 1;
tppParameterStruct.tppConfigurationStruct.ccdModule = 8;
tppParameterStruct.tppConfigurationStruct.ccdOutput = 1;
tppParameterStruct.tppConfigurationStruct.cleanCosmicRays = 1;

tppParameterStruct.backgroundCoeffStruct = make_weighted_poly(2, ...
    tppParameterStruct.backgroundConfigurationStruct.fitLowOrder, ...
    nCadences);
tppParameterStruct.backgroundGaps = [2,6];
for c=1:nCadences
    tppParameterStruct.motionPolyStruct(c).rowCoeff = make_weighted_poly(2, ...
        5, 1);
    tppParameterStruct.motionPolyStruct(c).columnCoeff = make_weighted_poly(2, ...
        5, 1);
end
tppParameterStruct.motionGaps = [1,7];


