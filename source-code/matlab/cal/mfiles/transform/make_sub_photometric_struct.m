function photoStruct = make_sub_photometric_struct(photoStruct, indices)
%
% function photoStruct = make_sub_photometric_struct(photoStruct, indices)
%
% This function accepts input of an errorPropStruct for photometric pixels 
% and returns the same struct modified to include only the primitive
% indices for both primitive data and subsequent transformations. If 
% indices is empty an empty_errorPropStruct is returned.
%
% INPUT:    photoStruct     = errorPropStruct for 'calibratedPixels' in CAL
%                             for a single cadence
%           indices         = list of primitive data indices to parse out 
%                             of photoStruct
% OUTPUT:   photoStruct     = errorPropStruct for 'calibratedPixels' in CAL
%                             with field contents modified to include only
%                             those indices included in the list
% 
%
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

% THIS FUNCTION IS NOT GENERIC. IT WILL NEED TO BE CHANGED AS CAL
% PHOTOMETRIC PROCESSING CHANGES
%

% --------------------------- HARD CODED CONSTANTS - FOR NOW -------------
CCD_COLUMNS = 1132;
%CCD_ROWS = 1070;
% ------------------------------------------------------------------------

if(~isempty(indices))
    % parse out primitive data
    photoStruct.xPrimitive = photoStruct.xPrimitive(indices);
    photoStruct.CxPrimitive = photoStruct.CxPrimitive(indices);

    % parse out new row and col values
    newRow = photoStruct.row(indices);
    newCol = photoStruct.col(indices);
    photoStruct.row = newRow;
    photoStruct.col = newCol;

    % adjust gapList
    [values, newGapList] = intersect(indices, photoStruct.gapList);
    photoStruct.gapList = newGapList;
    % set indicators
    validPixelIndicators = true(size(newRow));
%     validPixelIndicators(photoStruct.gapList) = false;

    % Make linear column index from unique rows list
    [uniqueRows, iRows, iUniqueRows] = unique(newRow);
    linearColumns = int32(iUniqueRows - 1) .* CCD_COLUMNS + int32(newCol);

    % Make range of linear columns to interpolate over
    totalInterpColumns = CCD_COLUMNS * length(uniqueRows);

    % Find unique Row-Column pairs            
    RC = [newRow(:), newCol(:)];            
    [uniqueRC, iRC] = unique(RC,'rows');

    % Valid linear columns are those which are not gapped and are unique
    validColIndicators = false(size(validPixelIndicators));            
    validColIndicators(iRC) = true;            
    validColIndicators = validColIndicators & validPixelIndicators;

    % POU: define validLinearColumns and its index into linearColumns
    validLinearColumns = linearColumns(validColIndicators);
    validLinearIndex = find(validColIndicators);

    % adjust structure field contents depending on transformation type
    for i=1:length(photoStruct.transformStructArray)

        if(~isempty(photoStruct.transformStructArray(i).transformType))

            % adjust indexing of incoming yData        
            if( strcmp(photoStruct.transformStructArray(i).yDataInputName, 'fittedBlack' ) )
                photoStruct.transformStructArray(i).yIndices = int32(newRow);
            end        
            if( strcmp(photoStruct.transformStructArray(i).yDataInputName, 'smearLevelEstimate' ) )
                photoStruct.transformStructArray(i).yIndices = int32(newCol);
            end        
            if( strcmp(photoStruct.transformStructArray(i).yDataInputName, 'darkColumns' ) )
                photoStruct.transformStructArray(i).yIndices = int32(newCol);
            end

            % adjust indexing of scaling vector
            if( strcmp(photoStruct.transformStructArray(i).transformType, 'scaleV' ) )
                photoStruct.transformStructArray(i).transformParamStruct.scaleORweight = ...
                    photoStruct.transformStructArray(i).transformParamStruct.scaleORweight(indices);
            end

            % adjust indexing of interp* and related transformations
            if( strcmp(photoStruct.transformStructArray(i).transformType, 'interpLinear' ) ||...
                    strcmp(photoStruct.transformStructArray(i).transformType, 'interpNearest' ))            
                photoStruct.transformStructArray(i).transformParamStruct.xIndices = int32(validLinearColumns);
                photoStruct.transformStructArray(i).transformParamStruct.polyXvector = ['(1:',num2str(totalInterpColumns),')'];
            end

            if( strcmp(photoStruct.transformStructArray(i).transformType, 'selectIndex' ) )
                if( i > 1 && strcmp(photoStruct.transformStructArray(i-1).transformType, 'filter' ) ) 

                     % must be original indices after coming out of 'filter'
                     photoStruct.transformStructArray(i).transformParamStruct.xIndices = int32(linearColumns);

                elseif( i < length(photoStruct.transformStructArray) && ...
                        (strcmp(photoStruct.transformStructArray(i+1).transformType, 'interpLinear' ) || ...
                         strcmp(photoStruct.transformStructArray(i+1).transformType, 'interpNearest' ) ) )

                    % must be valid linear indices going into 'interp*' 
                    photoStruct.transformStructArray(i).transformParamStruct.xIndices = int32(validLinearIndex);
                    
                else
                    errString = 'Error building sub photometric struct';
                    msgString = ['PA:',mfilename,'Must perform index select transform after filter or before interp'];
                    error( msgString, errString );
                end
            end  

        end    
    end
else
    photoStruct = empty_errorPropStruct;
end
