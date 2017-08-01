%************************************************************************************************************
% function [] = map_do_quick_map (mapData, mapInput)
%
% Right now this is intended to only be used with Short Cadence data. It may also work for Long Cadence but
% not tested to do so. SO TEST BEFORE YOU USE WITH LC DATA!
% 
% This will perform a Bayesian fit to a combination of a robust fit to the basis vectors and the LC MAP fit
% (if available):
%
%   quickMapFitCoeffs = (1-priorWeight) robustFitCoeffs + priorWeight * lcMapFitCoeffs
%
%   priorWeight = priorGoodness * priorVariabilityWeight
%   priorVariabilityWeight =  1 - (1 ./ max(variability^scaling,1.0))
%
%   where the priorGoodness uses a method similar to what's used for full blown MAP.
%
% If the LC map fit is not available then the reduced robust fit is used:
%
%   quickMapFitCoeffs = robustFitCoeffs(1:svdOrderForReducedRobustFit)
%
% Output:
%   mapData.quickMap    -- [quickMapStruct]
%       fields:
%           quickMapPerformed
%           priorGoodness     -- [double array(nTargets)]
%           priorWeight       -- [double array(nTargets)]
%           lcMapFitAvailable -- [logical array(nTargets)] If map was not performed for LC target then no
%                                   prior to use. This is different than if priorWeight is zero which may mean
%                                   the variability is just low.
%           FitCoefficients   -- [double matrix(nBasisVectors, nTargets)]
%
%************************************************************************************************************
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

function [] = map_do_quick_map (mapData, mapInput)

% First make sure MAP didn't fail with LC
if (mapInput.mapBlobStruct.mapFailed)
    error ('MAP failed for the corresponding LC run. SC Quick MAP cannot be performed!');
end

% Interpolate LC basis vectors
% The basis vectors have no gaps.
[mapData.basisVectors, syncFailed] = pdc_synchronize_vectors (mapInput.mapBlobStruct.basisVectors, ...
                                        mapInput.mapBlobStruct.cadenceTimes, mapInput.cadenceTimes, 'spline');
if (syncFailed)
    error('pdc_synchronize_vectors: the Basis Vector cadences do not seem to bracket the SC cadences');
end

% The interpolated basis vectors only span a fraction of the original basis vectors, so the mean is no longer
% zero. We need to subtract off the mean of each new basis vector.
mapData.basisVectors = mapData.basisVectors - ...
                repmat(mean(mapData.basisVectors), [length(mapData.basisVectors(:,1)), 1]);

mapData.nBasisVectors = length(mapData.basisVectors(1,:));

% Do robust least-squares fit
map_robust_fit (mapData, mapInput);

% Find the appropriate MAP fit from LC
% Is there a quick way to this with ismember?
%[memberHere, scTargetIndices] = ismember([mapInput.mapBlobStruct.kic.keplerId], mapData.kic.keplerId); 
[keplerIds, scTargetIndicesInLcList, scTargetOrder] = intersect([mapInput.mapBlobStruct.kic.keplerId], mapData.kic.keplerId);
% Re-arrange scTargetIndicesInLcList to the original order of mapData.kic.keplerId
% It is a shame intersect reorders in the first place!
[~, sortOrder] = sort(scTargetOrder);
scTargetIndicesInLcList = scTargetIndicesInLcList(sortOrder);
if (length(keplerIds) ~= mapData.nTargets)
    error ('Oh no!. A short cadence Target appears to not have long cadence data! This will not do.');
end

% The weighting on the robust fit goes as the inverse of the target variability. 1 and lower means completely
% weight the robust fit.
priorVariabilityWeight = 1 - (1 ./ max(mapData.variability,1.0).^mapInput.mapParams.priorPdfVariabilityWeight);
% If MAP was not performed then zero prior weight
mapData.quickMap.lcMapFitAvailable = mapInput.mapBlobStruct.targetsMapAppliedTo(scTargetIndicesInLcList );
priorVariabilityWeight(~mapData.quickMap.lcMapFitAvailable) = 0.0;

% The quick MAP fit is a smoothed sum of the robust fit and the LC MAP fit
mapData.quickMap.FitCoefficients = zeros(size(mapData.robustFit.coefficients));
priorGoodness = zeros(mapData.nTargets, 1);
priorWeight   = zeros(mapData.nTargets, 1);
for iTarget = 1 : mapData.nTargets
    if (mapData.quickMap.lcMapFitAvailable(iTarget))
        % If the LC MAP fit is available use it
        
        % Find the Goodness of the LC MAP fit
        % Uses same method as in mapPdfClass
        priorGoodness(iTarget) = find_prior_goodness (mapInput, mapData.basisVectors, ...
                    mapInput.mapBlobStruct.mapFitCoefficients(:,scTargetIndicesInLcList(iTarget)), ...
                    mapData.normTargetDataStruct(iTarget).values);

        % If prior Goodness is very poor then perform a reduced robust fit (performend in conditional statement before).
        if (priorGoodness(iTarget) < mapInput.mapParams.priorWeightGoodnessCutoff)
            priorGoodness(iTarget) = 0.0;
            priorWeight(iTarget) = 0.0;
        else
            % Prior is good so do a MAP fit
            priorGoodnessPart =  mapInput.mapParams.priorPdfGoodnessGain * priorGoodness(iTarget) ^ mapInput.mapParams.priorPdfGoodnessWeight;

            priorWeight(iTarget) = priorGoodnessPart * priorVariabilityWeight(iTarget);

            mapData.quickMap.FitCoefficients(:,iTarget) = (1 - priorWeight(iTarget)) .* mapData.robustFit.coefficients(:,iTarget) + ...
                                    priorWeight(iTarget) .* mapInput.mapBlobStruct.mapFitCoefficients(:,scTargetIndicesInLcList(iTarget));
        end
    end

    if (priorGoodness(iTarget) == 0.0)
        % If prior is bad (or non-existant) then do a reduced robust fit
        maxBasisVectorIndex = min(mapInput.mapParams.svdOrderForReducedRobustFit, mapData.nBasisVectors);
        mapData.quickMap.FitCoefficients(1:maxBasisVectorIndex,iTarget) = mapData.robustFit.coefficients(1:maxBasisVectorIndex,iTarget);
    end
end

mapData.quickMap.priorGoodness = priorGoodness;
mapData.quickMap.priorWeight   = priorWeight;

end

%************************************************************************************************************
% function [priorGoodness] = find_prior_goodness (mapInput, basisVectors, priorFitCoefficients, lightCurve)
%
% Finds the prior goodness using the same method as mapPdfClass.find_prior_goodness. Since part of the code is
% duplicated, the subplicated part shoudl be in a seperate function. 
%

function [priorGoodness] = find_prior_goodness (mapInput, basisVectors, priorFitCoefficients, lightCurve)

% The prior fit
priorFit = basisVectors * priorFitCoefficients;

% Remove low order polyfit to light curve data
x = [1:length(lightCurve)]';
[p, s, mu] = polyfit(x, lightCurve, mapInput.mapParams.coarseDetrendPolyOrder);
polyFit = polyval(p, x, s, mu);

%***
% Compare the two and find the standard deviation of the difference.
diffPriorToPolyFit = priorFit - polyFit;
% Normalize to the median absolute deviation of the polyfit removed light curve. This allows for a
% comparison of the difference between the polyfit and the prior fit with respect to the variance of the
% target.
absDev = mad(lightCurve - polyFit);
stdDiffPriorToPolyfit = std((diffPriorToPolyFit/absDev) - 1);

% This scaling was empirically found where around a stdDiff of ~>3 is where the prior appears to
% beginng to be poor: 1 - (stdDiff / 5)^3
priorGoodness = 1 - (stdDiffPriorToPolyfit/mapInput.mapParams.priorGoodnessScalingFactor)^...
            mapInput.mapParams.priorGoodnessPowerFactor;
if (priorGoodness < 0)
    % When stdDiff is above priorGoodnessScalingFactor then the above formula yields negative number.
    % But we should make weighting no less than 0. Anything above priorGoodnessScalingFactor 
    % meens fit is poor.
    priorGoodness = 0.0;
end
 
end
