function [deemphasisParameterSuperResolution, deemphasisParameter] = ...
    update_deemphasis_parameter_for_long_gaps( deemphasisParameter, ...
    deemphasisPeriodInCadences, gapFillParametersStruct, superResolutionFactor )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% update_deemphasis_parameter_for_long_gaps
%
% Description:  This function looks for long gaps that have no deemphasis
% on their boundaries and updates the deemphasisParameter so they are
% deemphasized on the boundary.  This is a target specific update to the
% deemphasisParameter which is originally not target specific.
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

% determine the minimum long gap length
maxArOrderLimit = gapFillParametersStruct.maxArOrderLimit; %% max AR model order limit set for choose_fpe_model_order function.
maxCorrelationWindowXFactor = gapFillParametersStruct.maxCorrelationWindowXFactor;
maxShortGapLength = maxCorrelationWindowXFactor * maxArOrderLimit;

% find where the deemphasisParameter is 1
gapLocations = find_datagap_locations( deemphasisParameter == 0 );

if ~isempty(gapLocations)
    gapLengths = gapLocations(:,2) - gapLocations(:,1) + 1;

    % remove all but long gaps
    gapLocations = gapLocations( gapLengths > maxShortGapLength, : );
    nGaps = sum( gapLengths > maxShortGapLength );
    nCadences = length(deemphasisParameter);
    
    % get the smallest deemphasisParameter outside the gap
    dummyDeemphasisParameter = set_deemphasis_parameter( ...
        [deemphasisPeriodInCadences+1 deemphasisPeriodInCadences+2], ...
        deemphasisPeriodInCadences, deemphasisPeriodInCadences+2);
    minDeemphasisParameter = min(dummyDeemphasisParameter(dummyDeemphasisParameter~=0));

    % determine which long gaps have no deemphasis at the borders
    needDeemphasis = false(nGaps,1);
    for iGap = 1:nGaps
        gapStart = gapLocations(iGap,1);
        gapEnd = gapLocations(iGap,2);
        if ~(isequal(gapStart,1) && isequal(gapEnd,nCadences))
            if isequal(gapStart,1) 
                needDeemphasis(iGap) = deemphasisParameter(gapEnd + 1) > minDeemphasisParameter;
            elseif isequal(gapEnd,nCadences) 
                needDeemphasis(iGap) = deemphasisParameter(gapStart - 1) > minDeemphasisParameter;
            else
                needDeemphasis(iGap) = (deemphasisParameter(gapEnd + 1) > minDeemphasisParameter) | ...
                    (deemphasisParameter(gapStart - 1) > minDeemphasisParameter);
            end
        end
    end

    % deemphasize boundaries of long gaps that need it
    if any(needDeemphasis)
        gapLocations = gapLocations( needDeemphasis, : );
        deemphasisParameterTemp = set_deemphasis_parameter( gapLocations, ...
            deemphasisPeriodInCadences, nCadences ) ;
        deemphasisParameter = min( deemphasisParameter, deemphasisParameterTemp );
    end
end

% convert this to super resolution time interval

if(superResolutionFactor > 1)
    deemphasisParameterSuperResolution = repmat( deemphasisParameter,1, superResolutionFactor ) ;
    deemphasisParameterSuperResolution = deemphasisParameterSuperResolution' ;
    deemphasisParameterSuperResolution = deemphasisParameterSuperResolution(:);
else
    deemphasisParameterSuperResolution = deemphasisParameter ;
end   
return