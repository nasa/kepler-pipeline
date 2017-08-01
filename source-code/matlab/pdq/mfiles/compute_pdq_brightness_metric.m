function pdqTempStruct = compute_pdq_brightness_metric(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct,pdqOutputStruct] =
% compute_pdq_brightness_metric(pdqScienceObject, pdqTempStruct,
% pdqOutputStruct,currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate brightness metric - a weighted mean brightness of all targets in
% the target list. This can be a subset of the original target list.
% Operates on target reference pixels after pixel level calibration and
% after background subtraction
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

starMags = pdqTempStruct.keplerMags;
numPixels = pdqTempStruct.numPixels;
targetPixels = pdqTempStruct.targetPixels;
isInOptimalAperture = pdqTempStruct.isInOptimalAperture;
targetGapIndicators = pdqTempStruct.targetGapIndicators;
fluxFractionInAperture = pdqTempStruct.fluxFractionInAperture;

% normalize simple aperture photometry flux measurements with the expected
% flux for each star; to do that need to know the flux for ref. 12th mag
% star, exp time, readout time, co adds

% Convert magnitudes into expected stellar fluxes
% Get the actual numbers from FC - including expected flux in photons
standardMag12Flux   = pdqTempStruct.standardMag12Flux;


% Get input data from data members
numCadences  = pdqTempStruct.numCadences;
numTargets   = length(pdqTempStruct.numPixels);


pdqTempStruct.observedFluxes           = zeros(numTargets, numCadences);
pdqTempStruct.correctedFluxes           = zeros(numTargets, numCadences);
pdqTempStruct.expectedFluxes           = zeros(numTargets, numCadences);
targetsUncertaintyStruct = struct('CtargetFlux', zeros(numTargets, numTargets));

pdqTempStruct.targetsUncertaintyStruct = repmat(targetsUncertaintyStruct, numCadences, 1);


for cadenceIndex = 1 : numCadences


    numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence(cadenceIndex);

    ccdExposureTime     = pdqTempStruct.configMapStruct.ccdExposureTime(cadenceIndex);

    expectedFluxes      = standardMag12Flux * ccdExposureTime * numberOfExposuresPerLongCadence * mag2b(starMags-12);

    pdqTempStruct.expectedFluxes(:, cadenceIndex) = expectedFluxes;

    indexStart = 1;

    %--------------------------------------------------------------------------
    % calculate flux of each star for each cadence using simple aperture
    % photometry
    %--------------------------------------------------------------------------
    for targetIndex = 1 : numTargets

        indexEnd = indexStart + numPixels(targetIndex) - 1;
        tPixels = targetPixels(indexStart : indexEnd, cadenceIndex);

        inOptimalAperture   = isInOptimalAperture(indexStart : indexEnd);
        gapIndicators       = targetGapIndicators(indexStart : indexEnd, cadenceIndex);

        validPixels = find( (~gapIndicators & inOptimalAperture));

        if(~isempty(validPixels))
            pdqTempStruct.observedFluxes(targetIndex, cadenceIndex) = sum(tPixels(validPixels));
        else
            pdqTempStruct.observedFluxes(targetIndex, cadenceIndex) = -1;
        end

        indexStart = indexEnd +1;

    end

    pdqTempStruct.correctedFluxes(:, cadenceIndex)   = pdqTempStruct.observedFluxes(:, cadenceIndex)./ fluxFractionInAperture; % for all 4 cadences


    validIndex = find(pdqTempStruct.correctedFluxes(:, cadenceIndex) > 0);


    if(isempty(validIndex))

        warning('PDQ:brightnessMetric:noValidCentroids', ...
            ['Can''t compute brightness metric as no valid targets are available for cadence ' num2str(cadenceIndex)]);

        pdqTempStruct.meanFluxes(cadenceIndex) = -1;
        pdqTempStruct.meanFluxesUncertainties(cadenceIndex) = -1;

        continue;

    end


    gapIndex = find(pdqTempStruct.correctedFluxes(:, cadenceIndex) < 0);
    pdqTempStruct.correctedFluxes(gapIndex, cadenceIndex) = -1;
    %--------------------------------------------------------------------------
    % derive flux metric for each cadence from the fluxes of all the stars
    % - a weighted mean brightness of all targets in the current module
    % output which is not unduly influenced by any one star
    %--------------------------------------------------------------------------


    % use robust mean to filter out bad targets
    normalizedFluxes = pdqTempStruct.correctedFluxes(validIndex, cadenceIndex) ./ pdqTempStruct.expectedFluxes(validIndex, cadenceIndex);



    warning off all;

    if(length(validIndex) > 2)

        [robustFluxMetric, robustFluxStats]  = robustfit(ones(length(validIndex),1),normalizedFluxes,[],[],0);
        warning on all;

        pdqTempStruct.meanFluxes(cadenceIndex)  = robustFluxMetric;

        if( any(robustFluxStats.w < eps))  % could easily check for 0;  == 0  is valid as robust fit sets the outlier weights to 0.

            badTargetsIndex = find(robustFluxStats.w <= eps);
            warning('PDQ:brightnessMetric:robustFluxMetric', ...
                ['brightnessMetric:ignoring bad targets [' num2str(badTargetsIndex') '] on this ccdModule ' num2str(pdqTempStruct.ccdModule) ' ccdOutput ' num2str(pdqTempStruct.ccdOutput)]);
        end

        nGoodTargets = length(find(robustFluxStats.w > 0));
        TrobustFlux = (robustFluxStats.w)./nGoodTargets;
    else
        robustFluxMetric = mean(normalizedFluxes);
        pdqTempStruct.meanFluxes(cadenceIndex)  = robustFluxMetric;

        TrobustFlux = ones(length(validIndex),1);
    end



    % target uncertainty - bin target pixel uncertainty matrix

    validPixelsForEachTarget = zeros(length(pdqTempStruct.numPixels), 1);
    cumNumPixels = cumsum(pdqTempStruct.numPixels);
    gapIndicators =  pdqTempStruct.targetGapIndicators(:, cadenceIndex);
    validPixelsForEachTarget(1) = sum(gapIndicators(1:cumNumPixels(1)));
    for j = 1: numTargets-1
        validPixelsForEachTarget(j+1) = sum(gapIndicators(cumNumPixels(j)+1 : cumNumPixels(j+1)));
    end
    validPixelsForEachTarget = pdqTempStruct.numPixels - validPixelsForEachTarget;

    CtargetPixels = pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels;

    % does essentially the same thing as binmat.m - (divides the big matrix
    % into smaller block matrices and sums their elements; two nested @sum
    % is needed to arrive at  sum(sum(matrix)) = scalar)
    cellCtargetPixels   = mat2cell(CtargetPixels, validPixelsForEachTarget, validPixelsForEachTarget);
    pdqTempStruct.targetsUncertaintyStruct(cadenceIndex).CtargetFlux = ...
        cell2mat(cellfun(@sum, cellfun(@sum, cellCtargetPixels, 'uniformoutput',false),'uniformoutput',false));

    % corrected flux uncertainties
    fluxWeights = 1./ fluxFractionInAperture;
    pdqTempStruct.targetsUncertaintyStruct(cadenceIndex).CtargetFlux = diag(fluxWeights) * pdqTempStruct.targetsUncertaintyStruct(cadenceIndex).CtargetFlux * diag(fluxWeights);

    % for the other metric
    % fluxMetricWeights = numTargets./(pdqTempStruct.expectedFluxes .* fluxFractionInAperture);

    %
    fluxMetricWeights = 1./(pdqTempStruct.expectedFluxes(:, cadenceIndex) .* numTargets);
    CtargetFlux = pdqTempStruct.targetsUncertaintyStruct(cadenceIndex).CtargetFlux;
    pdqTempStruct.meanFluxesUncertainties(cadenceIndex) = sqrt(TrobustFlux'*(fluxMetricWeights' * CtargetFlux * fluxMetricWeights)*TrobustFlux);

end

return