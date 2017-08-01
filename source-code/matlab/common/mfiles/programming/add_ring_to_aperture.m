function [isInNewAperture] = ...
    add_ring_to_aperture(rows, columns, isInOptimalAperture, nRings)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isInNewAperture] = ...
% add_ring_to_aperture(rows, columns, isInOptimalAperture, nRings)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add ring around pixels for which isInOptimalAperture == true. Return
% boolean vector isInNewAperture to indicate whether or not pixels fall in
% the new larger aperture.
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


if(~exist('nRings', 'var'))
    nRings = 1;
end


% meshplot for a visual check
minRow = min(rows);
maxRow = max(rows);

minCol = min(columns);
maxCol = max(columns);

nUniqueCols = maxCol - minCol +1;
nUniqueRows = maxRow - minRow +1;


aperture = zeros(nUniqueRows, nUniqueCols); % this aperture is rectangular, might not be the same as the mask assigned to the star

% find the index of original aperture in this rectangular aperture
originalIndex = sub2ind([nUniqueRows, nUniqueCols], rows-minRow+1,columns-minCol+1);


idx = sub2ind([nUniqueRows, nUniqueCols], rows(isInOptimalAperture)-minRow+1, columns(isInOptimalAperture)-minCol+1);

aperture(idx) = 1;


% create convolution kernel
haloKernel = [1,1,1;1,1,1;1,1,1];       % option 2 is a 3x3 square (more conservative)

nHaloAperture =  aperture;

% incrementally add a 1 pixel buffer around the input aperture
for k = 1:nRings
    nHaloAperture = conv2(nHaloAperture, haloKernel,'same') ;
end

% save as logical array
isInHaloAperture = nHaloAperture > 0;

isInNewAperture = isInHaloAperture(originalIndex);

return








% % Loop through pixels outside of original aperture and add those that are
% % at least diagonally adjacent to a pixel in the original aperture.
% isInNewAperture = isInOptimalAperture;
%
% for i = find(~isInOptimalAperture(:)')
%     if min((rows(i) - rows(isInOptimalAperture)) .^ 2 + ...
%             (columns(i) - columns(isInOptimalAperture)) .^ 2) <= 2
%         isInNewAperture(i) = true;
%     end
% end
%
% % Return.
% return
%
%
