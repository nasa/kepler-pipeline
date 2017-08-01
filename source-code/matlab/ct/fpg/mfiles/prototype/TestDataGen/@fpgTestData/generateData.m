function fpgTDout = generateData(fpgTestDataObj)
%
% Method which generates motion polynomials and other data of the fpgTestData class.
%
% version date:  2008-September-19.
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

% Modification history:
%
%    2008-September, 19, PT:
%        update raDec2PixClass constructor call.
%    2008-Apr-28, PT:
%        bugfix:  raDec2PixClass.geometryModel.array has 42 sets of 3-2-1 transformation
%        angles, not 84 sets.

%=========================================================================================

% initialize the returned object with the original

  fpgTDout = fpgTestDataObj ;
  
% set the mjd based on the calendar date

  fpgTDout.mjd = datestr2mjd(fpgTDout.calendarDate) ;
  
% obtain an raDec2Pix object which is valid on that mjd

  raDec2PixData = retrieve_ra_dec_2_pix_model(fpgTDout.mjd,fpgTDout.mjd) ;
  raDec2PixObj = raDec2PixClass(raDec2PixData,'zero-based') ;
  
% initialize the random number generators with the initialization information in the
% fpgTestData object

  rand('twister',get(fpgTDout,'randState')) ;
  randn('state',get(fpgTDout,'randnState')) ;
  
% the posRowCol are the nominal row and column positions of all the points to be used in
% fitting the motion polynomials (ie, they represent the pixel positions of the actual
% desired sky positions in the absence of any misalignments or pointing errors and on the
% reference pointing).  Convert these nominal pixel positions to the equivalent RA and Dec
% positions for each mod/out -- essentially, make up a grid of stars in the sky which
% correspond to the desired pixel positions under nominal / reference conditions; store
% the result in a pair of matrices.

  rowCol = get(fpgTDout,'posRowCol') ;
  rowRefPos = rowCol(:,1) ;
  colRefPos = rowCol(:,2) ;
  npoint = length(rowRefPos) ;
  raValues  = zeros(npoint,84) ;
  decValues = raValues ;

  modShapeVec = ones(npoint,1) ; 
  outShapeVec = modShapeVec ;
  
  modList = [2:4 6:20 22:24] ;
  modOut = 0 ;
  
  for iMod = modList 
      for iOut = 1:4
          modOut = modOut + 1 ;
          [raValues(:,modOut) decValues(:,modOut)] = pix_2_ra_dec(raDec2PixObj, ...
              iMod*modShapeVec, iOut*outShapeVec, rowRefPos, colRefPos, ...
              get(fpgTDout,'mjd') ) ;
      end
  end
  
% construct the constant errors in geometry and apply them to the raDec2Pix object.  The
% constant errors are:  the 3-2-1 transformation errors for the 42 CCDs; the plate scale
% error (expressed as 84 parameters in the raDec2Pix object, one for each mod/out).
%
% Errors in the CCD positions are generated with a flat random number generator, while the
% plate scale is applied exactly equal to the value in the fpgTestData object.

% start by generating a matrix of random numbers, uniformly generated from -1 to 1, with
% size 3 rows x 42 cols

  rMat = rand(3,42) ; rMat = 2*rMat - 1 ;
  
% multiply each column in rMat by the limit values in the fpgTestData object

  ccdError = get(fpgTDout,'ccdError') ; ccdError = ccdError(:) ;
  for iCCD = 1:42
      rMat(:,iCCD) = rMat(:,iCCD) .* ccdError ;
  end

% make a column vector out of the errors
  
  ccdPositionErrorVec = rMat(:) ;
%  ccdPositionErrorVec = ccdPositionErrorVec(:) ;
  
% the plate scale is a uniform error; since the value in the fpgTestData object is a
% fractional error, convert that to something more useful now

  plateScaleErrorVec = 1 + get(fpgTDout,'dPlateScale') * ones(84,1) ;
  
% update the geometry model in the local raDec2Pix object

  geometryModel = get(raDec2PixObj,'geometryModel') ;
  nGeom = length(geometryModel.constants) ;
  for iGeom = 1:nGeom
    geometryModel.constants(iGeom).array(1:126) = geometryModel.constants(iGeom).array(1:126) + ...
      ccdPositionErrorVec' ; 
    geometryModel.constants(iGeom).array(253:336) = geometryModel.constants(iGeom).array(253:336) .* ...
      plateScaleErrorVec' ;
  end
  raDec2PixObj = set(raDec2PixObj,'geometryModel',geometryModel) ;
  
% unpack the fixed pointing error from the object

  fixedPointingError = get(fpgTDout,'overallOrientationError') ;
  
% now we generate the pointings for non-reference pointing events, including both the
% expected variation from reference pointing and the errors.  Do this only if the pointing
% is not (0,0,0).

  cadencePointing = get(fpgTDout,'cadencedOrientation') ;
  cadencePointErr = get(fpgTDout,'cadencePointingError') ;
  cadencePointErr = cadencePointErr(:) ;
  
  nCadence = size(cadencePointing,2) ;
  for iCadence = 1:nCadence
      if ( (cadencePointing(1,iCadence) ~= 0) | ...
           (cadencePointing(2,iCadence) ~= 0) | ...
           (cadencePointing(3,iCadence) ~= 0)       )
          cadencePointing(1,iCadence) = cadencePointing(1,iCadence) * (1+cadencePointErr(4)) ;
          cadencePointing(2,iCadence) = cadencePointing(2,iCadence) * (1+cadencePointErr(5)) ;
          cadencePointing(:,iCadence) = cadencePointing(:,iCadence) + ...
              cadencePointErr(1:3) .*( 2*rand(3,1) -1 ) ;
      end
  end
  
  fpgTDout.pointingErrors = cadencePointing - get(fpgTDout,'cadencedOrientation') ;
  
% now generate the actual motion polynomials!  This is done by looping over cadences and
% mod/outs, generating the pixel locations of the artificial stars used in the fit via
% ra_dec_2_pix_relative ("relative" so that the cadence pointing offsets are included),
% fitting the 2D polynomials with weighted_polyfit2d, and then capturing everything in a
% data structure array!  This is called with the raDec2Pix object which has the modified
% geometry in it, so it should put the stars in the correct positions on the misaligned
% CCDs.  We also have to put Gaussian-distributed errors on the centroid locations...

  rowStruct = [] ; colStruct = [] ;
  for iCadence = 1:nCadence
      rowVec = [] ; colVec = [] ;
      for iModOut = 1:84
          [mod out row col] = ra_dec_2_pix_relative(raDec2PixObj, ...
              raValues(:,iModOut), decValues(:,iModOut), get(fpgTDout,'mjd'), ...
              cadencePointing(1,iCadence) + fixedPointingError(1), ...
              cadencePointing(2,iCadence) + fixedPointingError(2), ...
              cadencePointing(3,iCadence) + fixedPointingError(3)      ) ;
          if (any(out == -1))
              errormsg = ['Bad return from ra_dec_2_pix_relative, mod/out ',...
                  num2str(iModOut),', cadence ',num2str(iCadence)] ;
              error(errormsg) ;
          end
          
          row = row + get(fpgTDout,'centroidErrorPixels') * randn(npoint,1) ;
          col = col + get(fpgTDout,'centroidErrorPixels') * randn(npoint,1) ;
          
          rowpoly = weighted_polyfit2d(raValues(:,iModOut), decValues(:,iModOut), row, ...
              ones(npoint,1).*(1/get(fpgTDout,'centroidErrorPixels')), 3) ;
          
          colpoly = weighted_polyfit2d(raValues(:,iModOut), decValues(:,iModOut), col, ...
              ones(npoint,1).*(1/get(fpgTDout,'centroidErrorPixels')), 3) ;
          
% look at the residuals -- this is a debugging feature only

          rowresid = row - weighted_polyval2d(raValues(:,iModOut),decValues(:,iModOut),...
              rowpoly) ;
          colresid = col - weighted_polyval2d(raValues(:,iModOut),decValues(:,iModOut),...
              colpoly) ;
              
          rowVec = [rowVec ; rowpoly] ; colVec = [colVec ; colpoly] ;
          
      end % loop over mod/outs
      
      rowStruct = [rowStruct rowVec] ;
      colStruct = [colStruct colVec] ;
      
  end % loop over cadences
  
% put the polynomial structures and the raDec2PixClass object into the fpg test data
% object, and we're done!

  fpgTDout.raDec2PixObject = raDec2PixObj ;
  fpgTDout.rowPoly = rowStruct ; fpgTDout.colPoly = colStruct ;
  
  