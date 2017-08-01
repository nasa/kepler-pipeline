function [startIndices, gapLengths] = find_gaps( gapIndicators, roi )
%**************************************************************************  
% function [startIndices, gapLengths] = find_gaps( gapIndicators, roi )
%**************************************************************************  
% Determine the lengths of gaps in the logical gapIndicators input vector.
%
% INPUTS:
%     gapIndicators : Gap indicators for this time series
%     roi           : A region of interest (cadence indices). Only report
%                     on gaps that overlap these cadences. 
% OUTPUTS:
%     startIndices  : Starting cadence of each gap, in order.
%     gapLengths    : An array of gap lengths corresponding to each
%                     starting index.
%
%**************************************************************************  
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
    nCadences = length(gapIndicators);
    
    if ~exist('roi','var')
        roi = 1:nCadences;
    end
    
    %----------------------------------------------------------------------
    % Handle cases where all or none of the cadences are gapped.
    %----------------------------------------------------------------------
    if ~any(gapIndicators)
        startIndices = [];
        gapLengths   = [];
        return
    elseif all(gapIndicators)
        startIndices = 1;
        gapLengths   = nCadences;
        return
    end
    
    %----------------------------------------------------------------------
    % From here on we know some cadences are gapped and some are not.
    %----------------------------------------------------------------------
    firstDifference = diff(gapIndicators(:));
    beforeGaps = find( firstDifference > 0 );
    lastInGaps = find( firstDifference < 0 );
    
    % Consider cases where a gap exists at the beginning or end of a time
    % series.   
    if isempty(beforeGaps) || ...
           (~isempty(lastInGaps) && lastInGaps(1) - beforeGaps(1) <= 0)
        beforeGaps = [0; beforeGaps];
    end
    
    if isempty(lastInGaps) || ...
           (~isempty(beforeGaps) && lastInGaps(end) - beforeGaps(end) <= 0)
        lastInGaps = [lastInGaps; nCadences];
    end
    
    % We want to consider the total width of each gap that overlaps the
    % roi.
    considerTheseGaps = ismember(beforeGaps, roi) | ismember(lastInGaps, roi);
    startIndices = beforeGaps(considerTheseGaps) + 1;
    gapLengths = lastInGaps(considerTheseGaps) ...
        - beforeGaps(considerTheseGaps);
    
end


%********************************** EOF ***********************************

