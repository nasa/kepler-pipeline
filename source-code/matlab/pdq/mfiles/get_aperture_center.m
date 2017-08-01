function [rowCenters colCenters] = get_aperture_center(pdqTempStruct, cadenceIndex)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [rowCenters colCenters] = get_aperture_center(cadenceNum, currentModOut, cadenceIndices, targetIndices)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% get_aperture_center: returns the coordinates (row, column) of the aperture
% center for all cadences in cadenceNums and enclosing all target pixels
% for star with ID of targetID.
%
% Inputs:
%   Data members of pdqScienceClass
%       cadenceIndices      : array of indices of cadences to
%       targetIndices       : array of indices of target to construct apertures for
%       currentModOut       : current module ouput being processed
%       refPixelRowIndices  : indices of star pixels
%       refPixelColIndices  : column indices of star pixels
%       numPixels           : number of active pixels for each target
%
%
% Outputs:
%   rowCeners      : row value of center of aperture(s)
%   colcenters     : column value of center of aperture(s)
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

% Obtain necessary input data from pdqScienceClass data members

targetGapIndicators = pdqTempStruct.targetGapIndicators;

targetPixelRows     = pdqTempStruct.targetPixelRows;
targetPixelColumns  = pdqTempStruct.targetPixelColumns;
numPixels           = pdqTempStruct.numPixels;
numTargets          = pdqTempStruct.numTargets; % a vector containing the number of pixels in each target star's aperture

% Pre-allocate memory for these arrays
rowCenters = zeros(numTargets, 1);
colCenters = zeros(numTargets, 1);

indexStart = 1;

for j = 1 : numTargets

    indexEnd = indexStart + numPixels(j)- 1;

    targetRows          = targetPixelRows(indexStart : indexEnd);
    targetColumns       = targetPixelColumns(indexStart : indexEnd);
    gapIndicators       = targetGapIndicators(indexStart : indexEnd,cadenceIndex);

    validPixels = find(~gapIndicators);

    if(~isempty(targetRows(validPixels)))

        rowCenters(j) = mean(targetRows(validPixels));
        colCenters(j) = mean(targetColumns(validPixels));
    else

        warning('PDQ:backgroundCorrection:missingtarget',['Entire target missing for cadence ' num2str(cadenceIndex)]);
        rowCenters(j) = -1;
        colCenters(j) = -1;
    end

    indexStart = indexEnd + 1;


end
