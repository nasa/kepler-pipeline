function coaObject = create_output_image(coaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function coaObject = create_output_image(coaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Computes the synthetic image on a module output.  Operates on a group
% of stars at a time to avoid memory problems.
% Each star is placed on the image as follows:
%   1) determine the unaberrated pixel position of each star
%   2) evaluate the aberrated pixel position of each star for each time
%   3) determine which sub-pixel bin the time-averaged star centroid lands on
%   4) construct a time-averaged basis for the pixel response function
%   (PRF) from the aberrated star position
%   5) for each star load the Prf for the bin containing that star,
%   evaluate the Prf on the appropriate time-averaged basis, add the
%   resulting image to the output image and store the image if it is a
%   target star. 
% 
% Fills in the following the following fields of coaObject:
%   .outputImage resulting ccd output image
%   .minRow, .maxRow, .minCol, .maxCol bounding box of aberrated targets on
%       this CCD module output
%   .targetImages() array of structures for target stars on this output containing:
%       .image image of this target star
%       .imageRange vector containing offsets of this image into the otuput
%       image
%       .pixRange vector of offsets into this image for placement into the output
%       image
%       .aberratedRow, .aberratedColumn aberrated row and column of this target star
%       .unAberratedRow, .unAberratedColumn un-aberrated row and column of this target star
%       .RA, .dec, .magnitude, .flux astrophysical data for this target star
%       .KICID KIC ID of this target star
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
    
rand('seed', 0);
randn('seed', 0);

% get various parameters for convenience
startTime = datestr2mjd(coaObject.startTime);
duration = coaObject.duration;
flux12 = coaObject.pixelModelStruct.flux12;
module = coaObject.module;
output = coaObject.output;
nRowPix = coaObject.moduleDescriptionStruct.nRowPix;
nColPix = coaObject.moduleDescriptionStruct.nColPix;
cadenceTime = coaObject.pixelModelStruct.cadenceTime;
nOutputBufferPix = coaObject.coaConfigurationStruct.nOutputBufferPix;
nStarImageRows = coaObject.coaConfigurationStruct.nStarImageRows; % must be odd
nStarImageCols = coaObject.coaConfigurationStruct.nStarImageCols; % must be odd
starChunkLength = coaObject.coaConfigurationStruct.starChunkLength;
raOffset = coaObject.coaConfigurationStruct.raOffset;
decOffset = coaObject.coaConfigurationStruct.decOffset;
phiOffset = coaObject.coaConfigurationStruct.phiOffset;
motionPolynomialsEnabled = ...
    coaObject.coaConfigurationStruct.motionPolynomialsEnabled;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;
leadingBlack = coaObject.moduleDescriptionStruct.leadingBlack;
flatFieldImage = coaObject.flatFieldImage;
flatFieldImage = flatFieldImage(maskedSmear+1:maskedSmear+nRowPix, leadingBlack+1:leadingBlack+nColPix);

% create the prf object, creating the required input structure
if isfield(coaObject.prfStruct, 'c'); % it's a single prf model
    prfModel.polyStruct = coaObject.prfStruct;
else
	prfModel = coaObject.prfStruct;
end
prfObject = prfCollectionClass(prfModel, coaObject.fcConstants);
% prfObject = prfClass(prfModel.polyStruct);
prfNumRows = get(prfObject, 'nPrfArrayRows');
prfNumCols = get(prfObject, 'nPrfArrayRows');
prfMaxOrder = get(prfObject, 'maxOrder');
prfType = get(prfObject, 'polyType');

% draw(prfObject, 500, 500);

debugFlag = coaObject.debugFlag;

nStars = length(coaObject.kicEntryDataStruct);

% initialize the output image
outputImage = zeros(nRowPix, nColPix);

% find the valid motion polynomials in the desired time range; also find
% the closest valid polynomial to the center of the desired time range
motionPolyStruct = coaObject.motionPolyStruct;
if motionPolynomialsEnabled
    if isempty(motionPolyStruct)
        error('TAD:COA:create_output_image:motionPolyStruct', ...
            'motion polynomial structure array is empty');
    end
    motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
    motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    if isempty(motionPolyStruct)
        error('TAD:COA:create_output_image:motionPolyStruct', ...
            'all motion polynomials are invalid');
    end
    motionPolyTimestamps = [motionPolyStruct.mjdMidTime]';
    isInTimeRange = motionPolyTimestamps >= startTime & ...
        motionPolyTimestamps <= startTime + duration;
    if ~any(isInTimeRange)
        error('TAD:COA:create_output_image:motionPolyStruct', ...
            'no valid motion polynomials in desired time range');
    end
    [delta, centralMotionPolyIndex] = min(abs( ...
        motionPolyTimestamps(isInTimeRange) - (startTime + duration / 2)));
else
    isInTimeRange = [];
end

% break input star set into chunks of size starChunkLength 
% to avoid memory problems
starEnd = 0;
while starEnd < nStars
    % set the range of stars to work on
    starStart = starEnd + 1;
    starEnd = starStart + starChunkLength;
    if starEnd > nStars
        starEnd = nStars;
    end
    if debugFlag
        starStart
    end
    
    % get the unabberated right ascension and declination of the stars
    RA = [coaObject.kicEntryDataStruct(starStart:starEnd).RA]';
    dec = [coaObject.kicEntryDataStruct(starStart:starEnd).dec]';
    magnitude = [coaObject.kicEntryDataStruct(starStart:starEnd).magnitude]';
    KICID = [coaObject.kicEntryDataStruct(starStart:starEnd).KICID]';

    % Compute the pixel row and column on which the point-image of the stars
    % falls without aberration.  Note that the input RA is in hours.
    if ~motionPolynomialsEnabled
        [tmpModule,tmpOutput, row, column] = ra_dec_2_pix_relative( ...
            coaObject.raDec2PixObject, ...
            15*RA, dec, startTime + duration/2, ...
            raOffset, decOffset, phiOffset, 1);
    else
        [row] = weighted_polyval2d(15*RA, dec, ...
            motionPolyStruct(centralMotionPolyIndex).rowPoly);
        [column] = weighted_polyval2d(15*RA, dec, ...
            motionPolyStruct(centralMotionPolyIndex).colPoly);
        tmpModule = repmat(motionPolyStruct(centralMotionPolyIndex).module, size(row));
        tmpOutput = repmat(motionPolyStruct(centralMotionPolyIndex).output, size(row));
    end
    row = row - maskedSmear;
    column = column - leadingBlack;
    % convert coordinates so 0 is at center of pixel

    % compute the expected flux of each star in electrons per long cadence
    % should be a library call somewhere
    flux = cadenceTime * flux12 * mag2b(magnitude)/mag2b(12);

    % create the results struct, which contains all objects whether or not they
    % fall on the module output
    starPixDataStruct = struct('KICID', num2cell(KICID), ...
        'RA', num2cell(RA), 'dec', num2cell(dec),...
        'row', num2cell(row), 'column', num2cell(column),...
        'magnitude', num2cell(magnitude), 'flux', num2cell(flux));

    % trim the result to the module output
    starPixDataStruct = ...
        starPixDataStruct(([starPixDataStruct.row] >= -nOutputBufferPix) & ...
        ([starPixDataStruct.row] <= nRowPix + nOutputBufferPix) & ...
        ([starPixDataStruct.column] >= -nOutputBufferPix) & ...
        ([starPixDataStruct.column] <= nColPix + nOutputBufferPix) & ...
		(tmpModule' == module) & (tmpOutput' == output));
		
	if ~isempty(starPixDataStruct)
    	% determine the number of stars in this chunk
    	nStarsInChunk = length(starPixDataStruct);

    	if nStarsInChunk > 0
        	% compute the time-averaged basis and aberrated star row and columns
        	[aberratedRows aberratedCols avgStarRow avgStarCol] = ...
            	find_aberrated_data(coaObject, starPixDataStruct, ...
                motionPolyStruct(isInTimeRange));
        	% here we have the aberrated star positions for each day of the
        	% interval.  Now save the average value as the aberrated row,
        	% column position of the star
            if startTime > coaObject.k2StartMjd
                % for K2 operations force saturated targets to be in the
                % middle of thir pixels in the column direction
                for s = 1:nStarsInChunk
                    if starPixDataStruct(s).magnitude < 11
                        avgStarCol(s) = fix(avgStarCol(s));
                        aberratedCols(:,s) = repmat(avgStarCol(s), size(aberratedRows, 1), 1);
                    end
                end
            end
            for s = 1:nStarsInChunk
                starPixDataStruct(s).aberratedRow = avgStarRow(s);
                starPixDataStruct(s).aberratedCol = avgStarCol(s);
            end
            
            % now we are finally ready to create the image for each star
        	% compute the offsets required to imbed the Prf image into the star
        	% image
        	sIOffsetRows = fix((nStarImageRows - prfNumRows)/2);
        	sIOffsetCols = fix((nStarImageCols - prfNumCols)/2);
        	for s = 1:nStarsInChunk
				% we have to check the aberrated ranges to be robust against bad input data
				if (avgStarRow(s) >= nOutputBufferPix) && ...
					(avgStarRow(s) <= nRowPix + nOutputBufferPix) && ...
					(avgStarCol(s) >= nOutputBufferPix) && ...
					(avgStarCol(s) <= nColPix + nOutputBufferPix)

                    % put the aberrated star data into coordinates so that the
            		% average centroid location is on the central pixel 
            		prfCoordStarRow = aberratedRows(:,s) - fix(avgStarRow(s));
                    if mean(prfCoordStarRow) >= 0.5
                        prfCoordStarRow = prfCoordStarRow - 1;
                    end
            		prfCoordStarCol = aberratedCols(:,s) - fix(avgStarCol(s));
                    
                    if mean(prfCoordStarCol) >= 0.5
                        prfCoordStarCol = prfCoordStarCol - 1;
                    end
            		% now compute the actual time-averaged basis for this
            		% star
                    % compute the basis for each time as the rows of a design
                    % matrix
                    dvaDesignMatrix = weighted_design_matrix2d(prfCoordStarRow, ...
                        prfCoordStarCol, 1, prfMaxOrder, prfType); 
                    
                    % average over time, and multiply by the sampleInterval
                    averageBasis = ...
                        coaObject.dvaCoeffStruct.sampleInterval*mean(dvaDesignMatrix, 1)';               
                    
                    % get the actual time-averaged PRF
                    % PRF evaluate operates in CCD coordinates
                    prfPixels = evaluate(prfObject, avgStarRow(s) + maskedSmear, ...
                       avgStarCol(s) + leadingBlack, [], [], averageBasis');
                    
                    % check for negative pixels and alert us.  Then truncate to
                    % zero as they are expected for our less-than-ideal PRFs
                    if any(prfPixels < 0)
%                         warning(['create_output_image: star ' num2str(s) ' has negative pixel brightness']);
                        prfPixels(prfPixels < 0) = 0;
                    end

                    % normalize the prfPixels and multiply by the flux
                    if sum(prfPixels) > 0
                        pixelBrightness = starPixDataStruct(s).flux*prfPixels/sum(prfPixels);
                    else
                        pixelBrightness = zeros(size(prfPixels));
                    end
            		% now imbed the star image into a larger image to allow for saturation
            		% spill effects
            		% initialze the star image
            		starImage = zeros(nStarImageRows, nStarImageCols);
            		% imbed the Prf image into the center
            		starImage(sIOffsetRows + 1:nStarImageRows - sIOffsetRows,...
                		sIOffsetCols + 1:nStarImageCols - sIOffsetCols)...
                		= reshape(pixelBrightness, prfNumRows, prfNumCols);
            		if any(any(~isfinite(starImage)))
                		error('TAD:COA:create_output_image:starImage', 'starImage not finite');
            		end

            		% compute the pixel offsets required to place this star's image in
            		% the CCD module output image.  Problems occur near edges of the
            		% CCD so resolve in a function
            		[imageRange pixRange] = compute_pix_offsets( ...
                        avgStarRow(s), avgStarCol(s), ...
                        nRowPix, nColPix, nStarImageRows, nStarImageCols);     
            		%
            		% multiply starImage by vignetting and flat field here
            		%
					starImage(pixRange(1):pixRange(2), pixRange(3):pixRange(4)) ...
						= starImage(pixRange(1):pixRange(2), pixRange(3):pixRange(4)) ...
						.* flatFieldImage(imageRange(1):imageRange(2), imageRange(3):imageRange(4));

            		% finally imbed the star image into the output image
            		outputImage(imageRange(1):imageRange(2), imageRange(3):imageRange(4)) = ...
                		outputImage(imageRange(1):imageRange(2), imageRange(3):imageRange(4)) ...
                		+ starImage(pixRange(1):pixRange(2), pixRange(3):pixRange(4));

            		% add the star image to the target image list
            		coaObject = add_target_image(coaObject, starPixDataStruct(s), ...
                		imageRange, pixRange, starImage);
            		clear pixelBrightness starImage averageBasisStruct;
        		end
			end
    	end
	end
    clear starPixDataStruct;
end % end working star chunk loop
if any(any(~isfinite(outputImage)))
    error('TAD:COA:create_output_image:outputImage', 'outputImage not finite');
end

% initialize bounding box of targets
minRow = inf;
maxRow = 0;
minCol = inf;
maxCol = 0;

% now compute the bounding box of the aberrated targets on this CCD
% module output
if length(coaObject.targetImages) > 0
    minRow = fix(min([minRow, min([coaObject.targetImages.aberratedRow])]))+1;
    if minRow < 2
        minRow = 2;
    end
    maxRow = fix(max([maxRow, max([coaObject.targetImages.aberratedRow])]))+1;
    if maxRow > nRowPix - 1
        maxRow = nRowPix;
    end
    minCol = fix(min([minCol, min([coaObject.targetImages.aberratedColumn])]))+1;
    if minCol < 2
        minCol = 2;
    end
    maxCol = fix(max([maxCol, max([coaObject.targetImages.aberratedColumn])]))+1;
    if maxCol > nColPix - 1
        maxCol = nColPix;
    end
else
    minRow = 2;
    maxRow = nRowPix - 1;
    minCol = 2;
    maxCol = nColPix - 1;
end

% fill in the remaining outputs
coaObject.outputImage = outputImage;
coaObject.minRow = minRow;
coaObject.maxRow = maxRow;
coaObject.minCol = minCol;
coaObject.maxCol = maxCol;

% targetImages = coaObject.targetImages;
% save(['targetImages_m' num2str(module) 'o' num2str(output) '.mat'], 'targetImages');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [aberratedRow aberratedCol avgStarRow avgStarCol] = 
%   find_aberrated_data(coaObject, starPixDataStruct, motionPolyStruct)
%
% compute the time averaged basis and aberrated star positions
% returns:
%   aberratedRow, aberratedCol arrays indexed by (time, star) containing
%       the aberrated row, column of the star centroid over time
%   avgStarRow avgStarCol average over time of aberratedRow, aberratedCol
%       indexed by star
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [aberratedRows aberratedCols avgStarRow avgStarCol] = ...
    find_aberrated_data(coaObject, starPixDataStruct, motionPolyStruct)

motionPolynomialsEnabled = ...
    coaObject.coaConfigurationStruct.motionPolynomialsEnabled;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;
leadingBlack = coaObject.moduleDescriptionStruct.leadingBlack;

nStars = length(starPixDataStruct);

if ~motionPolynomialsEnabled
    
    OffsetBasisCoeffs = coaObject.dvaCoeffStruct;
    nRowPix = coaObject.moduleDescriptionStruct.nRowPix;
    nColPix = coaObject.moduleDescriptionStruct.nColPix;

    % first we compute the aberrated row and column for each star for each time
    nTimes = length(OffsetBasisCoeffs.abRowPoly);
    aberratedRows = zeros(nTimes, nStars);
    aberratedCols = zeros(nTimes, nStars);
    for t = 1:nTimes
        aberratedRows(t, :) = weighted_polyval2d([starPixDataStruct.row]'/nRowPix,...
            [starPixDataStruct.column]'/nColPix, OffsetBasisCoeffs.abRowPoly(t));
        aberratedCols(t, :) = weighted_polyval2d([starPixDataStruct.row]'/nRowPix,...
            [starPixDataStruct.column]'/nColPix, OffsetBasisCoeffs.abColPoly(t));
    end
    
else
    
    % evaluate the motion polynomials for each star at all valid cadences
    % in the desired time range
    nTimes = length(motionPolyStruct);
    aberratedRows = zeros(nTimes, nStars);
    aberratedCols = zeros(nTimes, nStars);
    for t = 1:nTimes
        aberratedRows(t, :) = weighted_polyval2d(15*[starPixDataStruct.RA]',...
            [starPixDataStruct.dec]', motionPolyStruct(t).rowPoly) - maskedSmear;
        aberratedCols(t, :) = weighted_polyval2d(15*[starPixDataStruct.RA]',...
            [starPixDataStruct.dec]', motionPolyStruct(t).colPoly) - leadingBlack;
    end
    
end
    
avgStarRow = mean(aberratedRows, 1)';    
avgStarCol = mean(aberratedCols, 1)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [imageRange pixRange] = compute_pix_offsets(starPixDataStruct, nRowPix, 
%   nColPix, starImageNRows, starImageNCols)
%
% determine the pixel offsets for imbedding the star image into 
% the output image
%
% output: 
%   imageRange is a vector of offsets into the star image
%   pixRange is a vector of offsets of the star image into the CCD module
%   output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imageRange pixRange] = compute_pix_offsets(starRow, starCol, nRowPix, nColPix, ...
    starImageNRows, starImageNCols)
% now imbed the star image into the output image.  We must compute the
% appropriate offsets, being careful at the edges.
row = fix(starRow + 0.5);    
col = fix(starCol + 0.5);
pixStartRow = 1;
pixEndRow = starImageNRows;
pixStartCol = 1;
pixEndCol = starImageNCols;
starImageHalfWidth = fix((starImageNRows-1)/2);
starImageHalfHeight = fix((starImageNCols-1)/2);
startRow = row-starImageHalfWidth;
if startRow < 1 
    pixStartRow = 2 - startRow; % = 1 - (startRow - 1)
    startRow = 1; 
end
endRow = row+starImageHalfWidth;
if endRow > nRowPix 
    pixEndRow = starImageNRows - (endRow - nRowPix);
    endRow = nRowPix; 
end
startCol = col-starImageHalfHeight;
if startCol < 1 
    pixStartCol = 2 - startCol;
    startCol = 1; 
end
endCol = col+starImageHalfHeight;
if endCol > nColPix 
    pixEndCol = starImageNCols - (endCol - nColPix);
    endCol = nColPix; 
end

imageRange = [startRow, endRow, startCol, endCol];
pixRange = [pixStartRow, pixEndRow, pixStartCol, pixEndCol];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function coaObject = add_target_image(coaObject, starPixDataStruct, 
%   imageRange, pixRange, starImage)
%
% add star image to the target image list if appropriate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coaObject = add_target_image(coaObject, starPixDataStruct, ...
    imageRange, pixRange, starImage)
% add the image to list of target stars if this star is a target
if ismember(starPixDataStruct.KICID, coaObject.targetKeplerIDList)
    coaObject.numTargetImages = coaObject.numTargetImages + 1;
    nt = coaObject.numTargetImages; % for convenience
    % save the offset vectors from the star image into the output image
    coaObject.targetImages(nt).imageRange = imageRange;
    coaObject.targetImages(nt).pixRange = pixRange;
    % save the actual target star image
    coaObject.targetImages(nt).image = starImage;
    % include some useful stuff
    coaObject.targetImages(nt).aberratedRow = starPixDataStruct.aberratedRow;
    coaObject.targetImages(nt).aberratedColumn = starPixDataStruct.aberratedCol;
    coaObject.targetImages(nt).unAberratedRow = starPixDataStruct.row;
    coaObject.targetImages(nt).unAberratedColumn = starPixDataStruct.column;
    coaObject.targetImages(nt).RA = starPixDataStruct.RA;
    coaObject.targetImages(nt).dec = starPixDataStruct.dec;
    coaObject.targetImages(nt).magnitude = starPixDataStruct.magnitude;
    coaObject.targetImages(nt).flux = starPixDataStruct.flux;
    coaObject.targetImages(nt).KICID = starPixDataStruct.KICID;
end

