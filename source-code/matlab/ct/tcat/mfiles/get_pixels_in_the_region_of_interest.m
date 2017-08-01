function [rows, columns, pixelsIndex] = get_pixels_in_the_region_of_interest(tcatInputDataStruct, pixelsIndex, rows, columns, xtalkPixelId, xtalkTypeString)
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

if(isempty(pixelsIndex))
    error('TCAT:emptyPixelArray', ...
        'extract_crosstalk_pixel_coordinates: input cross talk pixels linear index array is empty; quitting...');
end


nCcdRows = tcatInputDataStruct.fcConstantsStruct.CCD_ROWS;
nCcdColumns = tcatInputDataStruct.fcConstantsStruct.CCD_COLUMNS;

%----------------------------------------------------------------------
% remove charge injection pixels that fall on top of this parallel cross
% talk pixel
%----------------------------------------------------------------------

% find intersection of parallel cross talk pixels with charge injection
% pixels
[chargeInjectionPixelsInXtalk, indexInXtalkPixel] = intersect(pixelsIndex, tcatInputDataStruct.chargeInjectionPixelsLinearIndex);

% remove the charge injection pixels that fall on parallel cross talk
% pixels

indexToRemove = indexInXtalkPixel;

rows(indexToRemove) = [];
columns(indexToRemove) = [];
pixelsIndex(indexToRemove) = [];


%----------------------------------------------------------------------
% include (or exclude) those pixels in the rectangular region chosen by
% the user if a region of interest is in effect
%----------------------------------------------------------------------
%     s =
%     fcConstantsStruct: [1x1 struct]
%      wantToSpecifyRoi: 'y'
%             typeOfRoi: 'i'
%           roiStartRow: 1020
%             roiEndRow: 1070
%        roiStartColumn: 1132
%          roiEndColumn: 1132
%
if(strcmp(tcatInputDataStruct.wantToSpecifyRoi, 'y'))
    % region of interest specified...

    if(strcmp(tcatInputDataStruct.typeOfRoi, 'i'))
        % region of interest is an inclusion region

        nKeepRows = length(tcatInputDataStruct.roiStartRow:tcatInputDataStruct.roiEndRow);
        nKeepColumns = length(tcatInputDataStruct.roiStartColumn:tcatInputDataStruct.roiEndColumn);

        keepRows = repmat((tcatInputDataStruct.roiStartRow:tcatInputDataStruct.roiEndRow)', 1, nKeepColumns);
        
        keepRows = keepRows';
        keepRows = keepRows(:);
        
        keepColumns = repmat((tcatInputDataStruct.roiStartColumn:tcatInputDataStruct.roiEndColumn)', nKeepRows, 1);

        keepLinearIndex = sub2ind([nCcdRows, nCcdColumns], keepRows, keepColumns);

        % find the intersection of Xtalk pixel index with the inclusion
        % region
        [roiPixelIndex, indexToKeep] = intersect(pixelsIndex, keepLinearIndex);


        if(~isempty(indexToKeep))
            rows = rows(indexToKeep);
            columns = columns(indexToKeep);
            pixelsIndex = pixelsIndex(indexToKeep);
        else
            startRow = tcatInputDataStruct.roiStartRow;
            endRow = tcatInputDataStruct.roiEndRow;
            startColumn = tcatInputDataStruct.roiStartColumn;
            endColumn = tcatInputDataStruct.roiEndColumn;
            
            warning('TCAT:invalidInclusionRegion', ...
                ['extract_crosstalk_pixel_coordinates: No ' xtalkTypeString ' cross talk pixel of type ' num2str(xtalkPixelId) ' found in the inclusion region bound by rows ['...
                num2str([startRow endRow]) '], columns  [', num2str([startColumn endColumn]) ']']);
        end

    end

    if(strcmp(tcatInputDataStruct.typeOfRoi, 'e'))
        % region of interest is an exclusion region

        nExcludeRows = length(tcatInputDataStruct.roiStartRow:tcatInputDataStruct.roiEndRow);
        nExcludeColumns = length(tcatInputDataStruct.roiStartColumn:tcatInputDataStruct.roiEndColumn);

        excludeRows = repmat((tcatInputDataStruct.roiStartRow:tcatInputDataStruct.roiEndRow)', 1, nExcludeColumns);
        excludeRows = excludeRows';
        excludeRows = excludeRows(:);
        
        excludeColumns = repmat((tcatInputDataStruct.roiStartColumn:tcatInputDataStruct.roiEndColumn)', nExcludeRows, 1);


        excludeLinearIndex = sub2ind([nCcdRows, nCcdColumns], excludeRows, excludeColumns);

        % find the intersection of Xtalk pixel index with the inclusion
        % region
        [roiPixelIndex, indexToExclude] = intersect(pixelsIndex, excludeLinearIndex);

        if(~isempty(indexToExclude))
            rows(indexToExclude) = [];
            columns(indexToExclude) = [];
            pixelsIndex(indexToExclude) = [];
        else
            startRow = tcatInputDataStruct.roiStartRow;
            endRow = tcatInputDataStruct.roiEndRow;
            startColumn = tcatInputDataStruct.roiStartColumn;
            endColumn = tcatInputDataStruct.roiEndColumn;

            warning('TCAT:invalidExclusionRegion', ...
                ['extract_crosstalk_pixel_coordinates: No ' xtalkTypeString ' cross talk pixel of type ' num2str(xtalkPixelId) ' found in the exclusion region bound by rows ['...
                num2str([startRow endRow]) '], columns  [', num2str([startColumn endColumn]) ']']);
            
        end
    end
end


