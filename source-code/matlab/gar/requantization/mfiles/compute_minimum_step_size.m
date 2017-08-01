function [minimumStepSize, intrinsicNoiseVarianceMin, originalQuantizationNoiseVariance] = ...
    compute_minimum_step_size(tableEntryInAdu, numberOfTemporalCoAdds, numberOfSpatialCoAdds,...
    deviationsFromMeanBlackMaxMin, gainTable, readNoiseTable, quantizationFraction, fixedOffset, rssOutOriginalQuantizationNoiseFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [minimumStepSize, photoElectronsAboveZeroMin] = compute_minimum_step_size(tableEntryInAdu, ...
%     numberOfTemporalCoAdds, numberOfSpatialCoAdds,...
%     deviationsFromMeanBlackMaxMin, gainTable, readNoiseTable, quantizationFraction, fixedOffset)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function computes the minimum requantization table step size for the
% current entry given the black table of min, max values over all the 84
% modouts, the gain table, number of temporal and spatial coadds. This
% minimum stepsize ensures that the ratio between the intrinsic noise
% variance (sum of shot noise, read noise, and quantization noise) and
% quantization noise variance is maintained at the specified
% quantizationFraction.
%
%  Inputs:
%       1. tableEntryInAdu
%       2. numberOfTemporalCoAdds
%       3. numberOfSpatialCoAdds
%       4. deviationsFromMeanBlackMaxMin  - a table containing 84 x 2 entries; the
%       first column contains the max values and the second olumn contains
%       the min value of the black 2D values for the specified data type
%       (for example, for black collateral data type, this table contains
%       min, max values collected over the black collateral region only)
%       5. gainTable - a table containing 84 entries
%       6. readNoiseTable - a table containing 84 entries
%       7. quantizationFraction - a scalar
%       8. fixedOffset - from planned spacecraft config map
%
%
%  Outputs:
%       1. minimumStepSize
%       2. intrinsicNoiseVarianceMin
%
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

% converts counts (ADU) to minimum number of photoElectrons (e-) given
% deviationsFromMeanBlackMaxMin (in ADU), and gainTable (e-/ADU) for the 84 module outputs


if(~exist('rssOutOriginalQuantizationNoiseFlag', 'var'))
    rssOutOriginalQuantizationNoiseFlag = false;
end


% per exposure (scale by numberOfTemporalCoAdds)
countsInADUAboveZero = tableEntryInAdu - fixedOffset;


% deviationsFromMeanBlackMaxMin have been spatially coadded where appropriate
% 2 column contains the Min values

photoElectronsAboveZeroMin = max(0, (countsInADUAboveZero + deviationsFromMeanBlackMaxMin(:,2)*numberOfTemporalCoAdds).*gainTable);




% Note: Calculation of the variance of Poisson Noise in ADU^2
% For all instruments the Poisson variance (per cadence) is
% calculated as:
% Variance of Poission Noise = flux (e-)^2
% Let gain = the detector gain in electrons per ADU
% Then the variance of the Poisson noise in units of (ADU^2) is
% given as follows:
% Variance of Poission Noise = flux (e-)^2/gain^2 = flux in ADU/gain

minShotNoiseVarianceInADU   = min(photoElectronsAboveZeroMin./(gainTable.^2));



readNoiseVarianceInADU = (readNoiseTable.^2)*numberOfTemporalCoAdds*numberOfSpatialCoAdds;

%--------------------------------------------------------------------------
% Jon's email dated 5/13/2008
% Eric Bachtell has pointed out (rightly) that including the original
% quantization noise from the 14-bit ADC is "double dipping". We need to
% ignore it in the calculation of the quantization step size. Can you zero
% out this term? If we really wanted to do it right, we would RSS out the
% ADC quantization noise from the desired re-quantization noise, but this
% is more complicated and data type dependent.
%--------------------------------------------------------------------------

% originalQuantizationNoiseVariance  = (1/12)*numberOfTemporalCoAdds*numberOfSpatialCoAdds; % from the ADC
% intrinsicNoiseVariance = minShotNoiseVarianceInADU + readNoiseVarianceInADU + originalQuantizationNoiseVariance; % a vector



intrinsicNoiseVariance = minShotNoiseVarianceInADU + readNoiseVarianceInADU ; % a vector; excludes the orginal quantization noise



% stepSize is set so that the quantization noise is "quantizationFraction" of the total noise stdev
% according to the following equation:
%
% stepsize      sqrt(noisevar) * quantNoiseRatio
% --------   =
% sqrt(12)
%
% solving for stepsize yields:
%
% stepSize = sqrt(intrinsicNoiseVariance) * quantizationFraction * sqrt(12);

% The maximum quantization noise allowed is composed of both original
% quantization noise and the requantization noise.

% Solve for total quantization noise desired:
totalQuantizationNoiseVarianceDesired = intrinsicNoiseVariance*quantizationFraction^2;


% compute original quantization noise
originalQuantizationNoiseVariance = numberOfTemporalCoAdds*numberOfSpatialCoAdds/12;


% RSS out the original quantization noise
if(rssOutOriginalQuantizationNoiseFlag)
    residualQuantizationNoiseVariance = max(0,totalQuantizationNoiseVarianceDesired - originalQuantizationNoiseVariance);
else
    residualQuantizationNoiseVariance = max(0,totalQuantizationNoiseVarianceDesired);
end

stepSize = sqrt(residualQuantizationNoiseVariance*12);



[minStepSize, minIndex] = min(stepSize);


minimumStepSize = max(fix(minStepSize),1);


intrinsicNoiseVarianceMin = intrinsicNoiseVariance(minIndex); % needed for verification


return
