function dataCompleteness = get_data_completeness(cbdObj)
% dataCompletness = get_data_completeness(cbdObj)
% Report the percentage of valid data in each of the five regions of each
% FFI
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
[ffiRows, ffiCols, ffiNumber] = size( cbdObj.originalFFIs );
if ( ffiNumber == 0 )
   error('Error: no FFIs to report data completeness'); 
end

% load the GAP_TAG
constants;

% count missings in science and 4 collateral regions
gap_counts = zeros(ffiNumber, 5);
pixel_counts = zeros(1, 5);

% no need to save this as it is easy to compute on the fly
gap_counts(:, 1) = squeeze( sum( sum( (cbdObj.originalFFIs(SCIENCE_ROWS, SCIENCE_COLS, :) >= GAP_TAG), 1), 2) );
% leading black
gap_counts(:, 2) = squeeze( sum( sum( (cbdObj.originalFFIs(1:FFI_ROWS, LEADING_BLACK_COLS, :) >= GAP_TAG), 1), 2) );
% trailing black
gap_counts(:, 3) = squeeze( sum( sum( (cbdObj.originalFFIs(1:FFI_ROWS, TRAILING_BLACK_COLS, :) >= GAP_TAG), 1), 2) );

% masked smear: note partial columns
gap_counts(:, 4) = squeeze( sum( sum( (cbdObj.originalFFIs(MASKED_SMEAR_ROWS, SCIENCE_COLS, :) >= GAP_TAG), 1), 2) );
% virtual smear
gap_counts(:, 5) = squeeze( sum( sum( (cbdObj.originalFFIs(VIRTUAL_SMEAR_ROWS, SCIENCE_COLS, :) >= GAP_TAG), 1), 2) );

pixel_counts(1) = length(SCIENCE_ROWS) * length(SCIENCE_COLS);
pixel_counts(2) = FFI_ROWS * length(LEADING_BLACK_COLS);
pixel_counts(3) = FFI_ROWS * length(TRAILING_BLACK_COLS);
pixel_counts(4) = length(MASKED_SMEAR_ROWS) * length(SCIENCE_COLS);
pixel_counts(5) = length(VIRTUAL_SMEAR_ROWS) * length(SCIENCE_COLS);

dataCompleteness = uint8( 100 * ( 1 - gap_counts ./ repmat(pixel_counts, ffiNumber, 1) ) );

return;

