function [values] = ...
correct_time_series_discontinuities(values, discontinuityIndices, ...
discontinuityStepSizes, gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [values] = ...
% correct_time_series_discontinuities(values, discontinuityIndices, ...
% discontinuityStepSizes, gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Correct the given time series values for the discontinuities specified by
% the indices and step sizes. For each discontinuity, *subtract* the step
% size from all time series values following the index of the
% discontinuity. Ensure first that the indices are sorted. If gap
% indicators are specified then set all gapped values to zero in the
% adjusted time series.
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


% Set the gap indicators to false if they were not specified.
if ~exist('gapIndicators', 'var')
    gapIndicators = false(size(values));
end

% Check the usage.
if length(discontinuityIndices( : )) ~= length(discontinuityStepSizes( : ))
    error('PDC:correctTimeSeriesDiscontinuities:inconsistentDiscontinuitySpecification', ...
        'lengths of discontinuity indices (%d) and step sizes (%d) do not agree', ...
        length(discontinuityIndices( : )), length(discontinuityStepSizes( : )));
end % if

% Ensure that the discontinuity indices are properly sorted.
[discontinuityIndices, ix] = sort(discontinuityIndices);
discontinuityStepSizes = discontinuityStepSizes(ix);

% Loop over the discontinuities and adjust the flux by the specified step
% size(s) for all samples following each discontinuity.
nCadences = length(values);
nDiscontinuities = length(discontinuityIndices);

for iDiscontinuity = 1 : nDiscontinuities
    
    index = discontinuityIndices(iDiscontinuity);
    stepSize = discontinuityStepSizes(iDiscontinuity);
    
    if index < nCadences
        values(index + 1 : end) = ...
            values(index + 1 : end) - stepSize;
    end
    
end % for iDiscontinuity

% Set the gaps to zero.
values(gapIndicators) = 0;

% Return.
return
