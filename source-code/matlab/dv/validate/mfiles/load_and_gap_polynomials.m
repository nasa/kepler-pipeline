function [polyStruct, cadenceRange, gapIndicatorsForTargetTable] = ...
load_and_gap_polynomials(tableStruct, blobSeries, ...
baseCadence, gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [polyStruct, cadenceRange] = ...
% load_and_gap_polynomials(tableStruct, blobSeries, ...
% baseCadence, gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function loads and gaps background or motion polynomials from blob
% series files for a given target table. It returns the polynomial
% structure array, the applicable cadence range within the UOW, and the gap
% indicators for the given target table.
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

% Set the cadence range and gap indicators for the given target table.
targetTableStartCadence = tableStruct.startCadence;
targetTableEndCadence = tableStruct.endCadence;
argabrighteningIndices = tableStruct.argabrighteningIndices;

cadenceRange = (targetTableStartCadence : targetTableEndCadence) - ...
    baseCadence + 1;
gapIndicatorsForTargetTable = gapIndicators(cadenceRange);
gapIndicatorsForTargetTable(argabrighteningIndices) = true;

% Convert the background or motion polynomials for the given target table.
% Return if the polynomial structure array is empty.
[polyStruct] = poly_blob_series_to_struct(tableStruct.(blobSeries));
if isempty(polyStruct)
    return
end % if

% Determine the polynomial type.
if isfield(polyStruct, 'backgroundPoly')
    isBackground = true;
elseif isfield(polyStruct, 'rowPoly') && isfield(polyStruct, 'colPoly')
    isBackground = false;
else
    error('dv:loadAndGapPolynomials:unsupportedPolyType', ...
        'Polynomial type is unsupported')
end % if / elseif / else

% Gap the polynomials.
nCadences = length(polyStruct);

if isBackground
    status = logical([polyStruct.backgroundPolyStatus]);
    statusCellArray = ...
        num2cell(double(status & ~gapIndicatorsForTargetTable( : )'));
    [polyStruct(1 : nCadences).backgroundPolyStatus] = ...
        statusCellArray{ : };
else
    status = logical([polyStruct.rowPolyStatus]);
    statusCellArray = num2cell(double(status & ~gapIndicatorsForTargetTable( : )'));
    [polyStruct(1 : nCadences).rowPolyStatus] = statusCellArray{ : };
    [polyStruct(1 : nCadences).colPolyStatus] = statusCellArray{ : };
        
end % if / else
    
% Return.
return
