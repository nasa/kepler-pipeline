function plot_empirical_correlation(intermediateFluxTimeSeries)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_empirical_correlation(intermediateFluxTimeSeries)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the empirical target to target flux time series correlation.
% Normalize each flux time series prior to determining the correlation.
% 
% This function calls pdc_compute_correlation to do the actual correlation calculation.
%
% input:
%   intermediateFluxTimeSeries -- [struct array(nTargets)]
%       used fields:
%               .values -- [double array(nCadences)] flux time series
%               .gapIndicators -- [logical array(nCadences)] gap indicators
%
% Output:
%   none, just a figure;
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


% Remove the mean from the corrected flux values.
fluxValues = [intermediateFluxTimeSeries.values];
fluxGapIndicators = [intermediateFluxTimeSeries.gapIndicators];
nCadences = size(fluxValues, 1);

fluxValues(fluxGapIndicators) = 0;
nValidSamples = sum(~fluxGapIndicators, 1);
meanFlux = sum(fluxValues, 1) ./ nValidSamples;
fluxValues = fluxValues - repmat(meanFlux, [nCadences, 1]);
fluxValues(fluxGapIndicators) = 0;

% Create temporary targetDataStruct with the normalized flux
targetTempDataStruct = intermediateFluxTimeSeries;
for iTarget = 1 : length(intermediateFluxTimeSeries)
    targetTempDataStruct(iTarget).values = fluxValues(:,iTarget);
end

% The actual correlation calculation
correlationMatrix = pdc_compute_correlation(targetTempDataStruct);

% Plot the correlation matrix.
isLandscapeOrientation = true;
includeTimeFlag = false;
printJpgFlag = false;

imagesc(abs(correlationMatrix));
colorbar;
title('[PDC] Empirical Target to Target Correlation');

plot_to_file('pdc_empirical_correlation_post_correction', isLandscapeOrientation, ...
    includeTimeFlag, printJpgFlag);
    
% Return.
return
