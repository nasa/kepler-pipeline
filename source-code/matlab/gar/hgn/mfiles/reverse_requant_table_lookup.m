function [indxRequantPixelValues] = ...
reverse_requant_table_lookup(requantTable, indxRequantTable, requantPixelValues, ...
gapIndicators, requantEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [indxRequantPixelValues] = ...
% reverse_requant_table_lookup(requantTable, indxRequantTable, requantPixelValues, ...
% gapIndicators, requantEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get the indices into a table of requantization values corresponding to each
% element of a vector of requantized pixel values. The table lookup is
% implememented with the matlab 'interp1' function with the 'nearest' method.
% Extrapolation for values outside the range of the requantization table is
% specified with the 'extrap' option.
%
% Check to ensure that all output indices are integer-valued. Also verify that
% the table indices are correct for all requantized pixels.
%
% Set all requantization table indices to NaN (matlab not-a-number) if the
% associated gap indicator is true. These are missing pixels, and will be
% ignored in generation of the Huffman histograms.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%             requantTable: [int array]  requantization table values
%         indxRequantTable: [int array]  indices into requantization table
%       requantPixelValues: [int array]  requantized pixel values
%        gapIndicators: [logical array]  missing pixel indicators
%             requantEnabled: [logical]  requantization enabled flag
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  The following variable is returned by this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%   indxRequantPixelValues: [int array]  table indices of requantized pixels
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


% Assume that requantization was enabled if the flag was not specified.
if nargin < 5
    requantEnabled = true;
end

% Set all missing pixel values to a known table value to ensure that
% lookups succeed in these cases. The indices corresponding to these values
% will later be set to NaN.
requantPixelValues(gapIndicators) = requantTable(1);

% Do the reverse lookup with interp1. Specify nearest neighbor
% interpolation with extrapolation for out of range values.
indxRequantPixelValues = interp1(requantTable, indxRequantTable, ...
    requantPixelValues, 'nearest', 'extrap');

% Check for sanity. Only check for table lookup errors if requantization
% was enabled.
if ~isequal(indxRequantPixelValues, fix(indxRequantPixelValues))
    error('GAR:reverseRequantTableLookup:nonIntegerTableIndex', ...
        'Requantization table index is not an integer');
end


if requantEnabled && ...
        ~isequal(requantPixelValues, requantTable(indxRequantPixelValues + 1))
    indxFailures = ...
        find(requantPixelValues ~= requantTable(indxRequantPixelValues + 1));
    error('GAR:reverseRequantTableLookup:tableLookupError', ...
        'Requantization table lookup error (first bad pixel value = %d)', ...
        requantPixelValues(indxFailures(1)));
end


% Set indices of missing pixel values to NaN.
indxRequantPixelValues(gapIndicators) = NaN;

% Return.
return
 