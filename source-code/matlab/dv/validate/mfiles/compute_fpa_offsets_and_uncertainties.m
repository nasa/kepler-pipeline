function [centroidOffsets] = ...
compute_fpa_offsets_and_uncertainties(referenceRow, referenceColumn, ...
referenceCovariance, centroidRow, centroidColumn, centroidCovariance, ...
centroidOffsets)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [centroidOffsets] = ...
% compute_fpa_offsets_and_uncertainties(referenceRow, referenceColumn, ...
% referenceCovariance, centroidRow, centroidColumn, centroidCovariance, ...
% centroidOffsets)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the focal plane offsets between the given centroid and reference
% coordinates and propagate the associated uncertainties.
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

% Compute the row, column and focal plane offsets.
rowOffsetValue = ...
    centroidRow - referenceRow;
columnOffsetValue = ...
    centroidColumn - referenceColumn;
focalPlaneOffsetValue = sqrt(rowOffsetValue^2 + columnOffsetValue^2);

% Construct the covariance matrix for the reference row/column and the
% the centroid row/column.
Crc = zeros([4, 4]);
Crc(1 : 2, 1 : 2) = referenceCovariance;
Crc(3 : 4, 3 : 4) = centroidCovariance;

% Construct the Jacobians for the row, column and focal plane offsets.
Jrow = [-1, 0, 1, 0];
Jcol = [0, -1, 0, 1];
Jfp = [-rowOffsetValue, -columnOffsetValue, rowOffsetValue, columnOffsetValue] ...
    / focalPlaneOffsetValue;

% Propagate the uncertainties.
rowOffsetUncertainty = sqrt(Jrow * Crc * Jrow');
columnOffsetUncertainty = sqrt(Jcol * Crc * Jcol');
focalPlaneOffsetUncertainty = sqrt(Jfp * Crc * Jfp');

% Save the offset results.
centroidOffsets.rowOffset.value = rowOffsetValue;
centroidOffsets.columnOffset.value = columnOffsetValue;
centroidOffsets.focalPlaneOffset.value = focalPlaneOffsetValue;
centroidOffsets.rowOffset.uncertainty = rowOffsetUncertainty;
centroidOffsets.columnOffset.uncertainty = columnOffsetUncertainty;
centroidOffsets.focalPlaneOffset.uncertainty = focalPlaneOffsetUncertainty;

% Return.
return
