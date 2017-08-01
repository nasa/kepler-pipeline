function targetArray = assemble_collateral_targets(pixelArray, neighborhood)
%**************************************************************************  
% function targetArray = assemble_collateral_targets(pixelArray)
%**************************************************************************  
% Convert an array of collateral pixels to an array of target structures. A
% target is created around each pixel by including any neighbors in the
% specified neighborhood.However, neighbors included in the target are
% designated as "inactive" and are not cleaned. Only the "active" central
% pixel is cleaned for a given target.
%
% INPUTS:
%     pixelArray   : An array of pixelDataStruct elements.
%     neighborhood : An N-by-2 array of row, column offsets defining N
%                    neighboring pixel locations. 
%
% OUTPUTS:
%     targetArray         : An array of collateral targets, one for each
%     |                     element of pixelArray. Each target consists of 
%     |                     an "active" pixel and its nieghbors.
%     |-.activeIndices    : Specifies the elements of pixelDataStruct to be
%     |                     cleaned when clean_target() is called.
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
    nPixels = numel(pixelArray); % Build a target around each pixel.
    
    targetStruct = struct('activeIndices',   [], ...
                          'pixelDataStruct', []);
    targetArray = repmat(targetStruct, [1, nPixels]);
    
    for i = 1:nPixels
        targetArray(i) = targetStruct;
        rowCol = [pixelArray(i).ccdRow, pixelArray(i).ccdColumn];
        nbrIndices ...
            = cosmicRayCleanerClass.find_neighbors( pixelArray, ...
                                                    rowCol, neighborhood);
        targetArray(i).pixelDataStruct = pixelArray([ i; nbrIndices(:)]);
        targetArray(i).activeIndices = 1;
    end    
end

%********************************** EOF ***********************************