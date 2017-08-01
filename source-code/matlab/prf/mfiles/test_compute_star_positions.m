function result = test_compute_star_positions(targetStarsStruct)
% function result = test_compute_star_positions(targetStarsStruct)
%
% result: 1 x nTargets structure with fields
%   .maxRowExtent : maximum row extent of target's dither pattern
%   .minRowExtent : minimum row extent of target's dither pattern
%   .referenceRow
%   .maxColExtent : maximum column extent of target's dither pattern
%   .minColExtent : minimum column extent of target's dither pattern
%   .referenceColumn
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

nTargets = length(targetStarsStruct);
for t=1:nTargets

    if targetStarsStruct(t).referenceRow < 20 ...
            || targetStarsStruct(t).referenceRow > 1044 ...
            || targetStarsStruct(t).referenceColumn < 12 ...
            || targetStarsStruct(t).referenceColumn > 1112
        
        result(t).error = -1;
        result(t).maxRowExtent = 0;
        result(t).minRowExtent = 0;
        result(t).referenceRow = 0;
        result(t).maxColExtent = 0;
        result(t).minColExtent = 0;
        result(t).referenceColumn = 0;
        continue;
    end
    
    result(t).error = 0;
    
    result(t).maxRowExtent = max(targetStarsStruct(t).row);
    result(t).minRowExtent = min(targetStarsStruct(t).row);
    result(t).referenceRow = targetStarsStruct(t).referenceRow;
    if result(t).maxRowExtent - result(t).minRowExtent > 1.1
        result(t).error = 1;
    end
    if floor(result(t).minRowExtent) > result(t).referenceRow ...
            || ceil(result(t).maxRowExtent) < result(t).referenceRow
        result(t).error = 2;
    end
    
    result(t).maxColExtent = max(targetStarsStruct(t).column);
    result(t).minColExtent = min(targetStarsStruct(t).column);
    result(t).referenceColumn = targetStarsStruct(t).referenceColumn;
    if result(t).maxColExtent - result(t).minColExtent > 1.1
        result(t).error = 3;
    end
    if floor(result(t).minColExtent) > result(t).referenceColumn ...
            || ceil(result(t).maxColExtent) < result(t).referenceColumn
        result(t).error = 4;
    end
end