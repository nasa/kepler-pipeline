function reflectedImageStruct = find_reflected_images( mod, out, mjd, magCutoff )
%
% FIND_REFLECTED_IMAGES -- find pixels which have ghost images on a particular mod/out.
%
% reflectedImageStruct = find_reflected_images( mod, out, mjd, magCutoff ) finds all the 
%    stars which will produce reflections on a selected module and output, on a selected
%    mjd, for which the specular portion of the reflection is brighter than stellar
%    magnitude magCutoff.  The returned reflectedImageStruct is a vector nReflect x 1,
%    where ghostImageStruct(iReflect) has the following vectors:
%
%              row:  row position on requested mod/out
%           column:  column position on requested mod/out
%        magnitude:  stellar magnitude on requested mod/out.
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

% find the stars which are above the brightness required to produce a reflection which is
% at least as bright as the cutoff magnitude.  If no stars meet the criteria, catch the
% error and handle it.  If some other error occurred, rethrow it.

  reflectionMagnitudeIncrease = 8.03 ;

  try
      kics = retrieve_kics( mod, out, mjd, 0, ...
                            magCutoff - reflectionMagnitudeIncrease ) ;
  catch
      retrieveKicsError = lasterror ;
      if ( retrieveKicsError.stack(1).line == 78 )
          reflectedImageStruct = [] ;
          return ;
      else
          rethrow(lasterror) ;
      end
  end
  
% now:  the only stars which actually produce reflections are the ones which lie within
% the area covered by aluminum on the CCD, which is rows 1 to 20 (or, more accurately, row
% == 0.5 to row == 20.5).  Find the subset of stars in the last KICS call which meet that
% criterion, if there are any:

  catalogRA = zeros(length(kics),1) ;
  catalogDec = zeros(length(kics),1) ;
  
  for iStar = 1:length(kics)
      catalogRA(iStar) = kics(iStar).getRa ;
      catalogDec(iStar) = kics(iStar).getDec ;
  end
  
  rd2pm = retrieve_ra_dec_2_pix_model() ;
  rd2pmo = raDec2PixClass(rd2pm,'one-based') ;
  
  [m,o,row,col] = ra_dec_2_pix(rd2pmo,catalogRA*15,catalogDec,mjd) ;
  
  onAluminum = find( (row >= 0.5) & (row <= 20.5) ) ;
  
  if (isempty(onAluminum))
      reflectedImageStruct = [] ;
      return ;
  end
  
% get the generic image of a reflection, with the max light amplitude set to 1.0

  [row, dCol, amplitude] = get_reflection_image() ;
  
% convert the amplitude to a magnitude shift

  dMagnitude = log10(amplitude) * -5/2 ;
  
% dimension the return structure

  reflectedImageStruct(length(onAluminum)).row       = [] ;
  reflectedImageStruct(length(onAluminum)).column    = [] ;
  reflectedImageStruct(length(onAluminum)).magnitude = [] ;
  
% loop over the stars which can make a reflection of the desired magnitude and pull out
% the pixels which are above the cutoff

  structPointer = 0 ;
  for iReflect = onAluminum(:)'
      
      structPointer = structPointer + 1 ;
      c = round(col(iReflect)) ; m = double(kics(iReflect).getKeplerMag) ;
      m = m + reflectionMagnitudeIncrease ;
      belowCutoff = find(dMagnitude + m <= magCutoff) ;
      
      rowImage = row(belowCutoff) ;
      colImage = c + dCol(belowCutoff) ;
      magImage = m + dMagnitude(belowCutoff) ;
      
%     now drop out the points which have column numbers which are < 12 or > 1111, since
%     those represent the limits of the physical silicon

      goodColumns = find(colImage >= 13 & colImage <= 1112) ;
      
      reflectedImageStruct(structPointer).row = rowImage(goodColumns) ;
      reflectedImageStruct(structPointer).column = colImage(goodColumns) ;
      reflectedImageStruct(structPointer).magnitude = magImage(goodColumns) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function which returns the generic image of a reflection, with both specular and diffuse
% components

function [dRow, dCol, amplitude] = get_reflection_image()

% the range of interest is dRow from 0 to 25 and dCol from -25 to 25

  rowValues = 0:25 ; colValues = -25:25
  
% build a grid from the values of interest

  [rowGrid, colGrid] = ndgrid(rowValues,colValues) ;
  
% compute the radius of each pixel

  pixelRadius = sqrt(rowGrid.^2 + colGrid.^2) ;
  
% compute the angle of each pixel and normalize to pi/4

  absAngle = abs(atan2(rowGrid,colGrid)) / (pi/4);
  
% vectorize the row and column, and build an amplitude vector of equal length

  dRow = rowGrid(:) ; dCol = colGrid(:) ; amplitude = zeros(size(dRow)) ;
  pixRadVec = pixelRadius(:) ; angleVec = absAngle(:) ;
  
% find the pixels which are within a radius of 25 pixels of the (0,0) pixel and turn them
% on with a value of 0.16, which is the relative intensity of the diffuse reflection
% compared to the peak of the specular

  iReflect = find(pixRadVec<=25) ;
  amplitude(iReflect) = 0.16 ;
  
% turn off the pixels which are in a "box" near the origin

  iReflect = find( abs(dCol) <= 12 & dRow <= 12) ; 
  amplitude(iReflect) = 0 ;
  
% turn off the pixels near the 45 degree lines

  iReflect = find(abs(angleVec-1) < 0.2) ;
  amplitude(iReflect) = 0 ;
  iReflect = find(abs(angleVec-3) < 0.2) ;
  amplitude(iReflect) = 0 ;

% put in the specular reflection:  first the core...

  iReflect = find( abs(dCol)<=1 & dRow <= 2 ) ;
  amplitude(iReflect) = 1 ;
  
% ...and now the extended cross at about half amplitude

  iReflect = find( abs(dCol) <= 1 & dRow > 2 & dRow <= 6) ;
  amplitude(iReflect) = 0.5 ;

  iReflect = find( abs(dCol) > 1 & abs(dCol) <= 4 & dRow <= 2 ) ;
  amplitude(iReflect) = 0.5 ;

% and that's it!

%
%
%

%=========================================================================================

  