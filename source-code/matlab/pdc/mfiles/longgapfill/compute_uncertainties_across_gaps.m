function [uncertaintiesWithGapsFilled] = ...
compute_uncertainties_across_gaps(uncertaintiesWithGaps, dataGapIndicators, ...
gapLocations)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [uncertaintiesWithGapsFilled] = ...
% compute_uncertainties_across_gaps(uncertaintiesWithGaps, dataGapIndicators, ...
% gapLocations)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute uncertainties for long gap filled samples by tapering the rms
% uncertainty for samples to left of each gap to the rms uncertainty of
% samples to right of each gap. The rms uncertainty is equivalent to the
% square root of the mean variance.
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


% Get length of uncertainties series.
nLength = length(uncertaintiesWithGaps);

% Get the basic gap info.
nGaps = size(gapLocations, 1);
gapLengths = gapLocations( : , 2) - gapLocations( : , 1) + 1;

% Loop through the gaps, and taper the uncertainties across each one from
% the rms uncertainty in the samples to the left to the rms uncertainty in
% the samples to the right.
for i = 1 : nGaps

    % Get the gap size and indices for the given gap.
    currentGapSize = gapLengths(i);
    iGapBegin = gapLocations(i, 1);
    iGapEnd = gapLocations(i, 2);

    % It is possible that this gap could be the first (or the last) in which
    % case there may not be enough points to compute the rms uncertainty.
    % Use only the available points.
    iLeftDataSegmentEnd = gapLocations(i, 1) - 1;
    iLeftDataSegmentBegin = max(gapLocations(i, 1) - currentGapSize, 1);

    % For each gap, compute the rms uncertainty of the samples to the left.
    % Make sure not to include any gapped uncertainties in the rms
    % calculation.
    leftSegmentUncertainties = ...
        uncertaintiesWithGaps(iLeftDataSegmentBegin : iLeftDataSegmentEnd);
    leftSegmentDataGaps = ...
        dataGapIndicators(iLeftDataSegmentBegin : iLeftDataSegmentEnd);
    leftSegmentRmsUncertainty = ...
        sqrt(mean(leftSegmentUncertainties(~leftSegmentDataGaps) .^ 2));

    % Get the right segment and do the tapering. Skip the final gap if it
    % was introduced to make the signal length equal to a power of two.
    iRightDataSegmentBegin = gapLocations(i, 2) + 1;

    if iRightDataSegmentBegin < nLength

        iRightDataSegmentEnd = ...
            min(gapLocations(i, 2) + currentGapSize, nLength);
        
        % For each gap, compute the rms uncertainty of the samples to the right.
        % Make sure not to include any gapped uncertainties in the rms
        % calculation.
        rightSegmentUncertainties = ...
            uncertaintiesWithGaps(iRightDataSegmentBegin : iRightDataSegmentEnd);
        rightSegmentDataGaps = ...
            dataGapIndicators(iRightDataSegmentBegin : iRightDataSegmentEnd);
        rightSegmentRmsUncertainty = ...
            sqrt(mean(rightSegmentUncertainties(~rightSegmentDataGaps) .^ 2));

        % Take care of case(s) where left or right samples are not
        % available for filling.
        if isnan(leftSegmentRmsUncertainty) && isnan(rightSegmentRmsUncertainty)
            continue;
        elseif isnan(leftSegmentRmsUncertainty)
            leftSegmentRmsUncertainty = rightSegmentRmsUncertainty;
        elseif isnan(rightSegmentRmsUncertainty)
            rightSegmentRmsUncertainty = leftSegmentRmsUncertainty;
        end
        
        % Taper the rms uncertainty across the filled gap.
        linearTaperUncertainty = leftSegmentRmsUncertainty - ...
            (leftSegmentRmsUncertainty - rightSegmentRmsUncertainty ) .* ...
            (0 : currentGapSize + 1) ./ (currentGapSize + 1);
        
        % Update the uncertainties and also the data gap indicators. This
        % allows tapered uncertainties to be used to help estimate the
        % uncertainties for filled gaps to the right.
        uncertaintiesWithGaps(iGapBegin : iGapEnd) = ...
            linearTaperUncertainty(2 : end - 1);
        dataGapIndicators(iGapBegin : iGapEnd) = false;
        
    end % if
    
end % for

% Copy the esimated uncertainties to the output vector.
uncertaintiesWithGapsFilled = uncertaintiesWithGaps;

% Return.
return
