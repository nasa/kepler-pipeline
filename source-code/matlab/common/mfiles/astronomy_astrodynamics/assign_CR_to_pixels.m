function [pixelPointer, cadence, crValue] = assign_CR_to_pixels( pixelList, pixelProb, ...
                                          nCadences, cadenceDuration, fcConstants, ...
                                          minIntensity, xSectionScale, rngSeed )
% 
% assign_CR_to_pixels -- generate cosmic rays and assign them to pixels
%
% [pixelPointer, cadence, crValue] = assign_cr_to_pixels( pixelList, pixelProb, nCadences,
%    cadenceDuration, fcConstants ) takes as arguments: the pixelList output from
%    get_pa_pixel_mapping; the pixel probability values from assign_pixel_CR_probability;
%    the number of cadences in the data; the cadence duration in seconds; and the
%    fcConstants data structure.  Cosmic rays are generated and assigned to pixels,
%    yielding as output 3 vectors of equal length:
%
%    pixelPointer:  pointer to pixels in pixelList
%    cadence:       cadence #
%    crValue:       cosmic ray intensity in photoelectrons.
%
% [...] = assign_cr_to_pixels( ..., minIntensity, xSectionScale, rngSeed ) uses a
%    specified random number generator seed for all random number generation purposes, in
%    order to make the cosmic ray generation and assignment repeatable.  See the help for
%    add_cosmic_rays_to_input_structure for descriptions of these optional inputs.
%
% Version date:  2008-December-08.
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

% Modification History:
%
%    2008-December-08, PT:
%        add intensity and x-section scale factor arguments, and support for same.
%
%=========================================================================================

% manage the case of missing optional arguments

  if (nargin < 6) || (isempty(minIntensity))
      minIntensity = 1 ;
  end
  if (nargin < 7) || (isempty(xSectionScale))
      xSectionScale = 1 ;
  end

% if a random number seed is supplied, capture the current state of the RNG and set it now

  rngSeedArgNo = 8 ;
  if (nargin >= rngSeedArgNo && ~isempty(rngSeed))
      randState = get_rand_state ;
      rand('twister',rngSeed) ;
      randnState = get_randn_state ;
      randn('state',rngSeed) ;
  end
  
% compute the total area of pixels and convert to cm^2; note that some pixels are not
% present at all times (ie, virtual pixels), so they contribute fractionally to the
% expected number of cosmic rays

  pixelAreaCm2 = sum(pixelProb) * (fcConstants.PIXEL_SIZE_IN_MICRONS)^2 * 1e-8 ;
  
% compute the total time

  timeSeconds = nCadences * cadenceDuration ;
  
% generate the cosmic rays -- this will give an M x N x nCosmicRays array.  This is where
% the cross-section scale parameter is used

  cosmicRayMatrix = compute_cosmic_rays( xSectionScale * pixelAreaCm2, timeSeconds ) ;
  nCosmicRays = size(cosmicRayMatrix,3) ;
  nRowsCR = size(cosmicRayMatrix,1) ;
  nColsCR = size(cosmicRayMatrix,2) ;
  
% assign the cosmic rays to cadences at random

  cadence = random_integer(nCosmicRays,1,1,nCadences) ;
  
% Assign the central pixel of each CR to a pixel in the pixelList.  Take into account the
% probabilities of assignment, ie, if a pixel has a probability which is < 1, then use a
% random number to decide whether to keep that assignment or not; if not, reassign it.

  centralPixelPointer = zeros(nCosmicRays,1) ;
  crNotYetAssigned = 1:nCosmicRays ;
  nPixels = length(pixelProb) ;
  
  while (~isempty(crNotYetAssigned))
      nNotAssigned = length(crNotYetAssigned) ;
      centralPixelPointer(crNotYetAssigned) = random_integer(nNotAssigned,1, ...
                                                             1, nPixels) ;
      assignProbability = rand(nCosmicRays,1) ;
      crStillNotAssigned = ...
          find( assignProbability(crNotYetAssigned) ...
          > pixelProb(centralPixelPointer(crNotYetAssigned)) ) ;
      crNotYetAssigned = crStillNotAssigned ;
  end
  
% Now we will assign row and column locations, and pixel indices, to every pixel in the
% cosmic ray matrix.  Start with the row and column locations of the central pixels

  centralPixelRow = pixelList(centralPixelPointer,1) ;
  centralPixelCol = pixelList(centralPixelPointer,2) ;
  
% Convert those to matrices with the same dimension as the cosmic ray matrix, painting the
% central value of a given cosmic ray over its M x N pixels

  centralPixelRow = repmat(  reshape( centralPixelRow,[1,1,nCosmicRays] ), ...
      [nRowsCR,nColsCR,1]  ) ;
  centralPixelCol = repmat(  reshape( centralPixelCol,[1,1,nCosmicRays] ), ...
      [nRowsCR,nColsCR,1]  ) ;
  cadence = repmat(  reshape( cadence,[1,1,nCosmicRays] ), ...
      [nRowsCR,nColsCR,1]  ) ;
  
% construct identically-shaped offset matrices, which give the offset of each individual
% pixel with respect to the central pixel

  rowOffsetVector = -floor(nRowsCR/2):floor(nRowsCR/2) ;
  colOffsetVector = -floor(nColsCR/2):floor(nColsCR/2) ;

  [rowOffset,colOffset] = meshgrid( rowOffsetVector, colOffsetVector ) ;
  
  rowOffset = repmat(  reshape( rowOffset, [nRowsCR,nColsCR,1] ), ...
      [1,1,nCosmicRays]  ) ;
  colOffset = repmat(  reshape( colOffset, [nRowsCR,nColsCR,1] ), ...
      [1,1,nCosmicRays]  ) ;
  
% add the row and column offsets to the central pixel row and column to get the row and
% column of every pixel for every cosmic ray

  pixelRowCR = centralPixelRow + rowOffset ;
  pixelColCR = centralPixelCol + colOffset ;
  
% convert the row, column, and intensity to column vectors

  pixelRowCR = pixelRowCR(:) ;
  pixelColCR = pixelColCR(:) ;
  cosmicRayMatrix = cosmicRayMatrix(:) ;
  cadence = cadence(:) ;
  
% Throw out any pixel for which the intensity is < minIntensity photoelectron

  weakCRIndex = find(cosmicRayMatrix < minIntensity) ;
  pixelRowCR(weakCRIndex) = [] ;
  pixelColCR(weakCRIndex) = [] ;
  cosmicRayMatrix(weakCRIndex) = [] ;
  cadence(weakCRIndex) = [] ;
  
% throw out any pixel which is outside of the range of the pixel indexing

  badPixelLocation = find( pixelRowCR < fcConstants.MASKED_SMEAR_START  | ...
                           pixelRowCR > fcConstants.VIRTUAL_SMEAR_END   | ...
                           pixelColCR < fcConstants.LEADING_BLACK_START | ...
                           pixelColCR > fcConstants.TRAILING_BLACK_END ) ;
  
  pixelRowCR(badPixelLocation) = [] ;
  pixelColCR(badPixelLocation) = [] ;
  cosmicRayMatrix(badPixelLocation) = [] ;
  cadence(badPixelLocation) = [] ;
  
% Throw out any pixel which is present in the generated CRs but not in the list of pixels
% in the dataset (this is necessary because a cosmic ray event extends over > 1 pixel, so
% some pixels which are outside of the CR's core are not in the dataset, even if the core
% pixels are in the dataset).  To do this, we must convert each pixel's row and column to
% its unique index on the mod/out via sub2ind

  crPixelIndex = sub2ind( [fcConstants.VIRTUAL_SMEAR_END + 1, ...
                           fcConstants.TRAILING_BLACK_END + 1], ...
                           pixelRowCR+1, pixelColCR+1 ) ;
  badPixelPointer = find( ~ismember(crPixelIndex,pixelList(:,3)) ) ;
  pixelRowCR(badPixelPointer) = [] ;
  pixelColCR(badPixelPointer) = [] ;
  cosmicRayMatrix(badPixelPointer) = [] ;
  cadence(badPixelPointer) = [] ;
  
% At this point, it's possible that a given pixel is hit more than once on a single
% cadence.  We need to find all the hits for each pixel on each cadence and combine them.
% To do this, we need to convert the 3-dimensional space (cadence, row, column) into a
% single index, and reduce to uniques.

  cadenceRowCol = sub2ind( [nCadences, fcConstants.VIRTUAL_SMEAR_END + 1, ...
                            fcConstants.TRAILING_BLACK_END + 1], ...
                            cadence, pixelRowCR+1, pixelColCR+1 ) ;
  [cadenceRowColUnique, mapVector1, mapVector2] = unique(cadenceRowCol) ;
  
% since I can't think of any better way to do this, I'll use a loop to sum the cosmic rays
% into the crValue array

  crValue = zeros(size(cadenceRowColUnique)) ;
  for iCR = 1:length(cadenceRowCol)
      crValue(mapVector2(iCR)) = crValue(mapVector2(iCR))+cosmicRayMatrix(iCR) ;
  end
  
% we now need to get the indices of the cosmic ray pixels in the original pixel list,
% since the unique operation sorted the cosmic rays by their cadence,row,col index.  We
% can do this by partially reversing the sub2ind process to eliminate the cadence
% information, and then using the ismember function to find the pixelList(:,3) members
% which correspond to the cosmic ray pixels

  [cadence,crPixelIndexUnique] = ind2sub( [nCadences, ...
      (fcConstants.VIRTUAL_SMEAR_END + 1) * (fcConstants.TRAILING_BLACK_END + 1)], ...
      cadenceRowColUnique ) ;
  [tf,pixelPointer] = ismember( crPixelIndexUnique, pixelList(:,3) ) ;
  
% that's the end of the algorithm.  All that's left is cleanup -- restore the RNG to its
% previous condition if a state was passed by the caller

  if (nargin >= rngSeedArgNo && ~isempty(rngSeed))
      set_rand_state( randState ) ;
      set_randn_state( randnState ) ;
  end
  
return

% and that's it!

%
%
%
