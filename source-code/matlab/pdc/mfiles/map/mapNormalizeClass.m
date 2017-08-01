%% classdef mapNormalizeClass
%
% Normalizes an denormalizes the flux data in a targetDataStruct.
%
% There are currently three normalization methods
%   1) By the Median
%       = (flux / median(flux)) - 1
%   2) By the Mean
%       = (flux / mean(flux)) - 1
%   3) By the Standard Deviation
%       = (flux - mean(flux)) / std(flux)
%   4) By the square root of median
%       = (flux - mean(flux)) / sqrt(median(flux))
%   5) By noise floor
%       = (flux - mean(flux)) / std(diff(flux))
%
% This is just a collection of static methods. No need to construct an object to use these functions.
%
% The third and forth options subtracts the mean, not the median. This is so that SVD will not have a non-zero offset or
% nodes for any basis vectors.
%
% The normalization values and method are stored in the targetDataStruct for each target in normalize_flux to make denomalizing easy. 
% Calling denomalize_flux will then remove these added fields to indicate the data is now not normalized.
%
%%
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

classdef mapNormalizeClass

methods (Static=true)

%************************************************************************************************************
%% function [normTargetDataStruct, medianFlux, meanFlux, stdFlux] = normalize_flux(targetDataStruct, ...
%                       normMethod, doNanGaps, doMaskEpRecovery, cadenceTimes, maskWindow)
% 
% Normalizes flux using one of the following methods:
%   1) by 'median':       normFlux = (flux / median(flux)) - 1
%   2) by 'mean':         normFlux = (flux / mean(flux)) - 1
%   3) by 'std':          normFlux = (flux - mean(flux)) / std(flux)
%   4) by 'sqrtMedian':   normFlux = (flux - mean(flux)) / sqrt(median(flux))
%   5) by 'noiseFloor':   normFlux = (flux - mean(flux)) / std(diff(flux))
%
% Also normalizes the uncertanties by the same value as the flux
%
% This function will zero the flux in the gaps if requested to do so. Naning gaps removes their values from
% the median calculation.  In MAP, the gaps are linearly filled so they should not effect the median by much.
% So, generally, doNanGaps should be false. Also, if the gaps are filled then the gap values should be
% normalized as well. We do not know in general if the gaps are filled so unless doNanGaps, just go ahead and
% normalize them.
%
% The 'noiseFloor' method normalizes by the std of the noise floor of the flux. We want to normalize by the noise, so
% taking first differences removes all signal but the noise. However, the Earth-Point recovery regions do
% effect the std a bit, so also mask EP-recoveries.
%
% Do not mask for median and mean calculation since it is suspected doing so may result in the basis vectors
% not being centered on zero.
%
% The actual normalization occurs in the helper function normalize_value.
%
% The Normalization method is recorded in the targetDatStruct in the field 'normMethod'. This field disapears
% when the flux is unnormalized. The four normalization values (medianFlux, meanFlux, stdFlux and noiseFlor( are also recorded for each target in the
% targetDataStruct. This allows for easy denormalization.
%
%************************************************************************************************************
% Inputs:
%   targetDataStruct -- [targetDataStruct]
%       fields Used:
%                   values
%                   uncertainties
%                   gapIndicators
%   normMethod      -- [Char] Normalization method to use. [median, mean, std, sqrtMedian, noiseFloor]
%   doNanGaps       -- [Logical] If true then gaps are NaNed, otherwise the values of the flux in the gaps
%                                   are normalized
%   doMaskEpRecovery -- [Logical] If true then mask the Earth-Point Recovery regions
%   cadenceTimes    -- [cadenceTimesStruct] Cadence times information to parse the EathPoint indicators from
%   maskWindow      -- [integer] Cadence length for the masking window after end of Earth Point
%
%************************************************************************************************************
% Outputs:
%   normTargetDataStruct -- [targetDataStruct]
%       fields Updated:
%                   values
%                   uncertainties
%                   normMethod    -- [Char] The normalization method used, if this field is present than flux is normalized.
%                   medianFlux
%                   meanFlux  
%                   stdFlux   
%                   noiseFloor
%   medianFlux       -- [float array(nTargets)] median value of flux
%   meanFlux         -- [float array(nTargets)] mean value of flux
%   stdFlux          -- [float array(nTargets)] standard deviation of flux
%   noiseFloor       -- [float array(nTargets)] Noise floor of flux
%   
%************************************************************************************************************

function [normTargetDataStruct, medianFlux, meanFlux, stdFlux, noiseFloor] = normalize_flux(targetDataStruct, normMethod, ...
                        doNanGaps, doMaskEpRecovery, cadenceTimes, maskWindow)

normFluxMemUsage = memoryUsageClass('Normalize Flux Memory Usage');

% Convert struct array into matrix
fluxMatrix = [ targetDataStruct.values ];
uncertaintyMatrix = [ targetDataStruct.uncertainties ];
gapMatrix = [ targetDataStruct.gapIndicators ];

normFluxMemUsage.add('matrices created');

if (doMaskEpRecovery)
    % The Earth-Point Recovery regions should be masked
    maskedGaps = pdc_mask_recovery_regions (gapMatrix, cadenceTimes, maskWindow);
else
    maskedGaps = [targetDataStruct.gapIndicators];
end
% If not masking then maskedGapMatrix = gapMatrix
maskedGapMatrix = maskedGaps;
clear maskedGaps;

normFluxMemUsage.add('gapse masked');

nTargets = length(targetDataStruct);

if (doNanGaps)
    fluxMatrix(gapMatrix) = NaN;
end

coarseDetrendPolyOrder = 3;
medianFlux = zeros(nTargets,1);
meanFlux   = zeros(nTargets,1);
stdFlux    = zeros(nTargets,1);
noiseFloor = zeros(nTargets,1);
for iTarget = 1:nTargets
    % calculate median, mean and std for each timeseries (don't use gap values)
    % Canot be easily parallelized due to not including gaps
    medianFlux(iTarget)  = nanmedian(fluxMatrix((~gapMatrix(:,iTarget)),iTarget));
    meanFlux(iTarget)    = nanmean(fluxMatrix((~gapMatrix(:,iTarget)),iTarget));
    stdFlux(iTarget)     = nanstd(fluxMatrix((~maskedGapMatrix(:,iTarget)),iTarget));
    noiseFloor(iTarget)  = nanstd(diff(fluxMatrix((~maskedGapMatrix(:,iTarget)),iTarget)));
end
clear maskedGapMatrix;
% For any fully gapped targets the above will produce a value of NaN. So convert these to zeroes.
medianFlux(isnan(medianFlux)) = 0;
meanFlux(isnan(meanFlux)) = 0;
stdFlux(isnan(stdFlux)) = 0;
noiseFloor(isnan(noiseFloor)) = 0;

normFluxMemUsage.add('mean median etc...');

%***
normFlux = mapNormalizeClass.normalize_value (fluxMatrix, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod);

normFluxMemUsage.add('normalize value');

%***
% Normalization on the uncertainties is just divide by same medianFlux, stdFlux, etc...
switch strtrim(normMethod)
case 'median'
    % TODO: make sure this works with submatrix logic
    normUncertainties(:,medianFlux~=0) = scalerow(1./abs(medianFlux(medianFlux~=0)), uncertaintyMatrix(:,medianFlux~=0));
    normUncertainties(:,medianFlux==0) = uncertaintyMatrix(:,(medianFlux==0));
case 'mean'
    normUncertainties(:,meanFlux~=0)   = scalerow(1./abs(meanFlux(meanFlux~=0)), uncertaintyMatrix(:,meanFlux~=0));
    normUncertainties(:,meanFlux==0)   = uncertaintyMatrix(:,(meanFlux==0));
case 'std'
    normUncertainties(:,stdFlux~=0)    = scalerow(1./abs(stdFlux(stdFlux~=0)), uncertaintyMatrix(:,stdFlux~=0));
    normUncertainties(:,stdFlux==0)    = uncertaintyMatrix(:,(stdFlux==0));
case 'sqrtMedian'
    normUncertainties(:,medianFlux~=0) = scalerow(1./sqrt(abs(medianFlux(medianFlux~=0))), uncertaintyMatrix(:,medianFlux~=0));
    normUncertainties(:,medianFlux==0) = uncertaintyMatrix(:,(medianFlux==0));
case 'noiseFloor'
    normUncertainties(:,noiseFloor~=0) = scalerow(1./abs(noiseFloor(noiseFloor~=0)), uncertaintyMatrix(:,noiseFloor~=0));
    normUncertainties(:,noiseFloor==0) = uncertaintyMatrix(:,(noiseFloor==0));
otherwise
    error ('Unknown normalization method') 
end
clear uncertaintyMatrix;

normFluxMemUsage.add('normalize!');

% Reset gaps to NaN if requested
if (doNanGaps)
    normFlux(gapMatrix) = NaN;
end
clear fluxMatrix gapMatrix;

normTargetDataStruct = targetDataStruct;
normFluxMemUsage.add('targetDataStruct copied');

% convert matrix back into struct array
for i=1:nTargets
    normTargetDataStruct(i).values        = normFlux(:,i);
    normTargetDataStruct(i).uncertainties = normUncertainties(:,i);
    normTargetDataStruct(i).normMethod    = strtrim(normMethod);
    normTargetDataStruct(i).medianFlux    = medianFlux(i);
    normTargetDataStruct(i).meanFlux      = meanFlux(i);
    normTargetDataStruct(i).stdFlux       = stdFlux(i);
    normTargetDataStruct(i).noiseFloor    = noiseFloor(i);
end

clear normFlux normUncertainties;

normFluxMemUsage.add('convert back and end');

end % normalize_flux

%************************************************************************************************************
%% function [normalizedValue] = normalize_value (value, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)
% 
% Normalizes a value array or matrix using medianFlux and stdFlux with one of the following formulas:
%
%   1) by median:       normFlux = (flux / median(flux)) - 1
%   2) by mean:         normFlux = (flux / mean(flux)) - 1
%   3) by std:          normFlux = (flux - mean(flux)) / std(flux)
%   4) by sqrt(median): normFlux = (flux - mean(flux)) / sqrt(median(flux))
%   5) by noiseFloor:   normFlux = (flux - mean(flux)) / std(diff(flux))
%
% The value matrix is normalized column-wise, that is to say, each column is normalized by the same
% normalizingValue. So, if the dimensions of value is mxn then the dimension of normalizingValue is n.
%
% The third and forth options subtracts the mean, not the median. This is so that SVD will not have a non-zero offset or
% nodes for any basis vectors.
%
% The check for a zero median/mean is so that we do not divide by zero. for 'mean', 'median' and 'sqrtMedian'
% normalization. 'std' and 'noiseFloor' should never be zero unless it's flat-line data which means we have
% even bigger problems.
%
%************************************************************************************************************
% Inputs:
%   value           -- [float matrix(mxn)] the array of values to normalize
%   medianFlux      -- [float array(n)] median value of Flux
%   meanFlux        -- [float array(n)] mean value of Flux
%   stdFlux         -- [float array(n)] standard deviation of Flux
%   noiseFloor      -- [float array(n)] standard deviation of first differences of Flux (i.e. noise floor)
%   normMethod      -- [Char] Normalization method to use. [median, mean, std, sqrtMedian, noiseFloor]
%
%************************************************************************************************************
% Outputs:
%   normalizedValue -- [float matrix(mxn)]
%
%************************************************************************************************************

function [normalizedValue] = normalize_value (value, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)

[nCadences, nTargets] = size(value);
if (nCadences == 0 || nTargets == 0)
    % No data! nothing to do
    return;
end

% If median/mean is zero then already normalized, and don't divide by zero
% there is a corner case to protect from. If all targets' normalization values (e.g. medianFlux) are zero then the evaluation will crash, so
% protect form this condition. A try, catch bock would be dangerour since I want it to crash for other issues for debugging purposes.
switch strtrim(normMethod)
case 'median'
    if (nTargets ~= length(medianFlux))
        error('normalize_value: size(value) must be mxn and length(medianFlux) =  n');
    end
    if (~all(medianFlux == 0))
        normalizedValue(:,medianFlux~=0) = ...
            (value(:,medianFlux~=0) ./ repmat(medianFlux(medianFlux~=0)', [nCadences, 1])) - 1;
    end
    normalizedValue(:,medianFlux==0) = value(:,medianFlux==0);
case 'mean'
    if (nTargets ~= length(meanFlux))
        error('normalize_value: size(value) must be mxn and length(meanFlux) =  n');
    end
    if (~all(meanFlux == 0))
        normalizedValue(:,meanFlux~=0) = ...
            (value(:,meanFlux~=0) ./ repmat(meanFlux(meanFlux~=0)', [nCadences, 1])) - 1;
    end
    normalizedValue(:,meanFlux==0) = value(:,meanFlux==0);
case 'std'
    if (nTargets ~= length(stdFlux) || nTargets ~= length(meanFlux))
        error('normalize_value: size(value) must be mxn and length(stdFlux) =  length(meanFlux) = n');
    end
    if (~all(stdFlux == 0))
        normalizedValue(:,stdFlux~=0) = ...
            (value(:,stdFlux~=0) - repmat(meanFlux(stdFlux~=0)', [nCadences, 1])) ./ ...
                                                repmat(stdFlux(stdFlux~=0)', [nCadences, 1]);
    end
    normalizedValue(:,stdFlux==0) = value(:,stdFlux==0);
case 'sqrtMedian'
    if (nTargets ~= length(medianFlux) || nTargets ~= length(meanFlux))
        error('normalize_value: size(value) must be mxn and length(medianFlux) = length(meanFlux) = n');
    end
    if (~all(medianFlux == 0))
        normalizedValue(:,medianFlux~=0) = ...
            (value(:,medianFlux~=0) - repmat(meanFlux(medianFlux~=0)', [nCadences, 1])) ./ ...
                                                repmat(sqrt(medianFlux(medianFlux~=0))', [nCadences, 1]);
    end
    normalizedValue(:,medianFlux==0) = value(:,medianFlux==0);
case 'noiseFloor'
    if (nTargets ~= length(noiseFloor) || nTargets ~= length(meanFlux))
        error('normalize_value: size(value) must be mxn and length(noiseFloor) = length(meanFlux) = n');
    end
    if (~all(noiseFloor == 0))
        normalizedValue(:,noiseFloor~=0) = ...
            (value(:,noiseFloor~=0) - repmat(meanFlux(noiseFloor~=0)', [nCadences, 1])) ./ ...
                                                repmat(noiseFloor(noiseFloor~=0)', [nCadences, 1]);
    end
    normalizedValue(:,noiseFloor==0) = value(:,noiseFloor==0);
otherwise
    error ('Unknown normalization method') 
end


end % normalize_value

%************************************************************************************************************
%% function [targetDataStruct] = denormalize_flux (targetDataStruct)
% 
% Denormalizes flux using these methods:
%
% 1) median: normFlux = (flux / median(flux)) - 1 so that
%
%   flux = medianFlux * (value + 1)
%
% 2) mean: normFlux = (flux / mean(flux)) - 1 so that
%
%   flux = meanFlux * (value + 1)
%
% 3) std: normFlux    = (flux - mean(flux)) / std(flux) so that
%
%   flux = std(flux) * normFlux + mean(flux)
%
% 4) sqrt(median): normFlux    = (flux - mean(flux)) / sqrt(median(flux)) so that
%
%   flux = sqrt(median(flux)) * normFlux + mean(flux)
%
% 5) std: noiseFloor    = (flux - mean(flux)) / std(diff(flux)) so that
%
%   flux = std(diff(flux)) * normFlux + mean(flux)
%
% The denormalization method used is based on the value of targetDataStruct(:).normMethod. If this field
% doesn't exists then nothing is error, crash and burn...
% The normalization values are also recorded in the targetDataStruct.
%
% Also denormalizes the uncertanties by the same value
%
% The actual denormalization occurs in the helper function denormalize_value.
%
%************************************************************************************************************
% Inputs:
%   normTargetDataStruct -- [targetDataStruct]
%       fields Used:
%                   values
%                   uncertainties
%                   medianFlux -- [float array] value used to dernormalize flux.
%                   meanFlux   -- [float array] value used to dernormalize flux.
%                   stdFlux    -- [float array(n)] standard deviation of Flux
%                   noiseFloor -- [float array(n)] standard deviation of first differences of Flux (i.e. noise floor)
%                   normMethod -- [Char] Normalization method to use. [median, std, sqrtMedian, noiseFloor]
%
%************************************************************************************************************
% Outputs:
%   targetDataStruct -- [targetDataStruct]
%       fields Updated:
%                   values
%                   uncertainties
%                   normMethod => field removed
%
%%************************************************************************************************************

function [targetDataStruct] = denormalize_flux (normTargetDataStruct)

if (isfield(normTargetDataStruct(1), 'normMethod'))
    normMethod = normTargetDataStruct(1).normMethod;
    medianFlux = [normTargetDataStruct.medianFlux]';
    meanFlux   = [normTargetDataStruct.meanFlux]';
    stdFlux    = [normTargetDataStruct.stdFlux]';
    noiseFloor = [normTargetDataStruct.noiseFloor]';
else
    targetDataStruct = normTargetDataStruct;
    return
end

if (any(~strcmp(normMethod, {normTargetDataStruct(:).normMethod})))
    error ('All targets in normTargetDataStruct must be normalized using the same method');
end

nTargets = length(normTargetDataStruct);

% Convert struct array into matrix
fluxMatrix        = [ normTargetDataStruct.values ];
uncertaintyMatrix = [ normTargetDataStruct.uncertainties ];

%***
flux = mapNormalizeClass.denormalize_value (fluxMatrix, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod);
clear fluxMatrix;

%***
% Denormalize the uncertainties by just multiplying by same medianFlux, stdFlux etc...
% If median/mean is zero then just pass back the flux uncertainties
switch strtrim(normMethod)
case 'median'
    uncertainties = scalerow(abs(medianFlux), uncertaintyMatrix);
    uncertainties(:,medianFlux==0) = uncertaintyMatrix(:,(medianFlux==0));
case 'mean'
    uncertainties = scalerow(abs(meanFlux), uncertaintyMatrix);
    uncertainties(:,meanFlux==0) = uncertaintyMatrix(:,(meanFlux==0));
case 'std'
    uncertainties = scalerow(abs(stdFlux), uncertaintyMatrix);
    uncertainties(:,(stdFlux==0)) = uncertaintyMatrix(:,(stdFlux==0));
case 'sqrtMedian'
    uncertainties = scalerow(sqrt(abs(medianFlux)), uncertaintyMatrix);
    uncertainties(:,(medianFlux==0)) = uncertaintyMatrix(:,(medianFlux==0));
case 'noiseFloor'
    uncertainties = scalerow(abs(noiseFloor), uncertaintyMatrix);
    uncertainties(:,(noiseFloor==0)) = uncertaintyMatrix(:,(noiseFloor==0));
otherwise
    error ('Unknown normalization method') 
end
clear uncertaintyMatrix;

targetDataStruct = normTargetDataStruct;
% Convert matrix back into struct array
for iTarget=1:nTargets
    targetDataStruct(iTarget).values        = flux(:,iTarget);
    targetDataStruct(iTarget).uncertainties = uncertainties(:,iTarget);
end
clear uncertainties;

% Remove normalization flag
targetDataStruct = rmfield(targetDataStruct, 'normMethod');
targetDataStruct = rmfield(targetDataStruct, 'medianFlux');
targetDataStruct = rmfield(targetDataStruct, 'meanFlux');
targetDataStruct = rmfield(targetDataStruct, 'stdFlux');
targetDataStruct = rmfield(targetDataStruct, 'noiseFloor');

end % denormalize_flux

%************************************************************************************************************
%% function [denormalizedValue] = denormalize_value (value, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)
% 
% Denormalizes flux using these methods:
%
% 1) median: normFlux = (flux / median(flux)) - 1 so that
%
%   flux = median(flux) * (value + 1)
%
% 2) mean: normFlux   = (flux / mean(flux)) - 1 so that
%
%   flux = mean(flux) * (value + 1)
%
% 3) std: normFlux    = (flux - mean(flux)) / std(flux) so that
%
%   flux = std(diff(flux)) * normFlux + mean(flux)
%
% 4) sqrt(median): normFlux    = (flux - mean(flux)) / sqrt(median(flux)) so that
%
%   flux = sqrt(median(flux)) * normFlux + mean(flux)
%
% 3) std: noiseFloor  = (flux - mean(flux)) / std(diff(flux)) so that
%
%   flux = std(diff(flux)) * normFlux + mean(flux)
%
% The value matrix is denormalized column-wise, that is to say, each column is normalized by the same
% medianFlux/meanFlux. So, if the dimensions of value is mxn then the dimension of medianFlux is n.
%
%************************************************************************************************************
% Inputs:
%   value       -- [float matrix(mxn)] the array of values to normalize
%   medianFlux  -- [float array(n)] value to normalize with
%   meanFlux    -- [float array(n)] value to normalize with
%   stdFlux     -- [float array(n)] standard deviation of Flux
%   noiseFloor  -- [float array(n)] Noise floor of flux
%   normMethod  -- [Char] Normalization method to use. [median, std, sqrtMedian]
%
%************************************************************************************************************
% Outputs:
%   denormalizedValue -- [float matrix(mxn)]
%
%%************************************************************************************************************

function [denormalizedValue] = denormalize_value (value, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)

[nCadences, nTargets] = size(value);
if (nCadences == 0 || nTargets == 0)
    % No data! nothing to do
    return;
elseif (nTargets ~= length(medianFlux) || nTargets ~= length(stdFlux) || ...
            nTargets ~= length(meanFlux) || nTargets ~= length(noiseFloor))
    error('denormalize_value: size(value) must be mxn and length(medianFlux) = length(stdFlux) = ... =  n');
end

% if medianFlux/meanFlux is zero then just pass back the flux values
switch strtrim(normMethod)
case 'median'
    denormalizedValue = repmat(medianFlux',[size(value,1),1]).*(value + 1);
    denormalizedValue(:,medianFlux==0) = value(:,medianFlux==0);
case 'mean'
    denormalizedValue = repmat(meanFlux',[size(value,1),1]).*(value + 1);
    denormalizedValue(:,meanFlux==0) = value(:,meanFlux==0);
case 'std'
    denormalizedValue = (repmat(stdFlux',[size(value,1),1]).*value) + repmat(meanFlux',[size(value,1),1]);
    denormalizedValue(:,stdFlux==0) = value(:,stdFlux==0);
case 'sqrtMedian'
    denormalizedValue = (repmat(sqrt(medianFlux)',[size(value,1),1]).*value) + repmat(meanFlux',[size(value,1),1]);
    denormalizedValue(:,medianFlux==0) = value(:,medianFlux==0);
case 'noiseFloor'
    denormalizedValue = (repmat(noiseFloor',[size(value,1),1]).*value) + repmat(meanFlux',[size(value,1),1]);
    denormalizedValue(:,noiseFloor==0) = value(:,noiseFloor==0);
otherwise
    error ('Unknown normalization method') 
end

end % denormalize_value

%************************************************************************************************************
%% function [normalizedCoefficients] = normalize_coefficients (coefficients, ...
%                               medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)
%
% Normalizes the fit coefficients. The coefficients found in PDC-MAP are for the normalized flux. The
% denormalized coefficients gives the fit in units of electrons per cadence. The formula used are below. c
% refers to the denormalized coefficients and c' referes to the normalized coefficients. V is the matrix of
% basis vectors.
%
% 2) mean: normFlux = (flux / mean(flux)) - 1
%       v.c' = ((v.c + mean(flux)) / mean(flux) - 1)
%       v.c' = (v.c) / mean(flux)
%         c' = c  / mean(flux)
%       
% The normalizedCoefficients matrix is normalized row-wise, that is to say, each row correpsonds to one
% target and is normalized by the same medianFlux/meanFlux. So, if the dimensions of normalizedCoefficients 
% is mxn then the dimension of medianFlux is m.
%
%************************************************************************************************************
% Inputs:
%   coefficients -- [float matrix(mxn)] the array of coefficients to normalize
%   medianFlux   -- [float array(m)] value to normalize with
%   meanFlux     -- [float array(m)] value to normalize with
%   stdFlux      -- [float array(m)] standard deviation of Flux
%   noiseFloor   -- [float array(m)] noise floor of flux
%   normMethod   -- [Char] Normalization method to use. [median, std, sqrtMedian]
%
%************************************************************************************************************
% Outputs:
%   normalizedCoefficients -- [float matrix(mxn)]
%
%%************************************************************************************************************

function [normalizedCoefficients] = normalize_coefficients (coefficients, ...
                             medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)

normalizedCoefficients = zeros(size(coefficients));

switch strtrim(normMethod)
case 'mean'
    for iTarget = 1 : length(normalizedCoefficients(:,1))
        normalizedCoefficients(iTarget, :) = coefficients(iTarget,:) / meanFlux(iTarget);
    end
otherwise
    error ('Unknown normalization method') 
end

end % normalize_coefficients

%************************************************************************************************************
%% function [denormalizedCoefficients] = denormalize_coefficients (normalizedCoefficients, basisVectors, ...
%                               medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)
%
% Denormalizes the fit coefficients. The coefficients found in PDC-MAP are for the normalized flux. The
% denormalized coefficients gives the fit in units of electrons per cadence. The formula used are below. c
% refers to the denormalized coefficients and c' referes to the normalized coefficients. V is the matrix of
% basis vectors.
%
% 2) mean: normFlux = (flux / mean(flux)) - 1
%       v.c' = ((v.c + mean(flux)) / mean(flux) - 1)
%       v.c  = mean(flux)(v.c' + 1) - mean(flux)
%       v.c  = mean(flux).v.c'
%         c  = mean(flux).c'
%       
% The normalizedCoefficients matrix is denormalized row-wise, that is to say, each row correpsonds to one
% target and is normalized by the same medianFlux/meanFlux. So, if the dimensions of normalizedCoefficients 
% is mxn then the dimension of medianFlux is m.
%
%************************************************************************************************************
% Inputs:
%   normalizedCoefficients -- [float matrix(mxn)] the array of coefficients to denormalize
%   medianFlux             -- [float array(m)] value to normalize with
%   meanFlux               -- [float array(m)] value to normalize with
%   stdFlux                -- [float array(m)] standard deviation of Flux
%   noiseFloor             -- [float array(m)] noise floor of flux
%   normMethod             -- [Char] Normalization method to use. [median, std, sqrtMedian]
%
%************************************************************************************************************
% Outputs:
%   denormalizedCoefficients -- [float matrix(mxn)]
%
%%************************************************************************************************************

function [denormalizedCoefficients] = denormalize_coefficients (normalizedCoefficients, ...
                             medianFlux, meanFlux, stdFlux, noiseFloor, normMethod)

mapFitMatrix = basisVectors*normalizedCoefficients';
denormalizedCoefficients = zeros(size(normalizedCoefficients));

switch strtrim(normMethod)
case 'mean'
    for iTarget = 1 : length(normalizedCoefficients(:,1))
        denormalizedCoefficients (iTarget, :) = normalizedCoefficients(iTarget,:) * meanFlux(iTarget);
    end
otherwise
    error ('Unknown normalization method') 
end

end % denormalize_coefficients

end % static methods

end % classdef
