function pdqTempStruct = compute_dynamic_range_metric(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_dynamic_range_metric(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate dynamic range metric
%
% Only a limited number of reference pixels can be down linked via X-band,
% and the number will decrease as Kepler drifts away from Earth. Eventually
% we will not have sufficient number of pixels to adequately sample all 84
% module/outputs. Thhe goal is to use just a few reference pixels to see if
% the module/ouput is still functioning, by sampling pixles illuminated by
% a bright star (preferable saturated), and a background aperture.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Get input data from data members
% Number of cadences and number of targets to process
numCadences             = pdqTempStruct.numCadences; % RLM -- # new cadences (from pdqScienceObject.cadenceTimes)


if isfield(pdqTempStruct, 'dynamicPixels') && isfield(pdqTempStruct, 'dynamicGapIndicators')
    dynamicPixels           = pdqTempStruct.dynamicPixels;
    dynamicGapIndicators    = pdqTempStruct.dynamicGapIndicators;
else
    dynamicPixels            = zeros(0, numCadences);
    dynamicGapIndicators     = false(0, numCadences);
end


if isfield(pdqTempStruct, 'targetPixels') && isfield(pdqTempStruct, 'targetGapIndicators')
    targetPixels            = pdqTempStruct.targetPixels;
    targetGapIndicators     = pdqTempStruct.targetGapIndicators;
else
    targetPixels            = zeros(0, numCadences);
    targetGapIndicators     = false(0, numCadences);
end


if isfield(pdqTempStruct, 'bkgdPixels') && isfield(pdqTempStruct, 'bkgdGapIndicators')
    bkgdPixels              = pdqTempStruct.bkgdPixels;
    bkgdGapIndicators       = pdqTempStruct.bkgdGapIndicators;
else
    bkgdPixels              = zeros(0, numCadences);
    bkgdGapIndicators       = false(0, numCadences);
end


if isfield(pdqTempStruct, 'msmearPixels') && isfield(pdqTempStruct, 'msmearGapIndicators')
    msmearPixels            = pdqTempStruct.msmearPixels;
    msmearGapIndicators     = pdqTempStruct.msmearGapIndicators;
else
    msmearPixels            = zeros(0, numCadences);
    msmearGapIndicators     = false(0, numCadences);
end


if isfield(pdqTempStruct, 'vsmearPixels') && isfield(pdqTempStruct, 'vsmearGapIndicators')
    vsmearPixels            = pdqTempStruct.vsmearPixels;
    vsmearGapIndicators     = pdqTempStruct.vsmearGapIndicators;
else
    vsmearPixels            = zeros(0, numCadences);
    vsmearGapIndicators     = false(0, numCadences);
end


if isfield(pdqTempStruct, 'blackPixels') && isfield(pdqTempStruct, 'blackGapIndicators')
    blackPixels             = pdqTempStruct.blackPixels;
    blackGapIndicators      = pdqTempStruct.blackGapIndicators;
else
    blackPixels             = zeros(0, numCadences);
    blackGapIndicators      = false(0, numCadences);
end


numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence; % for all cadences

% RLM -- 7/12/11 -- For some reason the default values were set to zero,
% while the compute_dynamic_range_metric_main() function checks for values
% of -1 and gaps any such cadences in the metric time series.

%dynamicRanges = zeros(numCadences,1);
dynamicRanges = -ones(numCadences,1);
% -- RLM

for jCadence = 1:numCadences

    validDynamicPixelIndices    = find(~dynamicGapIndicators(:,jCadence));
    validTargetPixelIndices     = find(~targetGapIndicators(:,jCadence));
    validBkgdPixelIndices       = find(~bkgdGapIndicators(:,jCadence));
    validBlackPixelIndices      = find(~blackGapIndicators(:,jCadence));
    validMsmearPixelIndices     = find(~msmearGapIndicators(:,jCadence));
    validVsmearPixelIndices     = find(~vsmearGapIndicators(:,jCadence));



    allPixels = vertcat(dynamicPixels(validDynamicPixelIndices, jCadence), targetPixels(validTargetPixelIndices, jCadence),...
        bkgdPixels(validBkgdPixelIndices, jCadence), msmearPixels(validMsmearPixelIndices, jCadence), ...
        vsmearPixels(validVsmearPixelIndices, jCadence), blackPixels(validBlackPixelIndices, jCadence));

    % dynamic range should always be reported even if the dynamic range
    % targets are not present
    
    % RLM --12/7/10 -- commented out
    %   dynamicRanges(jCadence) = (max(allPixels) - min(allPixels))/numberOfExposuresPerLongCadence(jCadence);
    %
    % If the above code returns an empty array (which it may with gappy
    % data) the dynamicRanges[] array would have been reduced in size by
    % the old code. To correct this problem I added the following code: 
    range = (max(allPixels) - min(allPixels))/numberOfExposuresPerLongCadence(jCadence);
    if ~isempty(range) % Currently, dynamicRanges(jCadence) = 0
        dynamicRanges(jCadence) = range;
    end
    %-- RLM
    
end

pdqTempStruct.dynamicRanges = dynamicRanges;

return

