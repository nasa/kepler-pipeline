
function [gridRows, gridColumns] = place_a_meshgrid_on_targets(targetStarStruct, gridSize)
%--------------------------------------------------------------------------
% step 1a: form a 3x3 grid over the targets (their pixels) in the unit of work
% turn this into a separate function
%--------------------------------------------------------------------------
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
nTargets = length(targetStarStruct);

targetPositionMinRow = 1e6;
targetPositionMaxRow = -1;
targetPositionMinColumn = 1e6;
targetPositionMaxColumn = -1;

% get the bounding box row, col for the targets in the given unit of work
% put a square grid of size 'gridSize' over the bounding box and evaluate
% the motion polynomial at each point in the grid

for target = 1:nTargets
    % get the minimum and the maximum of the target pixel rows
    targetPositionMinRow = min( min(cat(1,targetStarStruct(target).pixelTimeSeriesStruct.row)), targetPositionMinRow);
    targetPositionMaxRow = max( max(cat(1,targetStarStruct(target).pixelTimeSeriesStruct.row)), targetPositionMaxRow);

    % get the minimum and the maximum of the target pixel columns
    targetPositionMinColumn = min( min(cat(1,targetStarStruct(target).pixelTimeSeriesStruct.column)), targetPositionMinColumn);
    targetPositionMaxColumn = max( max(cat(1,targetStarStruct(target).pixelTimeSeriesStruct.column)), targetPositionMaxColumn);
end



% make sure there is no possibility of rows or columns falling outside the
% imaging range (0 is not acceptable; what else?)
gridRows = round(linspace(targetPositionMinRow, targetPositionMaxRow, gridSize)); % linspace will result in fractional rows, so round the result
gridColumns = round(linspace(targetPositionMinColumn, targetPositionMaxColumn, gridSize));% linspace will result in fractional columns, so round the result

return