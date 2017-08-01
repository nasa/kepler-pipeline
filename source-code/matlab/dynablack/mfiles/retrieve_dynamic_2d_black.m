
function [ black, blackUnc] = retrieve_dynamic_2d_black( initializedModels, oneBasedRows, oneBasedColumns, mjds, listMode )
%
% function [ black, blackUnc] = retrieve_dynamic_2d_black( initializedModels, oneBasedRows, oneBasedColumns, mjds, listMode )
%
% Retrieve dynamic 2D black from initializedModels given list of rows (oneBasedRows) and columns (oneBasedColumns)
% for list of mjds. The parameter listMode {1,2} is used in the call to DynOBlack.
% 1 == input is a list of row, column pairs
% 2 == input is a list of rows and a list of columns which define a 2D region onthe CCD
% 
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


% Interpolate mjds requested onto the mjds for the long cadences actually fit in dynablack
% This gives the relative long cadence indices for DynOBlack (which could be fractional) 
fittedLongCadenceIdx = initializedModels.FCLC_list;
fittedLongCadenceGapIndicators = initializedModels.FCLC_gapIndicators;
fittedMjds = initializedModels.midTimestamps(fittedLongCadenceIdx);


% Note: The set of long cadences fit in dynablack are not necessarily evenly sampled. So a fractional index is not necessarily the same
% fraction of a long cadence.
relativeIdx = interp1( fittedMjds(:), 1:length(fittedLongCadenceIdx), mjds(:), 'linear', 'extrap'); 

% set any relativeIdx outside the fitted long cadence index range to the appropriate endpoint
relativeIdx(relativeIdx > length(fittedLongCadenceIdx)) = length(fittedLongCadenceIdx);
relativeIdx(relativeIdx < 1) = 1;

% Round any relativeIdx that fall in gapped fitted cadence indices to the nearest ungapped fitted cadence index.
% Nearest is in the mjd sense, not in the relative index sense.
% This prevents any gapped dynablack data from being used for interpolation to return blacks.
gappedFittedIdx = find(fittedLongCadenceGapIndicators);
unGappedFittedIdx = find(~fittedLongCadenceGapIndicators);
gappedIdxIndicator = false(size(relativeIdx));

% find the relativeIdx indices that are close to fittedIdx gaps
for i=1:length(relativeIdx)
    gappedIdxIndicator(i) = any(abs(relativeIdx(i)-gappedFittedIdx)<1);
end

% fill those relativeIdx with the closest (in time) ungapped fitted relative index
relativeIdx(gappedIdxIndicator) = interp1(fittedMjds(unGappedFittedIdx),unGappedFittedIdx,mjds(gappedIdxIndicator),'nearest','extrap');


% call DynOBlack retriever with listed row and column coordinates over the list of relative long cadences
% --> listMode == 1; row/column pairs
% --> listMode == 2; 2D region
[ black blackUnc ]  = DynOBlack( oneBasedRows, oneBasedColumns, relativeIdx, listMode, initializedModels );

