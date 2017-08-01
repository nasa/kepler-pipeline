function [imageMotionResults] = ...
compute_bootstrap_prf_fit_centroid_offsets(diagnostics, ...
referenceRa, referenceDec, imageMotionResults, ...
mqOffsetConstantUncertainty, singlePrfFitForCentroidPositionsEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [imageMotionResults] = ...
% compute_bootstrap_prf_fit_offsets(diagnostics, ...
% referenceRa, referenceDec, imageMotionResults, ...
% mqOffsetConstantUncertainty, singlePrfFitForCentroidPositionsEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the centroid offsets with respect to the out of transit centroid
% and the KIC reference position by averaging the results from the
% bootstrap PRF fit trials. This function is called in the pipeline only if
% the bootstrap successfully ran to completion so all RA/Dec coordinates
% provided in the diagnostics structure are assumed to be valid. Input
% centroid and KIC reference coordinates are in units of degrees. Centroid
% offsets are returned in units of arcseconds. Add the MQ offset constant
% uncertainty in quadrature to each of the offset components; it may or may
% not be set to 0.
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

% Define constants.
ARCSECONDS_PER_DEGREE = 60 * 60;
DEGREES_PER_HOUR = 360 / 24;

% Compute the mean offsets and standard deviations for the centroid offsets
% with respect to the out of transit position. Set the uncertainties equal
% to the respective standard deviations.
referenceRaArray = diagnostics.directRaArray;
referenceDecArray = diagnostics.directDecArray;
centroidRaArray = diagnostics.differenceRaArray;
centroidDecArray = diagnostics.differenceDecArray;

raOffsets = ARCSECONDS_PER_DEGREE * ...
    (centroidRaArray - referenceRaArray) .* cosd(referenceDecArray);
decOffsets = ARCSECONDS_PER_DEGREE * (centroidDecArray - referenceDecArray);

if singlePrfFitForCentroidPositionsEnabled
    
    controlCentroidRaDegrees = DEGREES_PER_HOUR * ...
        imageMotionResults.mqControlImageCentroid.raHours.value;
    controlCentroidDecDegrees = ...
        imageMotionResults.mqControlImageCentroid.decDegrees.value;
    differenceCentroidRaDegrees = DEGREES_PER_HOUR * ...
        imageMotionResults.mqDifferenceImageCentroid.raHours.value;
    differenceCentroidDecDegrees = ...
        imageMotionResults.mqDifferenceImageCentroid.decDegrees.value;
    
    raOffset = ARCSECONDS_PER_DEGREE * ...
        (differenceCentroidRaDegrees - controlCentroidRaDegrees) * ...
        cosd(controlCentroidDecDegrees);
    decOffset = ARCSECONDS_PER_DEGREE * ...
        (differenceCentroidDecDegrees - controlCentroidDecDegrees);
    
else
    
    raOffset = mean(raOffsets);
    decOffset = mean(decOffsets);
    
end % if / else

Crd = cov(raOffsets, decOffsets);
Crd = Crd + mqOffsetConstantUncertainty^2 * eye(2);

imageMotionResults.mqControlCentroidOffsets.singleFitRaOffset.value = ...
    raOffset;
imageMotionResults.mqControlCentroidOffsets.singleFitRaOffset.uncertainty = ...
    sqrt(Crd(1, 1));
imageMotionResults.mqControlCentroidOffsets.singleFitDecOffset.value = ...
    decOffset;
imageMotionResults.mqControlCentroidOffsets.singleFitDecOffset.uncertainty = ...
    sqrt(Crd(2, 2));

skyOffset = sqrt(raOffset^2 + decOffset^2);
Jrd = [raOffset, decOffset] / skyOffset;
imageMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.value = ...
    skyOffset;
imageMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.uncertainty = ...
    sqrt(Jrd * Crd * Jrd');

% Compute the mean offsets and standard deviations for the centroid offsets
% with respect to the KIC position. Set the uncertainties equal to the
% respective standard deviations.
if ~isempty(referenceRa) && ~isempty(referenceDec)
    
    raOffsets = ARCSECONDS_PER_DEGREE * ...
        (centroidRaArray - referenceRa) .* cosd(referenceDec);
    decOffsets = ARCSECONDS_PER_DEGREE * (centroidDecArray - referenceDec);
    
    if singlePrfFitForCentroidPositionsEnabled

        raOffset = ARCSECONDS_PER_DEGREE * ...
            (differenceCentroidRaDegrees - referenceRa) * ...
            cosd(referenceDec);
        decOffset = ARCSECONDS_PER_DEGREE * ...
            (differenceCentroidDecDegrees - referenceDec);
        
    else
        
        raOffset = mean(raOffsets);
        decOffset = mean(decOffsets);
    
    end % if / else
    
    Crd = cov(raOffsets, decOffsets);
    Crd = Crd + mqOffsetConstantUncertainty^2 * eye(2);

    imageMotionResults.mqKicCentroidOffsets.singleFitRaOffset.value = ...
        raOffset;
    imageMotionResults.mqKicCentroidOffsets.singleFitRaOffset.uncertainty = ...
        sqrt(Crd(1, 1));
    imageMotionResults.mqKicCentroidOffsets.singleFitDecOffset.value = ...
        decOffset;
    imageMotionResults.mqKicCentroidOffsets.singleFitDecOffset.uncertainty = ...
        sqrt(Crd(2, 2));
    
    skyOffset = sqrt(raOffset^2 + decOffset^2);
    Jrd = [raOffset, decOffset] / skyOffset;
    imageMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.value = ...
        skyOffset;
    imageMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.uncertainty = ...
        sqrt(Jrd * Crd * Jrd');
    
end % if

% Return.
return
