function [outOfFamilyIndicators, distanceMeasures] = ...
identify_out_of_family_centroids(keplerMags, centroidRowUncertainties, ...
centroidColumnUncertainties, centroidGapIndicators, madThreshold, ...
thresholdMultiplier)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [outOfFamilyIndicators, distanceMeasures] = ...
% identify_out_of_family_centroids(keplerMags, centroidRowUncertainties, ...
% centroidColumnUncertainties, centroidGapIndicators, madThreshold, ...
% thresholdMultipler)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify out of family centroids by (robust) fitting a quadratic function
% separately to the row and column centroid uncertainties as a function of kepler
% magnitude, and setting an indicator to true if the row or column residual
% for any target is more than a specified number of MAD's from the median.
% The process is performed cadence by cadence. The out of family centroids
% can then be excluded from the fitting of motion polynomials. Allow for
% an optional multiplier to be applied to the thresholds for positive
% centroid uncertainty outliers. These will be de-weighted in the
% subsequent motion polynomial fit anyway.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%                keplerMags: [float array]  nTargets x 1 array of kepler
%                                           magnitudes
%  centroidRowUncertainties: [float array]  nCadences x nTargets array of
%                                           centroid row uncertainties
%             centroidColumnUncertainties: 
%                            [float array]  nCadences x nTargets
%                                           array of centroid column uncertainties
%   centroidGapIndicators: [logical array]  nCadences x nTargets array of
%                                           centroid gap indicators
%                  madThreshold: [logical]  MAD threshold for identification of
%                                           centroid outliers
%           thresholdMultiplier: [logical]  optional threshold multiplier for
%                                           positive outliers (large uncertainties)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%   outOfFamilyIndicators: [logical array]  nCadences x nTargets array of
%                                           centroid out of family indicators
%   distanceMeasures     : [double array]   nCadences x nTargets array of
%                                           values indicating how far out
%                                           of family each centroid
%                                           uncertainty time series is on 
%                                           each cadence.
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


% HARD CODE THE QUADRATIC FIT ORDER AND OPTIONAL PARAMETERS.
FIT_ORDER = 2;
MAD_THRESHOLD = 3.5;
THRESHOLD_MULTIPLIER = 1.0;

% Set the threshold if it was not specified.
if ~exist('madThreshold', 'var')
    madThreshold = MAD_THRESHOLD;
end

if ~exist('thresholdMultiplier', 'var')
    thresholdMultiplier = THRESHOLD_MULTIPLIER;
end

% If there is only one cadence then allow the inputs (uncertainties and gap
% indicators) to be column vectors. This does not adhere to the nCadences x
% nTargets specification, but the intent is clear enough.
transposeFlag = false;

if size(centroidGapIndicators, 1) > 1 && ...
        size(centroidGapIndicators, 2) == 1
    centroidGapIndicators = centroidGapIndicators';
    centroidRowUncertainties = centroidRowUncertainties';
    centroidColumnUncertainties = centroidColumnUncertainties';
    transposeFlag = true;
end

% Initialize the output arrays.
outOfFamilyIndicators = false(size(centroidGapIndicators));
distanceMeasures      = zeros(size(centroidGapIndicators));

% Loop over the cadences and identify out of family centroids.
nCadences = size(centroidGapIndicators, 1);

for iCadence = 1 : nCadences
    
    % Get the gap indicators for the given cadence.
    gapIndicators = centroidGapIndicators(iCadence, : )';
    
    % Create the design matrix for the robust fit.
    designMatrix = x2fx(keplerMags(~gapIndicators), (0 : FIT_ORDER)');
    
    % Identify the out of family row uncertainties.
    [outOfFamilyIndicators, rowDist] = ...
        perform_fit_and_set_indicators(iCadence, ...
        designMatrix, centroidRowUncertainties, gapIndicators, ...
        outOfFamilyIndicators, madThreshold, thresholdMultiplier);
    
    % Identify the out of family column uncertainties.
    [outOfFamilyIndicators, colDist] = ...
        perform_fit_and_set_indicators(iCadence, ...
        designMatrix, centroidColumnUncertainties, gapIndicators, ...
        outOfFamilyIndicators, madThreshold, thresholdMultiplier);
    
    % Take the Euclidean norm of the row and column "distances".
    distanceMeasuresThisCadence = sqrt(rowDist .^ 2 + colDist .^ 2);
    if nCadences > 1
        distanceMeasures(iCadence, :) = distanceMeasuresThisCadence;
    else
        distanceMeasures = distanceMeasuresThisCadence;
    end
end % for iCadence

% Transpose the outputs if necessary.
if transposeFlag
    outOfFamilyIndicators = outOfFamilyIndicators';
    distanceMeasures      = distanceMeasures';
end

% Return.
return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [outOfFamilyIndicators, distance] = ...
%     perform_fit_and_set_indicators(iCadence, designMatrix, ...
%         centroidUncertainties, gapIndicators, outOfFamilyIndicators, ...
%         threshold, multiplier)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%     iCadence               : 1 x 1 scalar
%     designMatrix           : nUngappedCadences x (fitOrder+1)
%     centroidUncertainties  : nCadences x nTargets
%     gapIndicators          : nCadences x 1
%     outOfFamilyIndicators  : nCadences x nTargets
%     threshold              : 1 x 1 scalar
%     multiplier             : 1 x 1 scalar
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%   outOfFamilyIndicators    : nCadences x nTargets array of centroid out
%                              of family indicators.
%   distance                 : 1 x nTargets array of values indicating how
%                              far out of family each centroid uncertainty
%                              time series is on iCadence.   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [outOfFamilyIndicators, distance] = ...
    perform_fit_and_set_indicators(iCadence, designMatrix, ...
        centroidUncertainties, gapIndicators, outOfFamilyIndicators, ...
        threshold, multiplier)

% Perform the robust fit to the centroid uncertainties. Move on to the
% next cadence if the fit fails. Note that the output variable 'distance'
% must be defined here in case the catch block below is executed.
uncertainties = centroidUncertainties(iCadence, ~gapIndicators)';
distance = zeros(1, size(outOfFamilyIndicators, 2));

warning off all
try
    fitPoly = robustfit(designMatrix, uncertainties, [], [], 'off');
catch
    warning on all
    return
end
warning on all

% Compute the fit residuals.
fitResiduals = uncertainties - designMatrix * fitPoly;

% Identify the residuals that are out of family.
fitResiduals = fitResiduals - median(fitResiduals);
medianAbsoluteDeviation = mad(fitResiduals, 1);

isPositiveResidual = fitResiduals > 0;
fitResiduals(isPositiveResidual) = ...
    fitResiduals(isPositiveResidual) / multiplier;
isOverThreshold = abs(fitResiduals) > threshold * medianAbsoluteDeviation;

validIndices = find(~gapIndicators);
outOfFamilyIndicators(iCadence, validIndices(isOverThreshold)) = true;

% Return a measure of "out-of-familiness" on this cadence for each
% non-gapped centroid uncertainty timeseries.
if medianAbsoluteDeviation > 0
    distance(~gapIndicators) = abs(fitResiduals) / medianAbsoluteDeviation;
end

% TEMPORARY.
% hold off
% k = designMatrix(:,2);
% plot(k, uncertainties, '.b')
% hold on
% plot(k, designMatrix*fitPoly, '.r')
% plot(k, fitResiduals, '.g')
% v = threshold * medianAbsoluteDeviation;
% plot([11; 13.5], [v; v], '--k')
% plot([11; 13.5], [-v; -v], '--k')
% plot(k(isOverThreshold), uncertainties(isOverThreshold), 'or')
% grid
% title(['Centroids out of family = ', num2str(sum(isOverThreshold))])
% pause

% Return.
return
