function [gridRows gridCols] = get_pixel_grid(fcConstants, numGridSteps)
% [gridRows gridCols] = get_pixel_grid(fcConstants, numGridSteps)
%
% Returns a grid of row/column pixel coordinates covering the visable module/output.
% 
% INPUTS:
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

%    numGridSteps       (optional) The number of row and column locations to return.
%                       The default is 6, which returns 36-element (6x6)
%                       outputs.
%
% OUTPUTS:
%    gridRows           A vector of the row coordinates (1-based).
%    gridCols           A vector of the col coordinates (1-based).


    switch nargin
        case 1
            numGridSteps = 6;
        case 2
            % do nothing
        otherwise
            error('pmd:get_pixel_grid', 'Usage: get_pixel_grid(fcConstants) or get_pixel_grid(fcConstants, numGridSteps)');
    end

    startRow = fcConstants.nMaskedSmear + 1 + 1; % Convert from zero- to one-based AND move one pixel inward on the chip
    endRow = startRow + fcConstants.nRowsImaging - 1 - 1; % Extra -1 is to move one pixel into the chip
    stepRow = (endRow - startRow) / numGridSteps;

    startCol = fcConstants.nLeadingBlack + 1 + 1; % Convert from zero- to one-based AND move one pixel inward on the chip
    endCol = startCol + fcConstants.nColsImaging  - 1 - 1; % Extra -1 is to move one pixel into the chip
    stepCol = (endCol - startCol) / numGridSteps;
    
    [gridRows gridCols] = meshgrid(startRow:stepRow:endRow, startCol:stepCol:endCol);
    gridRows = gridRows(:)';
    gridCols = gridCols(:)';
return
