function ghostImageStruct = find_ghost_images( mod, out, mjd, magCutoff )
%
% FIND_GHOST_IMAGES -- find pixels which have ghost images on a particular mod/out.
%
% ghostImageStruct = find_ghost_images( mod, out, mjd, magCutoff ) finds all the stars
%    which will produce ghost images on a selected module and output, on a selected mjd,
%    for which the center of the ghost is brighter than stellar magnitude magCutoff.  The
%    returned ghostImageStruct is a vector nGhost x 1, where ghostImageStruct(iGhost) has
%    the following vectors:
%
%              row:  row position on requested mod/out
%           column:  column position on requested mod/out
%        magnitude:  stellar magnitude on requested mod/out.
%
% Note that the calculation of row and column for an image are somewhat approximate at
%    this time.  The core brightness is based on a measured reduction in ghost brightness
%    relative to source brightness, and the brightness of surrounding pixels is based on a
%    Gaussian distribution (assumed) with a 3 sigma radius of 8.5 pixels (estimated total
%    extent of a ghost image).
%
% Version date:  2008-September-25.
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
%     2008-September-25, PT:
%         convert to explicitly one-based.
%
%=========================================================================================

% find the mod/out which is diametrically opposed to the requested one on the focal plane

  [modOpposite, outOpposite] = find_diametric_opposite_mod_out( mod, out ) ;
  
% find the stars which are above the brightness required to produce a ghost which is at
% least as bright as the cutoff magnitude.  If no stars meet the criteria, catch the error
% and handle it.  If some other error occurred, rethrow it.

  ghostMagnitudeIncrease = 11.31 ;

  try
      kics = retrieve_kics( modOpposite, outOpposite, mjd, 0, ...
                            magCutoff - ghostMagnitudeIncrease ) ;
  catch
      retrieveKicsError = lasterror ;
      if ( retrieveKicsError.stack(1).line == 78 )
          ghostImageStruct = [] ;
          return ;
      else
          rethrow(lasterror) ;
      end
  end
  
% if there's some stars which can generate ghosts, then compute the standard ghost profile
% in magnitudes

  [dRow, dCol, dMag] = ghost_profile( 8.5/3, 8.5/3 ) ;
  
% create the ghost data structure

  nGhosts = length(kics) ; 
  ghostImageStruct(nGhosts,1).row       = [] ;
  ghostImageStruct(nGhosts,1).column    = [] ;
  ghostImageStruct(nGhosts,1).magnitude = [] ;
  
% construct an ra_dec_2_pix object

  rd2pm = retrieve_ra_dec_2_pix_model() ;
  raDec2PixObject = raDec2PixClass(rd2pm,'one-based') ;
  
% loop over sources; get magnitude, ra, and dec; compute location; get locations of pixels
% which are above the cutoff in the ghost image.

  for iGhost = 1:nGhosts
      
      sourceMag = kics(iGhost).getKeplerMag ;
      sourceRA = kics(iGhost).getRa * 180 / 12 ;
      sourceDec = kics(iGhost).getDec ;
      
      [m,o,row, col] = ra_dec_2_pix(raDec2PixObject, sourceRA, sourceDec, mjd ) ;
      
      imageIndices = find( dMag + double(sourceMag) + ghostMagnitudeIncrease < magCutoff ) ;
      
      ghostImageStruct(iGhost,1).row = round(row) + dRow(imageIndices) ;
      ghostImageStruct(iGhost,1).column = round(col) + dCol(imageIndices) ;
      ghostImageStruct(iGhost,1).magnitude = double(sourceMag) + ghostMagnitudeIncrease ...
          + dMag(imageIndices) ;
      
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function which finds the mod/out which is diametrically opposed to the requested one

function [modOpposite, outOpposite] = find_diametric_opposite_mod_out( mod, out )

% module 13 is special, so do all the other modules first

  if ( mod ~= 13 )
      
%     make a 5 x 5 grid of the module locations; flip it in both horizontal and vertical
%     directions to get the mapping from modules to their opposites
      
      modMap = 1:25 ; modMap = reshape(modMap,5,5) ;
      modMapFlip = fliplr(flipud(modMap)) ;
      modOpposite = modMapFlip(mod) ;
      
%     for these modules, the outputs are symmetric under 180 degree rotation
      
      outOpposite = out ;
      
  else % module 13 -- just do a lookup
      
      modOpposite = mod ;
      switch out
          case 1
              outOpposite = 3 ;
          case 2
              outOpposite = 4 ;
          case 3
              outOpposite = 1 ;
          case 4
              outOpposite = 2 ;
      end
      
  end
  
  return 
  
% and that's it!

%
%
%

%=========================================================================================
      
% find the brightness of the grid of pixels which surrounds the ghost image, based on a
% Gaussian model and Ball's calculation of the "diameter" of the ghost image.

function [dRow, dCol, dMag] = ghost_profile( sigRow, sigCol ) ;
  
% initialize double_gaussian with the sigmas

  z = double_gaussian( [], [], sigRow, sigCol ) ;

% figure out how big a grid we need to get to 3 sigmas -- we want an odd-number of pixels
% in each direction so that (0,0) is centered on a pixel.

  nRow = ceil(2*3*sigRow) ; nCol = ceil(2*3*sigCol) ;
  if (mod(nRow,2) == 0)
      nRow = nRow + 1 ;
  end
  if (mod(nCol,2) == 0)
      nCol = nCol + 1 ;
  end
  maxRow = (nRow-1)/2 ; maxCol = (nCol-1)/2 ;
  
  [dRow,dCol] = ndgrid([-maxRow:maxRow],[-maxCol:maxCol]) ;
  dMag = zeros(size(dRow)) ;
  
% integrate to get the total intensity in each of the pixels
  
  for iRow = 1:nRow 
      for iCol = 1:nCol
          dMag(iRow,iCol) = dblquad( @double_gaussian, dRow(iRow,iCol)-0.5, dRow(iRow,iCol)+0.5, ...
                                                       dCol(iRow,iCol)-0.5, dCol(iRow,iCol)+0.5 ) ;
      end
  end
  
% normalize do the central pixel and convert to stellar magnitude

  dMag = log10(dMag/dMag(maxRow+1,maxCol+1)) * -5/2 ;
  
% convert to row vectors and return

  dRow = dRow(:) ;
  dCol = dCol(:) ;
  dMag = dMag(:) ;
  
  
% and that's it!

%
%
%

%=========================================================================================

% double_gaussian -- 2-d Gaussian function (not normalized).  If the first 2 args are zero
% and there are 4 total, then the user is pre-setting the sigma values for capture.

function z = double_gaussian( x, y, sigXUser, sigYUser )

  persistent invSigX2 invSigY2

  if (isempty(x) & isempty(y))
      invSigX2 = -1/sigXUser^2 ;
      invSigY2 = -1/sigYUser^2 ;
      z = 0 ;
      return
  end
     
% otherwise, do the integral

  z = exp(invSigX2 * x.^2) * exp(invSigY2 * y.^2) ;
  
% and that's it!

%
%
%

%=========================================================================================