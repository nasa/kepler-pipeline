function [fitParsRowCol, parCovarRowCol] = convert_fit_pars_to_row_column( fitPars, ...
    parCovar, fitterArgs )
%
% CONVERT_FIT_PARS_TO_ROW_COLUMN convert FPG fit parameters from the original basis (3-2-1
% pointing angles) to a (dRow,dCol,dRotation) coordinate system.
%
% [fitParsRowCol, parCovarRowCol] = convert_fit_pars_to_row_column( fitPars, parCovar,
%    fitterArgs ) takes the fitPars and covariance matrix parCovar, which are expressed in
%    terms of the 3-2-1 transformation angles, and converts them to fitParsRowCol and
%    parCovarRowCol, which express the transverse misalignments of the CCDs in row and
%    column coordinates.  
%
% Version date:  2008-June-06.
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
%     2008-June-06, PT:
%         change central column value to 1111.5, from 1112.5.
%
%=========================================================================================

% since some of the fit parameters don't change, copy the fitPars to fitParsRowCol

  fitParsRowCol = fitPars ;

% figure out which CCDs were fitted, and which were not

  geometryParMap = fitterArgs.geometryParMap ;
  indx3Angle = 1:3:126 ; 
  fittedCCDs = find(geometryParMap(indx3Angle) ~= 0) ;
  nFittedCCDs = length(fittedCCDs) ;
  nParameters = size(parCovar,1) ;
  
% convert the list of fitted CCDs to a list of channels by doubling the values in
% fittedCCDs

  fittedCCDChannel2 = 2*fittedCCDs ;
  
% convert to module and output

  [fittedMod, fittedOut] = convert_to_module_output(fittedCCDChannel2) ;
  
% extract an raDec2PixClass object from fitterArgs, and get the mjd of the reference
% cadence

  raDec2PixNom = fitterArgs.raDec2PixObject ;
  mjd = fitterArgs.mjds(1) ;
  
% get the nominal rotation angles (1-angles) out of the raDec2PixClass object

  geometryModel = get(raDec2PixNom,'geometryModel') ;
  parPtr = find(geometryParMap ~= 0) ;
  par1Ptr = find( mod(parPtr,3) == 0 ) ;
  par1Ptr = parPtr(par1Ptr) ; % indices into geometryModel.constants of fitted 1-angles
  
  angle1Nom = geometryModel.constants(1).array(par1Ptr) ;
  angle1Nom = angle1Nom(:)' ; % needs to be a row vector for what we have in mind
  
  
% make a column of nominal row and column values -- for each mod/out of interest, the row
% # is 531.5 and the col # is 1111.5 

  ovec = ones(length(fittedMod),1) ;
  rowNom = 531.5*ovec ;
  colNom = 1111.5*ovec ;
  
% convert the nominal positions to RA's and Decs, and convert the RAs and Decs into actual
% row and column with the updated CCD positions

  [raNom,decNom] = pix_2_ra_dec(raDec2PixNom, fittedMod, fittedOut, rowNom, colNom, mjd) ;
  raDec2PixAct = put_geometry_pars_in_raDec2PixObj( fitPars, raDec2PixNom, ...
      fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;
  [mAct,oAct, rowAct, colAct] = ra_dec_2_pix( raDec2PixAct, raNom, decNom, mjd ) ;
  
% convert column positions to CCD-based coordinates

  colCCDAct = convert_to_ccd_column( oAct, colAct ) ;
  
% compute the misalignments -- the misalignment of the CCD, in pixel coordinates, is the
% opposite of the change in pixel position of light falling on the CCD (ie, if a star is
% supposed to fall on row 500, but it falls on row 480, that's because the CCD has moved
% by +20 rows)

  dRow = rowNom - rowAct ; 
  dCol = colNom - colCCDAct ;
  
% put the misalignments in the new basis into the vector.  Since the vector is in order
% d3; d2; d1; d3; d2; d1, we have to do a little gymnastics to put the row and column data
% into the correct slots

  geomParMatrix = reshape(fitParsRowCol(1:3*nFittedCCDs), 3, nFittedCCDs) ;
  
% now the first row is 3-angles, the 2nd row is 2-angles, the 3rd row is 1-angles.  We can
% replace the 3-angles with row errors, the 2-angles with col errors, and then reverse the
% reshaping to put the data back into the fitParsRowCol vector.  Finally, compute the
% change in 1-angle.  Note that in the case of the 1-angle it's fitted - nominal to give
% the error; this is the opposite of the row and column, where we computed the error in
% star position in the real alignment and reversed this to get the error in the CCD
% position.

  geomParMatrix(1,:) = dRow' ;
  geomParMatrix(2,:) = dCol' ;
  geomParMatrix(3,:) = geomParMatrix(3,:) - angle1Nom ;
  
  fitParsRowCol(1:3*nFittedCCDs) = geomParMatrix(:) ;
  
% now for the covariance matrix transformation:  the covariance matrix transformation is
% given by:
%
%     sigma_rctheta = R sigma_321 R',
%
% where sigma_rctheta is the covariance matrix in the row-col-theta coordinate system,
% sigma_321 is the covariance matrix in the 3-2-1 coordinate system, and R is the
% transformation matrix from one system to the other at the current point:
%
%     R = [dr_1/d3_1 dr_1/d2_1 dr_1/d1_1 ...
%          dc_1/d3_1 dc_1/d2_1 dc_1/d1_1 ...
%              0         0         1     ...]
%
% R is a sparse matrix, with 3 x 3 block diagonals (and 2 of those 9 terms are zero, even)
% for the CCD geometry parameters, and below that a unit matrix (since the plate scale and
% the pointing parameters are just transformed to themselves).  So as a first step we'll
% allocate the sparse matrix and set up its nonzero locations, and then fill them in.

  R = allocate_sparse_transformation_matrix( nFittedCCDs, nParameters ) ;
  
% Now we need to compute the 6 derivatives per CCD which constitute the non-trivial
% values.  We can do this with raDec2PixAct, the actual (fitted) geometry, and the vectors
% of row and column center positions (rowNom, colNom), plus the list of fitted modules and
% outputs.  

% build an argument structure for the jacobian-calculator

  jacobianArgs.fitPars = fitPars ; 
  jacobianArgs.geometryParMap = fitterArgs.geometryParMap ;
  jacobianArgs.plateScaleParMap = fitterArgs.plateScaleParMap ;
  jacobianArgs.mjd = mjd ;
  jacobianArgs.parUncertainty = sqrt(diag(parCovar)) ;
  jacobianArgs.raDec2PixObject = raDec2PixAct ;
  
  for iCCD = 1:nFittedCCDs
      
      jacobianArgs.iCCD = iCCD ;
      jacobianArgs.r0 = rowNom(jacobianArgs.iCCD) ; 
      jacobianArgs.c0 = colNom(jacobianArgs.iCCD) ;
      [jacobianArgs.ra0,jacobianArgs.dec0] = pix_2_ra_dec(raDec2PixAct, ...
          fittedMod(jacobianArgs.iCCD), ...
          fittedOut(jacobianArgs.iCCD), ...
          jacobianArgs.r0, jacobianArgs.c0, jacobianArgs.mjd) ;
            
%     start with the 3-transformation

      iAngle = 3*(iCCD-1) + 1 ;
      [drByd3, dcByd3] = get_angle_to_rowcol_jacobian_terms( jacobianArgs, iAngle ) ;

%       dTheta = sqrt(parCovar(iAngle,iAngle)) * 1e-3 ;      
%       fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) + dTheta ;
%       raDec2PixActDelta = put_geometry_pars_in_raDec2PixObj( fitParsPlusDelta, raDec2PixAct, ...
%       fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;
%       [m,o,r1,c1] = ra_dec_2_pix(raDec2PixActDelta,ra0,dec0,mjd) ;
%       c1 = convert_to_ccd_column(o,c1) ;
%       drByd3 = (r1-r0) / dTheta ;
%       dcByd3 = (c1-c0) / dTheta ;
%       fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) - dTheta ;
      
%     now do the same for the 2 transformation

       iAngle = iAngle + 1 ;
      [drByd2, dcByd2] = get_angle_to_rowcol_jacobian_terms( jacobianArgs, iAngle ) ;
%       dTheta = sqrt(parCovar(iAngle,iAngle)) * 1e-3 ;      
%       fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) + dTheta ;
%       raDec2PixActDelta = put_geometry_pars_in_raDec2PixObj( fitParsPlusDelta, raDec2PixAct, ...
%       fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;
%       [m,o,r1,c1] = ra_dec_2_pix(raDec2PixActDelta,ra0,dec0,mjd) ;
%       c1 = convert_to_ccd_column(o,c1) ;
%       drByd2 = (r1-r0) / dTheta ;
%       dcByd2 = (c1-c0) / dTheta ;
%       fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) - dTheta ;
      
%     and the 1 transformation

       iAngle = iAngle + 1 ;
      [drByd1, dcByd1] = get_angle_to_rowcol_jacobian_terms( jacobianArgs, iAngle ) ;
%       dTheta = sqrt(parCovar(iAngle,iAngle)) * 1e-3 ;      
%       fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) + dTheta ;
%       raDec2PixActDelta = put_geometry_pars_in_raDec2PixObj( fitParsPlusDelta, raDec2PixAct, ...
%       fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;
%       [m,o,r1,c1] = ra_dec_2_pix(raDec2PixActDelta,ra0,dec0,mjd) ;
%       c1 = convert_to_ccd_column(o,c1) ;
%       drByd1 = (r1-r0) / dTheta ;
%       dcByd1 = (c1-c0) / dTheta ;
%       fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) - dTheta ;

%     put the values into the transformation matrix in the appropriate slots

      ccdRowOffset = 3*(iCCD-1) ;
      ccdColOffset = ccdRowOffset ;
      
      R(ccdRowOffset+1:ccdRowOffset+2,ccdColOffset+1:ccdColOffset+3) = ...
          [drByd3 drByd2 drByd1 ; dcByd3 dcByd2 dcByd1] ;
      
  end % end of loop over CCDs to build transformation matrix
  
% now the covariance matrix in the row-col-theta basis is easy to calculate:

  parCovarRowCol = R * parCovar * R' ;
  
% and that's it!

%
%
%

%=========================================================================================

% function to pre-allocate and pre-fill (where appropriate) the sparse transformation
% matrix from the 3-2-1 coordinate basis to the row-col-theta coordinates.

function R = allocate_sparse_transformation_matrix( nFittedCCDs, nParameters )

% How many non-zero values?  Each fitted CCD requires 7 values, and each parameter which
% is not a CCD geometry parameter needs 1.  Figure out how many geometry parameters, how
% many non-geometry parameters, and how many non-zero values are needed.

  nParGeometry = 3*nFittedCCDs ; 
  nParNotGeometry = nParameters - nParGeometry ;
  nNonZero = nParNotGeometry + 7 * nFittedCCDs ;
  
% the dimension of the R matrix is square, with size nParameters x nParameters.

  m = nParameters ; n = m ;
  
% prepare vectors of the correct length to populate the matrix

  iVec = ones(nNonZero,1) ; jVec = iVec ; valueVec = iVec ;
  
% we know that, for the non-geometry parameters, the i and j values are equal (on the
% diagonal), and we know that these are at the lower-right section of the matrix; so we
% can fill in i and j for those now, and the values are already correct at 1.0

  iVec(7*nFittedCCDs+1:nNonZero) = nParGeometry+1:nParameters ;
  jVec(7*nFittedCCDs+1:nNonZero) = nParGeometry+1:nParameters ;
  
% loop over the # of fitted CCDs.  For each fitted CCD, there are 7 non-zero parameters on
% the block diagonal:  (1,1), (1,2), (1,3), (2,1), (2,2), (2,3), and (3,3).  Set the i and
% j values now, and leave the matrix values at 1 for all of these.

  for iCCD = 1:nFittedCCDs
      
%     determine the indexing into the sparse matrix
      
      ccdIndexStart = 7*(iCCD-1)+1 ;
      ccdIndexEnd   = ccdIndexStart + 6 ;
      
%     determine the row and column of the upper-left-most of this CCD's entries in the
%     unsparse matrix

      ccdStartRowOffset = 3*(iCCD-1) ;
      ccdStartColOffset = ccdStartRowOffset ;
      
%     set up the map -- the first nonzero entry in the sparse matrix is the (1,1) entry in
%     the non-sparse matrix, the second non zero is the (1,2), etc; include the offset in
%     the unsparse matrix of the first element (ie, for CCD1 it's (1,1) but for CCD2 it's
%     (4,4), etc.)
      
      iVec(ccdIndexStart:ccdIndexEnd) = ccdStartRowOffset + [1 ; 2 ; 1 ; 2 ; 1 ; 2 ; 3] ;
      jVec(ccdIndexStart:ccdIndexEnd) = ccdStartColOffset + [1 ; 1 ; 2 ; 2 ; 3 ; 3 ; 3] ;
      
  end
  
% at this point the indexing for the sparse matrix is done, so put the valueVec values
% into the matrix using the iVec and jVec for row and column information

  R = sparse( iVec, jVec, valueVec, m, n ) ; 
 
% and that's it!

%
%
%

%=========================================================================================

% function which computes the jacobian terms dRow/dAngle and dCol/dAngle for a selected
% choice of angle

function [drBydAngle, dcBydAngle] = get_angle_to_rowcol_jacobian_terms( jacobianArgs, iAngle ) 

% start by finding an angle for the finite-difference calculation which is small compared
% to the error on the angle fit, and applying it to the correct term in the fit pars
% vector

  dTheta = jacobianArgs.parUncertainty(iAngle) * 1e-3 ; 
  fitParsPlusDelta = jacobianArgs.fitPars ;
  fitParsPlusDelta(iAngle) = fitParsPlusDelta(iAngle) + dTheta ;
   
% put the fit par vector, with the tweaked parameter, into raDec2Pix, and compute the row
% and column of the nominal RA and Dec (ie, the RA and Dec of the CCD center when the CCD
% is properly positioned, projected onto the misaligned CCD)
   
  raDec2PixActDelta = put_geometry_pars_in_raDec2PixObj( fitParsPlusDelta, ...
       jacobianArgs.raDec2PixObject, ...
       jacobianArgs.geometryParMap, jacobianArgs.plateScaleParMap ) ;
   [m,o,r1,c1] = ra_dec_2_pix(raDec2PixActDelta, jacobianArgs.ra0,...
       jacobianArgs.dec0, jacobianArgs.mjd) ;
   
% convert the column position from mod/out coords to CCD coords
   
  c1 = convert_to_ccd_column(o,c1) ;
  
% finally compute the dRow/dAngle and dColumn/dAngle finite differences
  
  drBydAngle = (r1-jacobianArgs.r0) / dTheta ;
  dcBydAngle = (c1-jacobianArgs.c0) / dTheta ;
  
% and that's it!

%
%
%

