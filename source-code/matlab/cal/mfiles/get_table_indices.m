function [indxRequantPixelValues, requantTableId, requantTable] = ...
    get_table_indices(requantTables, requantPixelValuesArray, ...
    cadenceTimes, cadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [indxRequantPixelValues, requantId, requantTable] = ...
% get_table_indices(requantTables, requantPixelValuesArray, ...
% cadenceTimes, cadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform reverse requantization table lookup to obtain the table indices
% for the requantized pixel values for the given cadence. Set the gap
% indicators for requantized pixel values that equal NAN_VALUE. The requantization
% table to be utilized must first be identified from the time tag for the
% given cadence. Return the table indices, the table ID and the table
% entries.
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

% Define constants.
NAN_VALUE = -1;
EMPTY_VALUE = -1;

% Initialize variables.
indxRequantTable = (0 : length(requantTables(1).requantEntries) - 1)';
requantStartTags = [requantTables.startMjd];

% Get the requantized pixel values for the given cadence and set the gap
% indicators.
requantPixelValues = requantPixelValuesArray( : , cadence);
gapIndicators = (NAN_VALUE == requantPixelValues);

% Check if cadence timestamp is valid. If not then make sure to return all
% NaN's.
if ~cadenceTimes.gapIndicators(cadence)
    
    % Identify the correct requant table for the given cadence and perform a
    % reverse table lookup to obtain the table indices for the given pixels
    % values.
    cadenceTimestamp = cadenceTimes.timestamp(cadence);
    [sortedStartTags, indxSortedStartTags] = ...
        sort(requantStartTags, 'descend');
    indxSortedStartTags = ...
        indxSortedStartTags(sortedStartTags <= cadenceTimestamp);
    
    if isempty(indxSortedStartTags)
        error('CAL:getTableIndices:requantTableIdFailure', ...
            'Unable to identify requantization table for cadence time tag (%f)', ...
            cadenceTimestamp);
    else
        indxTable = indxSortedStartTags(1);
    end
    
    requantTableId = requantTables(indxTable).externalId;
    requantTable = requantTables(indxTable).requantEntries;
    requantEnabled = cadenceTimes.requantEnabled(cadence);
    indxRequantPixelValues = reverse_requant_table_lookup(requantTable, ...
        indxRequantTable, double(requantPixelValues), gapIndicators, ...
        requantEnabled);

else % cadence timestamp is not valid
    
    % Return all NaN's.
    requantTableId = EMPTY_VALUE;
    requantTable = NaN(size(requantTables(1).requantEntries));
    indxRequantPixelValues = NaN(size(requantPixelValues));
    
end % if/else

% Return.
return
