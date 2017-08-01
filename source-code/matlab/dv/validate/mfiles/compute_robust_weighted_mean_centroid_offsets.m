function [offsets] = compute_robust_weighted_mean_centroid_offsets( ...
centroidOffsetArray, offsets, mqOffsetConstantUncertainty, ...
isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [offsets] = compute_robust_weighted_mean_centroid_offsets( ...
% centroidOffsetArray, offsets, mqOffsetConstantUncertainty, ...
% isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the robust mean weighted centroid offsets in RA and Dec for the
% given planet candidate across all target tables. Also compute the
% associated sky offset as the square root of the sum of the squares of the
% RA and Dec components. Propagate the uncertainties through the robust
% fits to the sky offset. Add the MQ offset constant uncertainty in
% quadrature; it may or may not be set to 0. Perform a statistical
% bootstrap on the RA and Dec components of the quarterly centroid offsets.
% If the propagated uncertainty in the bootstrapped sky offset is larger
% than the uncertainty in the robust mean sky offset then adopt the
% bootstrapped uncertainties for the robust mean RA and Dec offsets and the
% resulting sky offset.
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

% Check optional arguments.
if ~exist('isBadQualityMetric', 'var')
    isBadQualityMetric = [];
end % if

% Compute the robust weighted mean RA offset.
[meanRaOffset, simpleMeanRaUncertainty] = ...
    compute_mean_centroid_offset([centroidOffsetArray.raOffset], ...
    offsets.meanRaOffset, mqOffsetConstantUncertainty, isBadQualityMetric);
offsets.meanRaOffset = meanRaOffset;

% Compute the robust weighted mean Dec offset.
[meanDecOffset, simpleMeanDecUncertainty] = ...
    compute_mean_centroid_offset([centroidOffsetArray.decOffset], ...
    offsets.meanDecOffset, mqOffsetConstantUncertainty, isBadQualityMetric);
offsets.meanDecOffset = meanDecOffset;

% Compute the associated sky offset for the mean RA and Dec offsets. Return
% if the mean offsets are invalid because in this case there is no reason
% to perform the bootstrap for the uncertainties. The propagated
% uncertainty based on simple mean computation should be a lower bound on
% the uncertainty in the robust mean sky offset.
if meanRaOffset.uncertainty ~= -1 && meanDecOffset.uncertainty ~= -1
    
    meanSkyOffset.value = ...
        sqrt(meanRaOffset.value^2 + meanDecOffset.value^2);
    Jrd = [meanRaOffset.value, meanDecOffset.value] / ...
        meanSkyOffset.value;
    Crd = diag([meanRaOffset.uncertainty^2, meanDecOffset.uncertainty^2]);
    meanSkyOffset.uncertainty = sqrt(Jrd * Crd * Jrd');
    offsets.meanSkyOffset.value = meanSkyOffset.value;
    offsets.meanSkyOffset.uncertainty = meanSkyOffset.uncertainty;
    
    Crd = diag([simpleMeanRaUncertainty^2, simpleMeanDecUncertainty^2]);
    simpleMeanSkyUncertainty = sqrt(Jrd * Crd * Jrd');
    if simpleMeanSkyUncertainty > meanSkyOffset.uncertainty
        offsets.meanRaOffset.uncertainty  = simpleMeanRaUncertainty;
        offsets.meanDecOffset.uncertainty = simpleMeanDecUncertainty;
        offsets.meanSkyOffset.uncertainty = simpleMeanSkyUncertainty;
    end % if
    
else
    return
end % if / else

% Perform a bootstrap computation of the uncertainties with N^2 trials
% where N is the number of quarterly centroid offsets. If the bootstrapped
% uncertainty in the sky offset is larger than the propagated uncertainty
% in the robust sky offset then replace the uncertainties in the
% RA, Dec and sky offsets with the bootstrapped values.
[bootstrapRaOffset, bootstrapDecOffset, Crd] = ...
    compute_bootstrap_centroid_offset([centroidOffsetArray.raOffset], ...
    [centroidOffsetArray.decOffset], mqOffsetConstantUncertainty, ...
    isBadQualityMetric);

% If the uncertainty in the bootstrapped sky offset is larger than the
% uncertainty in the robust mean sky offset then adopt the bootstrap
% uncertainties for the RA offset, Dec offset and sky offset. Note that
% offset values in RA/Dec are still determined by robust mean computations
% performed above.
if bootstrapRaOffset.uncertainty ~= -1 && ...
        bootstrapDecOffset.uncertainty ~= -1
    bootstrapSkyOffsetUncertainty = sqrt(Jrd * Crd * Jrd');
    if bootstrapSkyOffsetUncertainty > offsets.meanSkyOffset.uncertainty
        offsets.meanRaOffset.uncertainty  = bootstrapRaOffset.uncertainty;
        offsets.meanDecOffset.uncertainty = bootstrapDecOffset.uncertainty;
        offsets.meanSkyOffset.uncertainty = bootstrapSkyOffsetUncertainty;
    end % if
end % if

% Return.
return


function [meanOffset, simpleMeanUncertainty, robustMeanFlag] = ...
compute_mean_centroid_offset(offsetArray, meanOffset, ...
mqOffsetConstantUncertainty, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [meanOffset, robustMeanFlag] = ...
% compute_mean_centroid_offset(offsetArray, meanOffset, ...
% mqOffsetConstantUncertainty, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Extract the valid offsets and compute the robust weighted mean with
% associated uncertainty. If there is only one valid offset then the mean
% value/uncertainty are equal to the single valid offset value/uncertainty.
% If there is more than one valid offset then the robust weighted mean is
% called within a try/catch block; the non-robust weighted mean and
% uncertainty are returned if the robust fit fails for some reason.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Set the default value for the simple mean uncertainty and robust mean
% flag.
simpleMeanUncertainty = -1;
robustMeanFlag = false;

% Get all offset values/uncertainties and squeeze out the invalid ones. 
% Also squeeze the offsets based on bad quality difference images if they
% have been identified. Set any zero-valued uncertainties to eps as the
% weights for the fit must be finite.
offsetValues = [offsetArray.value]';
offsetUncertainties = [offsetArray.uncertainty]';
offsetUncertainties(offsetUncertainties == 0) = eps;

if isempty(isBadQualityMetric)
    isBadQualityMetric = false(size(offsetValues));
end % if

isValidOffset = offsetUncertainties ~= -1 & ~isBadQualityMetric;
if ~any(isValidOffset)
    return
end % if

offsetValues = offsetValues(isValidOffset);
offsetUncertainties = offsetUncertainties(isValidOffset);

% Compute the robust weighted mean if possible, otherwise return the
% non-robust mean. Also set the associated flag to indicate that the robust
% mean was actually computed.
if length(offsetValues) == 1
    
    meanOffset.value = offsetValues;
    meanOffset.uncertainty = offsetUncertainties;
    robustMeanFlag = true;
    
else
    
    warningState = warning('query', 'all');
    warning off all
    
    try
        [meanOffset.value, stats] = robustfit( ...
            1./offsetUncertainties, offsetValues./offsetUncertainties, ...
            [], [], 'off');
        meanOffset.uncertainty = stats.se;
        robustMeanFlag = true;
    catch exception                                                                         %#ok<NASGU>
        [meanOffset.value, stdx, mse] = lscov( ...
            ones(size(offsetValues)), offsetValues, 1./offsetUncertainties.^2);
        meanOffset.uncertainty = stdx / sqrt(mse);
    end % try/catch
    
    
    warning(warningState);
    
end % if / else

% Compute the uncertainty in the simple mean. This will be a lower bound on
% the uncertainty in the robust mean centroid offset (KSOC-4029).
simpleMeanUncertainty = ...
    sqrt(offsetUncertainties' * offsetUncertainties) / ...
    length(offsetUncertainties);

% Add the MQ offset constant uncertainty in quadrature to the uncertainties
% for each of the RA/Dec components. Steve Bryson has shown that this is
% equivalent to adding the same constant uncertainty in quadrature to the
% uncertainty in the offset distance derived from the RA/Dec components.
meanOffset.uncertainty = ...
    sqrt(meanOffset.uncertainty^2 + mqOffsetConstantUncertainty^2);
simpleMeanUncertainty = ...
    sqrt(simpleMeanUncertainty^2 + mqOffsetConstantUncertainty^2);

% Return.
return


function [bootstrapRaOffset, bootstrapDecOffset, bootstrapCovariance] = ...
compute_bootstrap_centroid_offset(raOffsetArray, decOffsetArray, ...
mqOffsetConstantUncertainty, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [bootstrapRaOffset, bootstrapDecOffset, bootstrapCovariance] = ...
% compute_bootstrap_centroid_offset(raOffsetArray, decOffsetArray, ...
% mqOffsetConstantUncertainty, isBadQualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Extract the valid offsets and perform a bootstrap with N^2 trials (where
% N is the number of valid offsets) to estimate the mean RA and Dec offsets
% and associated uncertainties. If there is only one valid offset then
% the mean value/uncertainty are equal to the single valid offset
% value/uncertainty. Return the bootstrapped RA and Dec centroid offset
% values/uncertainties and the RA/Dec offset covariance matrix.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Initialize the bootstrap results.
bootstrapRaOffset = struct( ...
    'value', 0, ...
    'uncertainty', -1);

bootstrapDecOffset = struct( ...
    'value', 0, ...
    'uncertainty', -1);

bootstrapCovariance = -ones(2, 2);

% Get all offset values/uncertainties and squeeze out the invalid ones.
raOffsetValues = [raOffsetArray.value]';
raOffsetUncertainties = [raOffsetArray.uncertainty]';

decOffsetValues = [decOffsetArray.value]';
decOffsetUncertainties = [decOffsetArray.uncertainty]';

if isempty(isBadQualityMetric)
    isBadQualityMetric = false(size(raOffsetValues));
end % if

isValidOffset = raOffsetUncertainties ~= -1 & ...
    decOffsetUncertainties ~= -1 & ~isBadQualityMetric;
if ~any(isValidOffset)
    return
end % if

raOffsetValues = raOffsetValues(isValidOffset);
raOffsetUncertainties = raOffsetUncertainties(isValidOffset);

decOffsetValues = decOffsetValues(isValidOffset);
decOffsetUncertainties = decOffsetUncertainties(isValidOffset);

% Perform a bootstrap with N^2 trials to estimate the mean and uncertainty
% for the RA and Dec offset components.
nQuarters = length(raOffsetValues);

if nQuarters == 1
    
    bootstrapRaOffset.value = raOffsetValues;
    bootstrapRaOffset.uncertainty = raOffsetUncertainties;
    
    bootstrapDecOffset.value = decOffsetValues;
    bootstrapDecOffset.uncertainty = decOffsetUncertainties;
    
    bootstrapCovariance = diag( ...
        [bootstrapRaOffset.uncertainty^2, ...
        bootstrapDecOffset.uncertainty^2]);
    
else

    nTrials = nQuarters^2;
    
    bootstrapRaArray = zeros([nTrials, 1]);
    bootstrapDecArray = zeros([nTrials, 1]);
    
    indexArray = fix(nQuarters * rand(nTrials, nQuarters)) + 1;
    
    for iTrial = 1 : nTrials
        
        indices = indexArray(iTrial, : );
        bootstrapRaArray(iTrial) = mean(raOffsetValues(indices));
        bootstrapDecArray(iTrial) = mean(decOffsetValues(indices));
        
    end % for iTrial
    
    bootstrapRaOffset.value = mean(bootstrapRaArray);
    bootstrapRaOffset.uncertainty = std(bootstrapRaArray);
    
    bootstrapDecOffset.value = mean(bootstrapDecArray);
    bootstrapDecOffset.uncertainty = std(bootstrapDecArray);
    
    bootstrapCovariance = cov(bootstrapRaArray, bootstrapDecArray);
    
end % if / else

% Add the MQ offset constant uncertainty in quadrature to the uncertainties
% for each of the RA/Dec components. Steve Bryson has shown that this is
% equivalent to adding the same constant uncertainty in quadrature to the
% uncertainty in the offset distance derived from the RA/Dec components.
bootstrapRaOffset.uncertainty = ...
    sqrt(bootstrapRaOffset.uncertainty^2 + mqOffsetConstantUncertainty^2);
bootstrapDecOffset.uncertainty = ...
    sqrt(bootstrapDecOffset.uncertainty^2 + mqOffsetConstantUncertainty^2);

bootstrapCovariance = ...
    bootstrapCovariance + mqOffsetConstantUncertainty^2 * eye(2);

% Return.
return
