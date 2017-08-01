function catalogData = project_stars(ccdObject, catalogData)
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

runParamsObject = ccdObject.runParamsClass;

moduleNumber = get(runParamsObject, 'moduleNumber');
outputNumber = get(runParamsObject, 'outputNumber');
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
virtualSmearStart = get(runParamsObject, 'virtualSmearStart');
trailingBlackStart = get(runParamsObject, 'trailingBlackStart');
nSubPix = get(runParamsObject, 'nSubPixelLocations');
fluxOfMag12Star = get(runParamsObject, 'fluxOfMag12Star');
raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
timeVector = get(runParamsObject, 'timeVector');
centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');

% Find the module, output, row, and column of the stars left in the catalog
[module, output, catalogData.aberratedInitRow, catalogData.aberratedInitColumn] = ...
    ra_dec_to_pix(raDec2PixObject, catalogData.ra, catalogData.dec, timeVector(1)); 

% find the sky objects we're interested in...1 pixel of margin on perimeter.
onVisiblePixelIndices = find(module==moduleNumber & output == outputNumber & ...
    catalogData.aberratedInitRow>=3 + numMaskedSmear & ...
    catalogData.aberratedInitColumn>=3 + numLeadingBlack & ...
    catalogData.aberratedInitRow<=virtualSmearStart-2 & ...
    catalogData.aberratedInitColumn<=trailingBlackStart-2);

% trim the star data to objects actually on visible pixels
catalogData.ra = catalogData.ra(onVisiblePixelIndices);
catalogData.dec = catalogData.dec(onVisiblePixelIndices);
catalogData.kicId = catalogData.kicId(onVisiblePixelIndices);
catalogData.keplerMagnitude = catalogData.keplerMagnitude(onVisiblePixelIndices);
catalogData.logSurfaceGravity = catalogData.logSurfaceGravity(onVisiblePixelIndices);
catalogData.logMetallicity = catalogData.logMetallicity(onVisiblePixelIndices);
catalogData.effectiveTemperature = catalogData.effectiveTemperature(onVisiblePixelIndices);
% catalogData.radius = catalogData.radius(onVisiblePixelIndices);
% catalogData.mass = catalogData.mass(onVisiblePixelIndices);

catalogData.aberratedInitRow = catalogData.aberratedInitRow(onVisiblePixelIndices);
catalogData.aberratedInitColumn = catalogData.aberratedInitColumn(onVisiblePixelIndices);

%%%%%%%%%%%%%%%%%%%%%%
% now we compute the row, column of all stars at the central time

[module, output, catalogData.row, catalogData.column] = ra_dec_to_pix(...
    raDec2PixObject, ...
    catalogData.ra, catalogData.dec, timeVector(centerTimeIndex));   

% convert coordinates so 0 is at center of pixel in the indexing scheme
% below
catalogData.row = catalogData.row + 0.5;
catalogData.column = catalogData.column + 0.5;

% Find the subpixel that each star lies on...
catalogData.rowFraction = ...
    floor(nSubPix * (catalogData.row - floor(catalogData.row))) + 1;
catalogData.columnFraction = ...
    floor(nSubPix * (catalogData.column - floor(catalogData.column))) + 1;

% Which of the nsub x nsub "subpixel grid" are these stars located on?
catalogData.subPixelIndex = sub2ind([nSubPix nSubPix], ...
    catalogData.rowFraction, catalogData.columnFraction);

% fix the row and column to an integer pixel and eliminate edges
catalogData.row = floor(catalogData.row);
catalogData.column = floor(catalogData.column);
catalogData.visiblePixelIndex = sub2ind([numVisibleRows numVisibleCols], ...
    catalogData.row - numMaskedSmear, catalogData.column - numLeadingBlack);

% compute the ra and dec for the position the pixel actually landed on
fixedRow = catalogData.row + (catalogData.rowFraction - 1)/nSubPix;
fixedCol = catalogData.column + (catalogData.columnFraction - 1)/nSubPix;
[catalogData.fixedRa catalogData.fixedDec] = pix_to_ra_dec(raDec2PixObject, ...
    module, output, fixedRow, fixedCol, timeVector(centerTimeIndex));

%%%%%%%%%%%%%%%%%%%%%%
% compute the flux of each star
catalogData.flux = fluxOfMag12Star * mag2b(catalogData.keplerMagnitude - 12);


