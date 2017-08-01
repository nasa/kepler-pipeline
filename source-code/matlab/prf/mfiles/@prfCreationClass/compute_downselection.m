function prfCreationObject = compute_downselection(prfCreationObject)
% function prfCreationObject = compute_downselection(prfCreationObject)
% 
% compute the down selection criteria based on configuration parameters
% Sets the .selectedTarget flag in each target's structure
%
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

magnitudeRange = prfCreationObject.prfConfigurationStruct.magnitudeRange;
crowdingThreshold = prfCreationObject.prfConfigurationStruct.crowdingThreshold;
rowLimit = prfCreationObject.prfConfigurationStruct.rowLimit;
columnLimit = prfCreationObject.prfConfigurationStruct.columnLimit;

targetStarsStruct = prfCreationObject.targetStarsStruct;

% look at on-point cadence[
baseCadence = prfCreationObject.prfConfigurationStruct.baseAttitudeIndex;
goodCadences = ~prfCreationObject.cadenceTimes.gapIndicators;
    
% compute the extended crowding metric 
% = tadCrowdingMetric * (flux in optimal ap)/(flux in mask)
% normalized so that the least crowded star has extended crowding
% metric = 1
for t=1:length(targetStarsStruct)
    pixelStruct = targetStarsStruct(t).pixelTimeSeriesStruct;
    
    pixVals = [pixelStruct.values];
    % find the pixels in the optimal aperture
    inOptAp = [pixelStruct.isInOptimalAperture];
    
    % flux in target's mask
    maskFlux = sum(pixVals(baseCadence, :));
    % flux in target's optimal aperture
    optimalApFlux = sum(pixVals(baseCadence, inOptAp));
    prfCreationObject.targetStarsStruct(t).fluxRatio = optimalApFlux/maskFlux;
    prfCreationObject.targetStarsStruct(t).extendedCrowdingMetric ...
        = targetStarsStruct(t).tadCrowdingMetric * optimalApFlux/maskFlux;
end
% find the target with the highest extended crowding metric
% maxVal = max([prfCreationObject.targetStarsStruct.extendedCrowdingMetric]);
% 
% % normalize the extended crowding metric
% for t=1:length(targetStarsStruct)
%     prfCreationObject.targetStarsStruct(t).extendedCrowdingMetric ...
%         = prfCreationObject.targetStarsStruct(t).extendedCrowdingMetric/maxVal;
% end

for t=1:length(targetStarsStruct)
    targetStruct = prfCreationObject.targetStarsStruct(t);
    prfCreationObject.targetStarsStruct(t).selectedTarget ...
        = targetStruct.keplerMag >= magnitudeRange(1) ...
        && targetStruct.keplerMag <= magnitudeRange(2) ...
        && targetStruct.extendedCrowdingMetric >= crowdingThreshold ...
        && targetStruct.row(1) >= rowLimit(1) ...
        && targetStruct.row(1) <= rowLimit(2) ...
        && targetStruct.keplerId ~= 7880048 ...
        && targetStruct.keplerId ~= 5472344 ...
        && targetStruct.keplerId ~= 5682974 ...
        && targetStruct.keplerId ~= 6100142 ...
        && targetStruct.column(1) >= columnLimit(1) ...
        && targetStruct.column(1) <= columnLimit(2);
end
