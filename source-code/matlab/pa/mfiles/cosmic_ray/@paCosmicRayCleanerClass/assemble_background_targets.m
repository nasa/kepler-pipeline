function targetArray = assemble_background_targets(pixelArray)
%**************************************************************************  
% function targetArray = assemble_background_targets(obj, pixelArray)
%**************************************************************************  
% Convert an array of background pixels to an array of target structures.
% Group pixels into 4-connected regions and assemble a target struct for
% each region. Doing this homegenizes the input target arrays, enabling the
% same code to process both stellar and background targets. 
%
% INPUTS:
%     pixelArray : An array of pixelDataStruct elements.
%
% OUTPUTS:
%     targetArray         : An array of background target data structures. 
%     |-.raHours    = NaN : Always NaN.
%     |-.decDegrees = NaN : Always NaN.
%      -.pixelDataStruct  : The 4-connected subset of pixelArray comprising
%                           this background target.
%
%**************************************************************************  
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
    targetArray = [];
    
    % Save the pixel's original array position. 
    c = num2cell(1:length(pixelArray));
    [pixelArray.index] = c{:};

    % Find 4-connected regions of pixels.
    while ~isempty(pixelArray)
        targetStruct = struct('raHours',         NaN, ...
                              'decDegrees',      NaN, ...
                              'pixelDataStruct', []);
        targetPixels = pixelArray(1);
        pixelArray(1) = [];
        
        if ~isempty(pixelArray)
            
            % Find all neighbors of target pixels and move them from
            % pixelArray to targetPixels. Repeat until no new neighbors are
            % found.
            targetPixelIndex = 1;
            while targetPixelIndex <= length(targetPixels)
                rowCol = [targetPixels(targetPixelIndex).ccdRow, ...
                          targetPixels(targetPixelIndex).ccdColumn];
                newNeighborIndices ...
                    = cosmicRayCleanerClass.find_neighbors(pixelArray, ...
                                                           rowCol, 4);
                if ~isempty(newNeighborIndices)
                    targetPixels = [targetPixels, ...
                                    pixelArray(newNeighborIndices)];
                    pixelArray(newNeighborIndices) = [];
                end
                    
                targetPixelIndex = targetPixelIndex + 1;
            end
        end
        
        targetStruct.pixelDataStruct = targetPixels;
        targetArray = [targetArray; targetStruct];
    end
end

% NOTE:
% The following function needs to be defined here since
% assemble_background_targets() is a static method and can't access the
% member function find_neighbors()

%**************************************************************************  
% function nbrIndices = find_neighbors(pixelArray, index, neighborhood)
%**************************************************************************  
% Return the pixel array indices corresponding to neighbors of a specified
% pixel.
% 
% INPUTS
%     pixelArray   : An array of pixel data structures.
%     pixelRowCol  : The [row, col] whose neighbors we wish to find.
%     neighborhood : Either an N x 2 matrix of (row,col) offsets defining
%                    the neighborhood or one of the integers 4 or 8
%                    indicating a 4- or 8-connected neighborhood. 
%
% OUTPUTS
%     nbrIndices : The indices in pixelArray of pixels that are neighbors
%                  of pixelRowCol.
%**************************************************************************  
function nbrIndices = find_neighbors(pixelArray, pixelRowCol, neighborhood)
    if isequal(neighborhood, 4)
        neighborhood = [-1 0; 0 1; 1 0; 0 -1];
    elseif isequal(neighborhood, 8)
        neighborhood = [-1 0; -1 1; 0 1; 1 1; 1 0; 1 -1; 0 -1; -1 -1];
    end

    rows = [pixelArray.ccdRow];
    cols = [pixelArray.ccdColumn];
    nbrRowCol = [rows(:), cols(:)];
    
    nbrIndices = [];
    for i = 1:size(neighborhood,1)
        for j = 1:size(nbrRowCol,1)
            if isequal(pixelRowCol + neighborhood(i,:), nbrRowCol(j,:))
                nbrIndices = [nbrIndices; j];
            end
        end
    end
end

%********************************** EOF ***********************************