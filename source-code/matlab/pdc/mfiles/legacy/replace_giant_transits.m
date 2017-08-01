function [fluxWithoutTransitsArray] = ...
replace_giant_transits(fluxWithTransitsArray, gapIndicatorsArray, ...
gapFillParametersStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [fluxWithoutTransitsArray] = ...
% replace_giant_transits(fluxWithTransitsArray, gapIndicatorsArray, ...
% gapFillParametersStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify the giant transits for each target and replace them prior to
% performing the cotrend fit. The transits will still be present in the
% residuals between the original flux and the cotrend fit for each target.
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


% Get the maximum detrend polynomial order.
maxDetrendPolyOrder = gapFillParametersStruct.maxDetrendPolyOrder;

% Allocate space for relative flux without transits array .
fluxWithoutTransitsArray = zeros(size(fluxWithTransitsArray));

% Process targets one at a time.
nTargets = size(fluxWithTransitsArray, 2);

for iTarget = 1 : nTargets
    
    targetFlux = fluxWithTransitsArray( : , iTarget);
    targetFluxDataGapIndicators = gapIndicatorsArray( : , iTarget);
    
    % Identify giant transits.
    [indexOfGiantTransits] = identify_giant_transits(targetFlux, ...
        targetFluxDataGapIndicators, gapFillParametersStruct);
    
    if ~isempty(indexOfGiantTransits)
        
        % Temporarily replace the giant transits with data gaps.
        targetFlux(indexOfGiantTransits) = 0;
        targetFluxDataGapIndicators(indexOfGiantTransits) = true;

        % Fit a polynomial trend to the flux curve and replace the
        % giant transits with the trend values.
        indexAvailable = find(~targetFluxDataGapIndicators);
        nTimeSteps = (1 : length(targetFluxDataGapIndicators))';
        [fittedTrend] = fit_trend(nTimeSteps, indexAvailable, ...
            targetFlux, maxDetrendPolyOrder);
        targetFlux(indexOfGiantTransits) = fittedTrend(indexOfGiantTransits);
        
    end % if
    
    % Save the relative flux without transits in an array for further
    % processing.
    fluxWithoutTransitsArray( : , iTarget) = targetFlux;
    
end % for iTarget

% Return.
return
