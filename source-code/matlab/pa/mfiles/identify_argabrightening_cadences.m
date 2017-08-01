function [isArgaCadence, argaCadences, argaStatistics] = ...
identify_argabrightening_cadences(pixelValues, pixelGapIndicators, ...
cadenceNumbers, argabrighteningConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [backgroundPolyStruct, argaCadences] = ...
% identify_lc_argabrightening_cadences(pixelValues, pixelGapIndicators, ...
% cadenceNumbers, argabrighteningConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify the Argabrightening cadences from the two dimensional array of
% given pixel values. In the long cadence case, these will be all of the
% calibrated background pixel time series for the module output. In the
% short cadence case, these will be all of the calibrated pixel time series
% for the target pixels that fall outside of the optimal target apertures
% in the first short cadence PA target invocation.
%
% First, compute the median level of the input pixel values on a cadence by
% cadence basis. Then, fit a low order polynomial trend and perform median
% filtering on the residual. The polynomial detrending is only necessary
% to reduce the edge effects for the median filter. Apply a MAD threshold
% to identify the Argabrightening cadences. Return a vector of logicals
% indicating the Argabrightening cadences, a list of the (absolute)
% cadence numbers of the Argabrightening cadences, and a vector containing
% the computed Argabrightening statistics for the given module output.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%               pixelValues: [float array]  nCadences x nPixels array of
%                                           pixel values
%        pixelGapIndicators: [float array]  nCadences x nPixels array of
%                                           pixel gap indicators
%             cadenceNumbers: [int array]   nCadences x 1 array of absolute
%                                           cadence numbers
%   argabrighteningConfigurationStruct:
%                                 [struct]  Argabrightening mitigation parameters
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  argabrighteningConfigurationStruct is a struct with the following fields:
%
%                 mitigationEnabled: [int]  identify Argabrightening cadences if
%                                           true and gap PA outputs
%                          fitOrder: [int]  polynomial order for detrending
%                medianFilterLength: [int]  order of median filter
%                    madThreshold: [float]  threshold for identifying
%                                           Argabrightening cadences
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%           isArgaCadence: [logical array]  nCadences x 1 array of logicals,
%                                           true for Argabrightening cadences
%                argaCadences: [int array]  list of Argabrightening cadences
%            argaStatistics: [float array]  MAD's from median residual for
%                                           each cadence
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


% Get fields from the input arguments.
fitOrder = argabrighteningConfigurationStruct.fitOrder;
medianFilterLength = argabrighteningConfigurationStruct.medianFilterLength;
madThreshold = argabrighteningConfigurationStruct.madThreshold;

% Compute the median pixel level for each cadence and determine the valid
% cadences.
pixelValues(pixelGapIndicators) = NaN;
nominalLevel = nanmedian(pixelValues, 2);
gapIndicators = isnan(nominalLevel);
nominalLevel(gapIndicators) = 0;

% set default output values
isArgaCadence = false(size(gapIndicators));
argaCadences = [];
argaStatistics = zeros(size(gapIndicators));

% Return immediately if there are too few valid cadences to do anything
% useful.
nValidCadences = sum(~gapIndicators);
if nValidCadences <= fitOrder + 1 
    return
end % if

% Detrend the median level time series and perform median filtering.
if medianFilterLength > nValidCadences
    medianFilterLength = nValidCadences;
end % if

nominalLevel = detrendcols(nominalLevel, fitOrder, find(gapIndicators));
residuals = nominalLevel(~gapIndicators) - ...
    medfilt1(nominalLevel(~gapIndicators), medianFilterLength);

% Apply a MAD threshold to the residual levels. Identify the
% Argabrightening cadences. Return the Argabrightening cadence indicators,
% numbers and statistics for all cadences.
medianAbsoluteDeviation = mad(residuals, 1);
isOverThreshold = abs(residuals - median(residuals)) > ...
    madThreshold * medianAbsoluteDeviation;

validIndices = find(~gapIndicators);
argaCadences = cadenceNumbers(validIndices(isOverThreshold));
isArgaCadence = ismember(cadenceNumbers, argaCadences);
argaStatistics(~gapIndicators) = ...
    (residuals - median(residuals)) / medianAbsoluteDeviation;

% Return.
return
